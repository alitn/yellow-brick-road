require 'sprockets/directive_processor.rb'
require 'sprockets/bundled_asset.rb'
require 'fileutils'

module YellowBrickRoad
class ClosureBuilderProcessor < Sprockets::DirectiveProcessor

  GOOG_BASE_REL_PATH = File.join '..', '..'

  def prepare
    super
    @closure_roots = []
    @closure_root_prefixes = {}
    @has_processed_closure_roots = false
    @has_closure_root = false
  end

  def process_require_closure_root_directive path
    if relative? path
      closure_root = pathname.dirname.join(path).expand_path

      unless (stats = stat(closure_root)) && stats.directory?
        raise ArgumentError, 'require_closure_root argument must be a directory'
      end

      context.depend_on closure_root
      register_closure_root closure_root

      each_entry closure_root do |pathname|
        context.depend_on pathname
      end
    else
      # The path must be relative and start with a `./`.
      raise ArgumentError, 'require_closure_root argument must be a relative path'
    end

    # require_closure_root ./app -> app
    # require_closure_root ../app -> ../app
    relpath = path.starts_with?('./') ? path[2..-1] : path

    # require_closure_root ./app in file appdir/file.js  -> appdir
    parent = Pathname.new(context.logical_path).parent.to_s
    parent = '' if parent == '.'

    path_relative_to_goog_base = File.join GOOG_BASE_REL_PATH, parent, relpath
    
    closure_root_path = closure_root.to_s
    @closure_roots << closure_root_path
    @closure_root_prefixes[closure_root_path] = path_relative_to_goog_base
  end

  def process_directives
    if @has_closure_root
      # Require closure base once, and before any other assets.
      context.require_asset YellowBrickRoad.closure_library_base
    end

    super
    process_closure_roots
  end

  def evaluate context, locals, &block
    @has_closure_root = directives.map{|d| d[1]}.include? 'require_closure_root'

    if YellowBrickRoad.closure_compiler[:enable] && @has_closure_root
      @context = context

      # Only process require_closure_root to keep the dependency sane.
      directives.each do |line_number, name, *args|
        next if name == 'require_closure_root'
        context.__LINE__ = line_number
        send("process_#{name}_directive", *args)
        context.__LINE__ = nil
      end

      @has_written_body = true
      @result = generate_with_closure_compiler
    else
      super
    end

    @result
  end

private

  def register_closure_root closure_root
    key = context.pathname.basename.to_s
    registry = YellowBrickRoad.closure_roots_registry[key] ||= []
    registry << closure_root.to_s
    registry.uniq!
  end
  
  def process_closure_roots
    return if @closure_roots.empty? || @has_processed_closure_roots

    @closure_roots.uniq!

    if !YellowBrickRoad.standalone_soy
      @closure_roots.unshift CLOSURE_SOYUTILS_USEGOOG_ROOT
      @closure_root_prefixes[CLOSURE_SOYUTILS_USEGOOG_ROOT] = GOOG_BASE_REL_PATH
    end

    if YellowBrickRoad.protobuf_enabled
      context.depend_on YellowBrickRoad.protos_js_out_dir
      @closure_roots.unshift YellowBrickRoad.protos_js_out_dir
      @closure_root_prefixes[YellowBrickRoad.protos_js_out_dir] = GOOG_BASE_REL_PATH
    end

    generate_closure_root_deps

    @has_processed_closure_roots = true
  end

  def generate_closure_root_deps
    ClosureRoot.process_roots @closure_roots, copy_dot_js: false do |properties|
      closure_roots_with_prefix = @closure_roots.map { |closure_root|
        processed_root = properties[:processed_roots][closure_root]
        prefix = @closure_root_prefixes[closure_root]
        roots = ["'#{closure_root} #{prefix}'"]
        roots.push("'#{processed_root} #{prefix}'") if processed_root
        roots
      }.flatten

      stdout = Utils::run_command YellowBrickRoad.closure_deps_writer,
        command_options: {
          root_with_prefix: closure_roots_with_prefix
        },
        command_error_message: 'An error occured while running closure depswriter.py.'
      @result << stdout.join('')
    end
    
    Rails.logger.info "Executed closure depswriter.py on closure root paths: #{@closure_roots.join(', ')}"
  end

  def generate_with_closure_compiler
    # Ugly hack to avoid circular dependency:
    # Copy this asset, process it and pass the output.
    # TODO: Find a better solution.
    closure_compiler_enabled = YellowBrickRoad.closure_compiler[:enable]
    YellowBrickRoad.closure_compiler[:enable] = false
    copy_file_extension_name = "-#{Time.now.to_i}.js"
    copy_file_logical_path = "#{context.logical_path}#{copy_file_extension_name}"
    copy_file_path = "#{pathname}#{copy_file_extension_name}"
    copy_file_pathname = Pathname.new copy_file_path

    js_output = ''

    begin
      FileUtils.cp pathname, copy_file_path
      copy_asset = Sprockets::BundledAsset.new context.environment,
        copy_file_logical_path, copy_file_pathname
      compiler = ClosureCompiler.new(compiler_options: YellowBrickRoad.closure_compiler[:options])
      js_output = compiler.compile_start_point(copy_asset)[:js_output]
    ensure
      FileUtils.rm(copy_file_path) if File.exists?(copy_file_path)
      YellowBrickRoad.closure_compiler[:enable] = closure_compiler_enabled
    end 

    js_output
  end

end

  mattr_reader :closure_roots_registry
  @@closure_roots_registry = {}
end
