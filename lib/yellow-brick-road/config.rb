module YellowBrickRoad
  module Config
    mattr_accessor :standalone_soy
    @@stand_alone_soy = false
  end

  # Constants.
  ROOT = File.expand_path File.join(File.dirname(__FILE__), '..', '..')
  VENDOR_ASSETS_ROOT = File.join ROOT, 'vendor'
  CLOSURE_LIBRARY_ROOT = File.join VENDOR_ASSETS_ROOT, 'closure-library'
  CLOSURE_LIBRARY_BASE = File.join CLOSURE_LIBRARY_ROOT, 'closure', 'goog', 'base.js'
  CLOSURE_SOYUTILS_ROOT = File.join VENDOR_ASSETS_ROOT, 'closure-soyutils'
  CLOSURE_SOYUTILS_USEGOOG_ROOT = File.join VENDOR_ASSETS_ROOT, 'closure-soyutils-usegoog'
  CLOSURE_DEPSWRITER = File.join CLOSURE_LIBRARY_ROOT, 'closure', 'bin', 'build', 'depswriter.py'
end
