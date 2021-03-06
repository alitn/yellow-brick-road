YellowBrickRoad.setup do |config|
  # Yellow-brick-road comes with an internal copy of the closure library.
  # The following git commit-id is the latest one at the time of generating
  # this config file. The commit-id is corresponded to git svn mirror of
  # https://github.com/jarib/google-closure-library which is wrapped by 
  # https://github.com/alitn/closure-library-wrapper gem.
  #
  # If you change this commit-id, you will need to restart rails.
  config.closure_library_lock_at 'e67b83515e9cde8a3c42db7621123bcbe19560c3'

  # Uncomment this to set the closure library root to an external directory.
  # When this options is used, the above commit-id lock will be ignored.
  # config.closure_library_root = '/path/to/your/closure-library-root'

  # Uncomment this to use yellow-brick-road as an standalone
  # soy template compiler. If this option is used, the output
  # of the compiler will be different -- see the documentation.
  # config.standalone_soy = true
end
