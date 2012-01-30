module YellowBrickRoad
class ClosureCompilerController < ActionController::Base

  layout false

  def index
    if !params['commit']
      @results = []
    else
      compiler = ClosureCompiler.new compilation_level: params[:cl],
        warning_level: params[:wl]
      @results = compiler.compile
    end

    @compilation_levels = ClosureCompiler::COMPILATION_LEVEL.map {|k| [k, k]}
    @compilation_levels_default = params[:cl] || ClosureCompiler::COMPILATION_LEVEL[1]
    @warning_levels = ClosureCompiler::WARNING_LEVEL.map {|k| [k, k]}
    @warning_levels_default = params[:wl] || ClosureCompiler::WARNING_LEVEL[1]
  end

end
end
