module YellowBrickRoad
  ROOT = File.expand_path File.join(File.dirname(__FILE__), '..', '..')
  VENDOR_ASSETS_ROOT = File.join ROOT, 'vendor', 'assets'
  CLOSURE_LIBRARY_ROOT = File.join VENDOR_ASSETS_ROOT, 'closure-library'
  CLOSURE_LIBRARY_BASE = File.join CLOSURE_LIBRARY_ROOT, 'closure', 'goog', 'base.js'
  CLOSURE_DEPSWRITER = File.join CLOSURE_LIBRARY_ROOT, 'closure', 'bin', 'build', 'depswriter.py'
end
