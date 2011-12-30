require 'sprockets/directive_processor.rb'

module YellowBrickRoad
class ClosureBuilderProcessor < Sprockets::DirectiveProcessor

  def prepare
    super
    @closure_roots = []
    @closure_deps_file = Rails.root.join 'app', 'assets', 'javascripts', 'closure-deps.js'
    @has_executed_closure_builder = false
  end

  def process_require_closure_root_directive path
    context.require_asset CLOSURE_LIBRARY_BASE
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

    @closure_roots << closure_root.to_s
  end

  def process_directives
    super
    generate_closure_dependencies
  end

private
  
  def generate_closure_dependencies
    return nil if @closure_roots.empty? || @has_executed_closure_builder

    result = Utils::run_command CLOSURE_DEPSWRITER,
      command_options: {
        root_with_prefix: "'#{CLOSURE_LIBRARY_ROOT} ../../'",
        root: @closure_roots,
        output_file: @closure_deps_file
      },
      command_error_message: 'An error occured while running closure depswriter.py.'

    @has_executed_closure_builder = true
    Rails.logger.info "Executed closure depswriter.py on root paths: #{@closure_roots.join(', ')}"


    result
  end

end
end