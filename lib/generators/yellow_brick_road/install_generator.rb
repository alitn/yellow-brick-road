module YellowBrickRoad
module Generators
class InstallGenerator < Rails::Generators::Base

  source_root File.expand_path '../../templates', __FILE__
  desc 'Creates a yellow-brick-road initializer.'

  def copy_initializer
    template 'yellow_brick_road.rb.erb', 'config/initializers/yellow_brick_road.rb'
  end

end
end
end
