
module YellowBrickRoad
  include ProtobufClosureLibrary

  def self.compile_protos_to_js proto_files, logger = Rails.logger

    generator_options = {}
    if YellowBrickRoad.protobuf_js_superclass
      generator_options[:js_superclass] = YellowBrickRoad.protobuf_js_superclass
    end
    if YellowBrickRoad.protobuf_js_collection_superclass
      generator_options[:js_collection_superclass] = YellowBrickRoad.protobuf_js_collection_superclass
    end
    if YellowBrickRoad.protobuf_js_advanced
      generator_options[:advanced] = 'true'
    end

    logger.info '* Compiling protobuf to closure-library javascript:'

    proto_files.each do |proto_file|
      logger.info "\t- #{proto_file}"
      ProtocJs.compile proto_file, YellowBrickRoad.protos_js_out_dir,
        generator_options: generator_options
    end

    logger.info "\tCompiled all to javascript in #{YellowBrickRoad.protos_js_out_dir}"
  end

end
