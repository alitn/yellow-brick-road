require 'open3'

module YellowBrickRoad
class Utils

  def self.run_command command, options
    options = {
      command_arg: nil,
      command_options: {},
      command_error_message: "An error occured while running command: #{command}"
    }.merge options

    command_options = self.serialize_options options[:command_options]
    command_properties = [command, command_options]
    command_properties << options[:command_arg] if options[:command_arg]
    command_string = command_properties.flatten.join(' ')

    begin
      stdin, stdout, stderr = Open3.popen3 command_string
    rescue StandardError => error
      raise "#{options[:command_error_message]}\n\n#{error.message}"
    end

    err = stderr.readlines
    if false# !err.empty?
      err = err.join('')
      # Wrap longs texts.
      err.gsub!(/(.{1,#{120}})( +|$\n?)|(.{1,#{120}})/, "\\1\\3\n")
      raise "#{options[:command_error_message]}\n\n#{err}"
    end
  end

  private

  def self.serialize_options options
    options.map do |k, v|
      if v.is_a?(Array)
        v.uniq!
        v.map {|v2| ["--#{k}", v2.to_s]}
      else
        ["--#{k}", v.to_s]
      end
    end.flatten
  end

end
end
