module YellowBrickRoad
  @@protobuf_enabled = true

  def self.compile_protos logger = Rails.logger
    YellowBrickRoad.initProtos
    proto_files = Dir[YellowBrickRoad.protos_dir]

    if proto_files.empty?
      logger.info "No protobuf file to compile in #{YellowBrickRoad.protos_dir}."
      return
    end

    compile_protos_to_js proto_files, logger
    compile_protos_to_rb proto_files, logger 
  end

end
