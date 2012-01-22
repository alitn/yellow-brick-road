require 'closure-library-wrapper'

module YellowBrickRoad
  # Constants.

  ROOT = File.expand_path File.join(File.dirname(__FILE__), '..', '..')
  VENDOR_ROOT = File.join ROOT, 'vendor'

  CLOSURE_LIBRARY_ROOT_INTERNAL = ClosureLibraryWrapper.closure_library_root
  CLOSURE_LIBRARY_GOOG_RELPATH = ['closure', 'goog']
  CLOSURE_LIBRARY_THIRD_PARTY_RELPATH = ['third_party', 'closure', 'goog']
  CLOSURE_LIBRARY_BASE_FILE_NAME = 'base.js'
  CLOSURE_LIBRARY_DEPS_FILE_NAME = 'deps.js'
  CLOSURE_DEPSWRITER_RELPATH = ['closure', 'bin', 'build', 'depswriter.py']
  CLOSURE_BUILDER_RELPATH = ['closure', 'bin', 'build', 'closurebuilder.py']

  CLOSURE_SOYUTILS_ROOT = File.join VENDOR_ROOT, 'closure-soyutils'
  CLOSURE_SOYUTILS_USEGOOG_ROOT = File.join VENDOR_ROOT, 'closure-soyutils-usegoog'

  CLOSURE_DEPS_FILE_RELPATH = ['app', 'assets', 'javascripts', 'closure-deps.js']

  CLOSURE_SOY_COMPILER = File.join VENDOR_ROOT, 'jars', 'SoyToJsSrcCompiler-111222.jar'

  # Config.

  mattr_reader :closure_deps_writer
  mattr_reader :closure_builder

  mattr_reader :closure_library_goog
  mattr_reader :closure_library_third_party
  mattr_reader :closure_library_base
  mattr_reader :closure_library_deps

  mattr_accessor :closure_library_root
  @@closure_library_root = CLOSURE_LIBRARY_ROOT_INTERNAL
  def self.closure_library_root= value
    @@closure_library_root = value
    self.update_closure_library_properties
  end

  mattr_accessor :concat_closure_roots

  def self.initClosureConfig
    @@concat_closure_roots = !Rails.application.config.assets.debug
  end

  mattr_reader :protobuf_enabled
  @@protobuf_enabled = false

  mattr_accessor :protos_dir
  mattr_accessor :protos_js_out_dir
  def self.initProtos
    @@protos_dir ||= Rails.root.join 'app', 'protos', '**', '*.proto'
    @@protos_js_out_dir ||= Rails.root.join 'app', 'assets', 'javascripts', 'protos'
  end

  mattr_accessor :protobuf_js_superclass
  @@protobuf_js_superclass = nil

  mattr_accessor :protobuf_js_advanced
  @@protobuf_js_advanced = false

  mattr_accessor :standalone_soy
  @@stand_alone_soy = false

  def self.closure_library_lock_at commit_id
    ClosureLibraryWrapper.lock_at commit_id
  end

  def self.setup
    yield self
  end

private

  def self.update_closure_library_properties
    @@closure_deps_writer = File.join @@closure_library_root, *CLOSURE_DEPSWRITER_RELPATH
    @@closure_builder = File.join @@closure_library_root, *CLOSURE_BUILDER_RELPATH
    @@closure_library_goog = File.join @@closure_library_root, *CLOSURE_LIBRARY_GOOG_RELPATH
    @@closure_library_third_party = File.join @@closure_library_root, *CLOSURE_LIBRARY_THIRD_PARTY_RELPATH
    @@closure_library_base = File.join @@closure_library_goog, CLOSURE_LIBRARY_BASE_FILE_NAME
    @@closure_library_deps = File.join @@closure_library_goog, CLOSURE_LIBRARY_DEPS_FILE_NAME
  end
  self.update_closure_library_properties

end
