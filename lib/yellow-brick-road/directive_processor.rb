require 'sprockets/directive_processor.rb'

module YellowBrickRoad
class ClosureBuilderProcessor < Sprockets::DirectiveProcessor

  def prepare
    super
    @closure_roots = []
    @closure_deps_file = Rails.root.join *CLOSURE_DEPS_FILE_RELPATH
    @closure_root_prefix = File.join '..', '..'
    @has_executed_closure_builder = false
  end

  def process_require_closure_root_directive path
    context.require_asset YellowBrickRoad.closure_library_base
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
    generate_closure_dependencies
  end

private
  
  def generate_closure_dependencies
    return nil if @closure_roots.empty? || @has_executed_closure_builder

    if !YellowBrickRoad.standalone_soy
      @closure_roots.unshift << {
        path: CLOSURE_SOYUTILS_USEGOOG_ROOT,
        path_relative_to_goog_base: '/'
      }
    if YellowBrickRoad.protobuf_enabled
      context.depend_on YellowBrickRoad.protos_js_out_dir
      @closure_roots.unshift ({
        path: YellowBrickRoad.protos_js_out_dir,
        path_relative_to_goog_base: File.join('..', '..')
      })
    end

    closure_roots_with_prefix = @closure_roots.map { |cr| "'#{cr[:path]} #{cr[:path_relative_to_goog_base]}'" }

    result = Utils::run_command YellowBrickRoad.closure_deps_writer,
      command_options: {
        root_with_prefix: closure_roots_with_prefix,
        output_file: @closure_deps_file
      },
      command_error_message: 'An error occured while running closure depswriter.py.'

    @has_executed_closure_builder = true
    Rails.logger.info "Executed closure depswriter.py on root paths: #{@closure_roots.join(', ')}"


    result
  end

end
end
