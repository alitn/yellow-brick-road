require 'protocol_buffers'
require 'protocol_buffers/compiler'
require 'protocol_buffers/compiler/file_descriptor_to_ruby'
require 'tempfile'

module YellowBrickRoad

  def self.compile_protos_to_rb proto_files, logger = Rails.logger
    include_dirs = proto_files.map { |proto_file| File.dirname proto_file }
    include_dirs.uniq!

    protocfile = Tempfile.new 'ruby-protoc'
    protocfile.binmode
    ProtocolBuffers::Compiler.compile protocfile.path, proto_files,
      :include_dirs => include_dirs
    descriptor_set = FileDescriptorSet.parse protocfile
    protocfile.close true

    logger.info '* Compiling protobuf to ruby:'

    descriptor_set.file.each do |file_descriptor|
      proto_file = proto_files[proto_files.index { |path| path.include? file_descriptor.name }]
      logger.info "\t- #{proto_file}"

      path = File.join YellowBrickRoad.protos_rb_out_dir,
        File.basename(file_descriptor.name, '.proto') + '.pb.rb'

      FileUtils.mkpath(File.dirname(path)) unless File.directory?(File.dirname(path))

      File.open(path, "wb") do |file|
        dumper = FileDescriptorToRuby.new(file_descriptor)
        dumper.write(file)
      end
    end

    logger.info "\tCompiled all to ruby in #{YellowBrickRoad.protos_js_out_dir}"
  end

end
