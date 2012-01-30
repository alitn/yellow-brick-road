require 'tilt'
require 'tempfile'

module YellowBrickRoad
class SoyProcessor < Tilt::Template

  def self.default_mime_type
    'application/javascript'
  end

  def self.default_namespace
    'this.SOY'
  end

  def prepare
    @namespace = self.class.default_namespace

    @compiler_options = {}
    if !YellowBrickRoad.standalone_soy
      @compiler_options.merge!({
        shouldProvideRequireSoyNamespaces: '',
        shouldGenerateJsdoc: '',
        cssHandlingScheme: 'goog'
      })
    end
  end

  attr_reader :namespace

  def evaluate scope, locals, &block
    # When concatenating closure code by closurebuilder,
    # the soy processor should not function as it will lead to
    # duplicated code.
    # Completely unregistering the soy processor is not an option
    # as we need to track the soy files assets.
    return ';' if YellowBrickRoad.concat_closure_roots

    # Since SoyToJsSrcCompiler does not provide a stdout access to
    # the output, the output is written to a tempfile.
    # tempoutput = Rails.root.join 'tmp', "soy-#{Time.now.to_i.to_s}.js"
    tempfile = Tempfile.new 'soy'

    compiler_options = @compiler_options.merge outputPathFormat: tempfile.path

    compile compiler_options

    @output = IO.read tempfile.path
    tempfile.unlink

    @output
  end

private

  def compile compiler_options
    Utils::run_command "java -jar #{CLOSURE_SOY_COMPILER}",
      command_arg: file,
      command_options: compiler_options,
      command_error_message: 'An error occured while running closure soy template compiler.'
  end

end
end
