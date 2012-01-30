require 'systemu'

module YellowBrickRoad
class Utils

  def self.run_command command, options
    STDOUT.sync = true

    options = {
      command_arg: nil,
      command_options: {},
      command_error_message: "An error occured while running command: #{command}",
      stderr_as_error: false
    }.merge options

    command_options = self.serialize_options options[:command_options]
    command_properties = [command, command_options]
    command_properties << options[:command_arg] if options[:command_arg]
    command_string = command_properties.flatten.join(' ')

    status, stdout, stderr = systemu command_string

    unless status.exitstatus.zero?
      # Wrap longs texts.
      err = stderr.gsub!(/(.{1,#{120}})( +|$\n?)|(.{1,#{120}})/, "\\1\\3\n")
      self.raise_error err, options[:command_error_message], command_string
    end

    return stdout, stderr
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

  def self.raise_error error_message, command_error_message, command_string
    raise <<-FIN
#{command_error_message}

#{error_message}"


Command string:

#{command_string}
    FIN
  end

end
end
