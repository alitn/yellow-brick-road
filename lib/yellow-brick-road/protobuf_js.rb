
module YellowBrickRoad
  @@protobuf_enabled = true
  include ProtobufClosureLibrary

  def self.compile_protos logger = Rails.logger
    YellowBrickRoad.initProtos
    proto_files = Dir[YellowBrickRoad.protos_dir]

    if proto_files.empty?
      logger.info "No protobuf file to compile in #{YellowBrickRoad.protos_dir}."
      return
    end

    generator_options = {}
    if YellowBrickRoad.protobuf_js_superclass
      generator_options[:js_superclass] = YellowBrickRoad.protobuf_js_superclass
    end
    if YellowBrickRoad.protobuf_js_advanced
      generator_options[:advanced] = 'true'
    end

    logger.info 'Compiling protobuf to closure-library javascript:'
    proto_files.each do |proto_file|
      logger.info "\t- #{proto_file}"
      ProtocJs.compile proto_file, YellowBrickRoad.protos_js_out_dir,
        generator_options: generator_options
    end
    logger.info "Compiled all to #{YellowBrickRoad.protos_js_out_dir}"
  end

end
