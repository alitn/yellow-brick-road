module YellowBrickRoad
CONFIG = ActiveSupport::OrderedOptions.new

class Engine < Rails::Engine

  initializer :yellow_brick_road do |app|
    app.assets.append_path CLOSURE_LIBRARY_ROOT

    if Config.standalone_soy
      app.assets.append_path CLOSURE_SOYUTILS_ROOT
    else
      app.assets.append_path CLOSURE_SOYUTILS_USEGOOG_ROOT
    end

    app.assets.unregister_processor 'application/javascript', Sprockets::DirectiveProcessor
    app.assets.register_processor 'application/javascript', ClosureBuilderProcessor

    app.assets.register_engine '.soy', SoyProcessor
  end

end
end
