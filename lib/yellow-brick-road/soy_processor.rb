require 'tilt'
require 'closure'

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
  end

  attr_reader :namespace

  def evaluate scope, locals, &block
    # Since SoyToJsSrcCompiler does not provide a stdout access to
    # the output, the output is written to a tempfile.
    tempoutput = Rails.root.join 'tmp', "soy-#{Time.now.to_i.to_s}.js"

    compiler_args = []
    if !Config.standalone_soy
      compiler_args = compiler_args | %w{
        --shouldProvideRequireSoyNamespaces
        --cssHandlingScheme goog
        --shouldGenerateJsdoc
      }
    end
    compiler_args << "--outputPathFormat" << tempoutput
    compiler_args << file
    compile compiler_args

    @output = IO.read tempoutput
    File.delete tempoutput

    @output
  end

private

  def compile args
    args = args.collect {|a| a.to_s } # for bools and numerics

    out, err = Closure.run_java Closure.config.soy_js_jar, 'com.google.template.soy.SoyToJsSrcCompiler', args
    unless err.empty?
      raise err
    end
  end

end
end
