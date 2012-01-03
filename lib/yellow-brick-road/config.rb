require 'closure-library-wrapper'

module YellowBrickRoad
  # Constants.

  ROOT = File.expand_path File.join(File.dirname(__FILE__), '..', '..')
  VENDOR_ROOT = File.join ROOT, 'vendor'

  CLOSURE_LIBRARY_ROOT_INTERNAL = ClosureLibraryWrapper.closure_library_root
  CLOSURE_LIBRARY_BASE_RELPATH = ['closure', 'goog', 'base.js']
  CLOSURE_DEPSWRITER_RELPATH = ['closure', 'bin', 'build', 'depswriter.py']

  CLOSURE_SOYUTILS_ROOT = File.join VENDOR_ROOT, 'closure-soyutils'
  CLOSURE_SOYUTILS_USEGOOG_ROOT = File.join VENDOR_ROOT, 'closure-soyutils-usegoog'

  CLOSURE_DEPS_FILE_RELPATH = ['app', 'assets', 'javascripts', 'closure-deps.js']

  CLOSURE_SOY_COMPILER = File.join VENDOR_ROOT, 'jars', 'SoyToJsSrcCompiler-111222.jar'

  # Config.

  mattr_accessor :closure_library_root
  @@closure_library_root = CLOSURE_LIBRARY_ROOT_INTERNAL

  mattr_reader :closure_deps_writer
  mattr_reader :closure_library_base

  def self.closure_library_root= value
    @@closure_library_root = value
    self.update_closure_library_properties
  end

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
    @@closure_library_base = File.join @@closure_library_root, *CLOSURE_LIBRARY_BASE_RELPATH
  end
  self.update_closure_library_properties

end
