require 'sprockets/directive_processor.rb'

module YellowBrickRoad
class ClosureBuilderProcessor < Sprockets::DirectiveProcessor

  GOOG_BASE_REL_PATH = File.join '..', '..'

  def prepare
    super
    @closure_roots = []
    @closure_deps_file = Rails.root.join *CLOSURE_DEPS_FILE_RELPATH
    @closure_root_prefix = File.join '..', '..'
    @has_processed_closure_roots = false
  end

  def process_require_closure_root_directive path
    if !YellowBrickRoad.concat_closure_roots
      context.require_asset YellowBrickRoad.closure_library_base
      context.require_asset YellowBrickRoad.closure_library_deps
    end
    context.require_asset @closure_deps_file

    if relative? path
      closure_root = pathname.dirname.join(path).expand_path

      unless (stats = stat(closure_root)) && stats.directory?
        raise ArgumentError, 'require_closure_root argument must be a directory'
      end

      context.depend_on closure_root

      each_entry closure_root do |pathname|
        context.depend_on pathname
      end
    else
      # The path must be relative and start with a `./`.
      raise ArgumentError, 'require_closure_root argument must be a relative path'
    end

    relpath = path.starts_with?('./') ? path[2..-1] : path
    @closure_roots << {
      path: closure_root.to_s,
      path_relative_to_goog_base: File.join('..', '..', relpath)
    }
  end

  def process_directives
    super
    process_closure_roots
  end

private
  
  def process_closure_roots
    return nil if @closure_roots.empty? || @has_processed_closure_roots

    if !YellowBrickRoad.standalone_soy
      @closure_roots.unshift ({
        path: CLOSURE_SOYUTILS_USEGOOG_ROOT,
        path_relative_to_goog_base: GOOG_BASE_REL_PATH
      })
    end

    if YellowBrickRoad.protobuf_enabled
      context.depend_on YellowBrickRoad.protos_js_out_dir
      @closure_roots.unshift ({
        path: YellowBrickRoad.protos_js_out_dir,
        path_relative_to_goog_base: File.join('..', '..')
      })
    end

    result = YellowBrickRoad.concat_closure_roots ?
      generate_concat : generate_no_concat

    @has_processed_closure_roots = true

    result
  end

  def generate_no_concat
    closure_roots_with_prefix = @closure_roots.map { |cr| "'#{cr[:path]} #{cr[:path_relative_to_goog_base]}'" }

    result = Utils::run_command YellowBrickRoad.closure_deps_writer,
      command_options: {
        root_with_prefix: closure_roots_with_prefix,
        output_file: @closure_deps_file
      },
      command_error_message: 'An error occured while running closure depswriter.py.'
    
    closure_roots = @closure_roots.map { |cr| cr[:path] }
    Rails.logger.info "Executed closure depswriter.py on root paths: #{closure_roots.join(', ')}"

    result
  end

  def generate_concat
    closure_roots = @closure_roots.map { |cr| cr[:path] }
    closure_roots.unshift YellowBrickRoad.closure_library_third_party
    closure_roots.unshift YellowBrickRoad.closure_library_goog

    # Generate soy files
    soy_files = []
    Rails.application.assets.each_file do |asset_file|
      soy_files << asset_file.to_s if asset_file.extname == '.soy'
    end
    soy_out_dir = Rails.root.join 'tmp', 'soy'
    compile_soy_templates soy_files, soy_out_dir
    closure_roots << soy_out_dir

    result = Utils::run_command YellowBrickRoad.closure_builder,
      command_options: {
        root: closure_roots,
        output_mode: 'script',
        namespace: 'interaxt.app',
        output_file: @closure_deps_file
      },
      command_error_message: 'An error occured while running closurebuilder.py.'

    Rails.logger.info "Executed closurebuilder.py on root paths: #{closure_roots.join(', ')}"

    result
  end

  def compile_soy_templates soy_files, out_dir
    return if soy_files.empty?

    FileUtils.mkdir_p out_dir

    result = Utils::run_command "java -jar #{CLOSURE_SOY_COMPILER}",
      command_arg: soy_files.join(' '),
      command_options: {
        outputPathFormat: File.join(out_dir, 'soy-tmp.js'),
        shouldProvideRequireSoyNamespaces: '',
      },
      command_error_message: 'An error occured while running closurebuilder.py.'
  end

end
end
