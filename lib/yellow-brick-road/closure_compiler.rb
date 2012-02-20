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
      compilation_level: COMPILATION_LEVEL[1],
      warning_level: WARNING_LEVEL[1]
    }.merge options
  end

  def compile
    Rails.application.assets.cache.clear
    # Rails.application.config.assets.digest = false

    @source_path = Rails.root.to_s
    @tmpdir = Dir.mktmpdir
    @target_path = File.join(@tmpdir, 'js').to_s

    results = Hash[*YellowBrickRoad.closure_start_points.collect { |start_point|
        [start_point, compile_start_point(start_point)]
      }.flatten]

    FileUtils.remove_entry_secure @tmpdir
    
    results
  end

private

  def compile_start_point start_point
    # Rails.application.assets[start_point] must be called before
    # anything else, in order to init.
    start_point_dependencies = Rails.application.assets[start_point].to_a
    start_point_dependencies.uniq!
    # Exclude the closure root deps file from dependencies.
    closure_deps_file = Rails.root.join(*CLOSURE_DEPS_FILE_RELPATH).to_s

    # Process and copy source *.js dependencies to target *.js.
    start_point_dependencies.each do |processed_asset|
      asset_path = processed_asset.pathname.to_s

      next if !asset_path.starts_with? @source_path
      next if asset_path == closure_deps_file

      target_asset = asset_path.gsub @source_path, @target_path
      FileUtils.mkdir_p Pathname.new(target_asset).dirname
      processed_asset.write_to "#{target_asset}.js"
    end

    # Find all files under each closure root.
    # TODO: extend this for multiple closure roots.
    closure_root = YellowBrickRoad.closure_roots_registry[start_point][0]
    closure_root_dependencies = Dir["#{closure_root}/**/*"].find_all{|f| !File.directory? f}
    closure_root_dependencies.uniq!

    # Process and copy source *.js dependencies to target *.js.
    closure_root_dependencies.each do |asset_path|
      next if !asset_path.starts_with? @source_path
      next if asset_path == closure_deps_file

      asset = Rails.application.assets[asset_path]
      next if !asset

      target_asset = asset_path.gsub @source_path, @target_path
      FileUtils.mkdir_p Pathname.new(target_asset).dirname
      asset.write_to "#{target_asset}.js"
    end

    js_files = generate_closure_dependencies
    raise "Generated javascript dependencies for #{start_point} is empty." if js_files.empty?

    js_output_file = File.join @tmpdir, 'out.js'

    compiler_options = {
      js: js_files,
      js_output_file: js_output_file,
      compilation_level: @options[:compilation_level],
      warning_level: @options[:warning_level],
      summary_detail_level: 3
    }

    out, err = Utils::run_command "java -jar #{CLOSURE_COMPILER}",
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
    
    err = err.split("\n").map {|line| process_line line}
    err[-1] = "<b>#{err[-1]}</b>"
    compiler_output = err.join "\n"

    {compiler_output: compiler_output, js_files: js_files}
  end

  def generate_closure_dependencies
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

    # Gather roots.
    closure_roots = [
      @target_path,
      YellowBrickRoad.closure_library_goog,
      YellowBrickRoad.closure_library_third_party,
      CLOSURE_SOYUTILS_USEGOOG_ROOT
    ]
    if YellowBrickRoad.protobuf_enabled
      closure_roots << YellowBrickRoad.protos_js_out_dir
    end

    list_file = File.join @tmpdir, 'list'

    # Run closurebuilder.
    Utils::run_command YellowBrickRoad.closure_builder,
      command_options: {
        root: closure_roots,
        output_mode: 'list',
        namespace: namespace,
        output_file: list_file,
      },
      command_error_message: 'An error occured while running closurebuilder.py.',
      stderr_as_error: false

    IO.read(list_file).split "\n"
  end

  def calculate_uncompressed_size manifiest
    size = 0
    manifiest.each do |file|
      size += File.size file
    end
    size /= 1024
  end

  def file_line_regex
    @file_line_regex || (
      escaped_target_path = Regexp.escape @target_path
      @file_line_regex = /^(#{escaped_target_path}.*):(\d+):/
    )
  end
  
  def process_line input
    match = file_line_regex.match input
    return input if match.nil?

    input.gsub! "#{@target_path}/", ''
    input.gsub! match.captures[1], "<b>#{match.captures[1]}</b>"

    input
  end

end
end
