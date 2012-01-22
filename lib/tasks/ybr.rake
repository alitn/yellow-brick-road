namespace :ybr do

  if YellowBrickRoad.protobuf_enabled
    desc 'Compile protocol buffer files.'
    task :compile_protos do
      initializer = Rails.root.join 'config', 'initializers', 'yellow_brick_road.rb'
      require initializer
      YellowBrickRoad.compile_protos Logger.new(STDOUT)
    end
  end

end
