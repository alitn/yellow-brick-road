require 'fileutils'
require 'pathname'

module YellowBrickRoad
class ClosureCompiler

  COMPILATION_LEVEL = [
    :WHITESPACE_ONLY,
    :SIMPLE_OPTIMIZATIONS,
    :ADVANCED_OPTIMIZATIONS
  ]

  WARNING_LEVEL = [
    :QUIET,
    :DEFAULT,
    :VERBOSE
  ]

  def initialize options = {}
    @options = {
      compiler_options: {
        compilation_level: COMPILATION_LEVEL[1],
        warning_level: WARNING_LEVEL[1]
      },
      stats: false
    }.merge options

    @source_path = Rails.root.to_s
  end

  def compile
    Rails.application.assets.cache.clear
    # Rails.application.config.assets.digest = false

    results = Hash[*YellowBrickRoad.closure_start_points.collect { |start_point|
        [start_point, compile_start_point(start_point)]
      }.flatten]
    
    results
  end

  def compile_start_point start_point
    start_point_asset = start_point.kind_of?(String) ? Rails.application.assets[start_point] : start_point
    start_point_dependencies = start_point_asset.to_a
    start_point_dependencies.uniq!

    start_point_key = start_point.kind_of?(String) ? start_point : start_point.pathname.basename.to_s
    closure_roots = YellowBrickRoad.closure_roots_registry[start_point_key]

    # Check for namespace.
    namespace = YellowBrickRoad.closure_namespace
    if namespace.empty?
      raise <<-FIN
        No closure namespace was given. One or more input files to
        calculate dependencies is required by closurebuilder.py. Set
        a namespace or an array of namespaces to YellowBrickRoad.closure_namespace
        in the initializer.
      FIN
    end

    externs = nil
    externs_dir = YellowBrickRoad.closure_compiler[:externs_dir]
    if externs_dir
      externs = Dir["#{externs_dir}/**/*"].find_all{|f| !File.directory? f}
    end

    compiler_output = ''
    js_files = []
    js_output = ''

    ClosureRoot.process_roots closure_roots do |properties|
      roots = properties[:processed_roots].values | [
        YellowBrickRoad.closure_library_goog,
        YellowBrickRoad.closure_library_third_party,
        CLOSURE_SOYUTILS_USEGOOG_ROOT]

      # if YellowBrickRoad.protobuf_enabled
      #   roots << YellowBrickRoad.protos_js_out_dir
      # end

      js_list = File.join properties[:tmp_dir], 'list.js'

      Utils::run_command YellowBrickRoad.closure_builder,
        command_options: {
          root: roots,
          output_mode: 'list',
          namespace: namespace,
          output_file: js_list
        },
        command_error_message: 'An error occured while running closure depswriter.py.'

      js_files = IO.read(js_list).split "\n"
      js_output_file = File.join properties[:tmp_dir], 'out.js'
      
      compiler_options = {
        js: js_files,
        js_output_file: js_output_file,
        summary_detail_level: 3
      }.merge! @options[:compiler_options]
      compiler_options[:externs] = externs if externs

      out, err = Utils::run_command "java -Xmn256M -Xms1024M -Xmx1024M -jar #{CLOSURE_COMPILER}",
        command_arg: '',
        command_options: compiler_options,
        command_error_message: 'An error occured while running closure compiler.'

      compiled_size = File.size(js_output_file) / 1024
      uncompressed_size = calculate_uncompressed_size js_files
      compression = '%.1f' % (100 * (1 - compiled_size.to_f / uncompressed_size))
      err.chomp!
      err << ", #{compiled_size} kb compiled"
      err << ", #{uncompressed_size} kb uncompressed"
      err << ", #{compression}% compressed"
      err << '.'
      
      err = err.split("\n").map {|line| process_line line, properties[:tmp_dir]}
      err[-1] = "<b>#{err[-1]}</b>"
      compiler_output = err.join "\n"

      js_output = IO.read js_output_file
    end

    {compiler_output: compiler_output, js_files: js_files, js_output: js_output}
  end

private

  def calculate_uncompressed_size manifiest
    size = 0
    manifiest.each do |file|
      size += File.size file
    end
    size /= 1024
  end
  
  def process_line input, target_path
    escaped_target_path = Regexp.escape target_path
    file_line_regex = /^(#{escaped_target_path}.*):(\d+):/

    match = file_line_regex.match input
    return input if match.nil?

    input.gsub! "#{target_path}/", ''
    input.gsub! match.captures[1], "<b>#{match.captures[1]}</b>"

    input
  end

end

class IdentityCompiler

  def compress io
    io.to_s
  end

end
end
