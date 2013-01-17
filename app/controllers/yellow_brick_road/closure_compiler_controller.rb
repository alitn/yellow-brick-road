module YellowBrickRoad
class ClosureCompilerController < ActionController::Base

  layout false
  @@closure_compiler_default_config ||= {}
  @@is_applied = false

  def index
    @results = []

    compiler_options = {
      compilation_level: params[:cl],
      warning_level: params[:wl]
    }

    if params['compile']
      compile params[:sp], compiler_options
    elsif params['apply_settings'] # Experimental.
      Rails.application.assets.cache.clear
      @@is_applied ? default_settings : apply_settings(compiler_options)
    end

    @is_applied = @@is_applied
    @start_points = YellowBrickRoad.closure_start_points.keys
    @start_points_default = params[:sp] || @start_points[0]
    @compilation_levels = ClosureCompiler::COMPILATION_LEVEL.map {|k| [k, k]}
    @compilation_levels_default = params[:cl] || ClosureCompiler::COMPILATION_LEVEL[1]
    @warning_levels = ClosureCompiler::WARNING_LEVEL.map {|k| [k, k]}
    @warning_levels_default = params[:wl] || ClosureCompiler::WARNING_LEVEL[1]
  end

private

  def compile start_point, compiler_options
    begin
      closure_compiler_enabled = YellowBrickRoad.closure_compiler[:enable]
      YellowBrickRoad.closure_compiler[:enable] = false
      compiler = ClosureCompiler.new compiler_options: compiler_options, stats: true
      @results = compiler.compile start_point
    ensure
      YellowBrickRoad.closure_compiler[:enable] = closure_compiler_enabled
    end
  end

  def apply_settings compiler_options
    @@closure_compiler_default_config[:enable] = YellowBrickRoad.closure_compiler[:enable]
    @@closure_compiler_default_config[:options] = YellowBrickRoad.closure_compiler[:options]
    YellowBrickRoad.closure_compiler[:enable] = true
    YellowBrickRoad.closure_compiler[:options] = compiler_options
    @@is_applied = true
  end

  def default_settings
    YellowBrickRoad.closure_compiler[:enable] = @@closure_compiler_default_config[:enable]
    YellowBrickRoad.closure_compiler[:options] = @@closure_compiler_default_config[:options]
    @@is_applied = false
  end

end

end
