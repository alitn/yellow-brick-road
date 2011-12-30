module YellowBrickRoad
class Engine < Rails::Engine

  initializer :yellow_brick_road do |app|
    app.assets.append_path CLOSURE_LIBRARY_ROOT
    app.assets.unregister_processor 'application/javascript', Sprockets::DirectiveProcessor
    app.assets.register_processor 'application/javascript', ClosureBuilderProcessor
  end

end
end
