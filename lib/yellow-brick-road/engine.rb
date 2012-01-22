module YellowBrickRoad

class Engine < Rails::Engine

  initializer :yellow_brick_road do |app|
    if YellowBrickRoad.clear_asset_cache_on_startup
      Rails.application.assets.cache.clear
    end

    YellowBrickRoad.initClosureConfig
    app.assets.append_path YellowBrickRoad.closure_library_root

    if YellowBrickRoad.standalone_soy
      app.assets.append_path CLOSURE_SOYUTILS_ROOT
    else
      app.assets.append_path CLOSURE_SOYUTILS_USEGOOG_ROOT
    end

    if YellowBrickRoad.protobuf_enabled
      YellowBrickRoad.initProtos
      app.assets.append_path YellowBrickRoad.protos_js_out_dir
    end

    app.assets.unregister_processor 'application/javascript', Sprockets::DirectiveProcessor
    app.assets.register_processor 'application/javascript', ClosureBuilderProcessor

    app.assets.register_engine '.soy', SoyProcessor
  end

end
end
