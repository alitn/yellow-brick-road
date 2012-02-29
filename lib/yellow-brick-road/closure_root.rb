require 'fileutils'
require 'pathname'

module YellowBrickRoad
class ClosureRoot

  # Since closure build tools do not support fetching souce files as urls,
  # it is not possible to render non-js files like .js.soy, or js files with
  # sprockets directives, and feed them to the build tools. This method renders
  # these files to a temprary directory, where the build tools can access them
  # within the block.
  def self.process_roots closure_roots, options = {}, &block
    options = {
      copy_dot_js: true
    }.merge options

    closure_roots = [closure_roots] if !closure_roots.kind_of?(Array)

    source_path = Rails.root.to_s
    target_path_parent = Dir.mktmpdir

    begin
      js_files = []
      processed_roots = {}

      closure_roots.each do |closure_root|
        target_path = File.join(target_path_parent, closure_root.hash.to_s(36)).to_s

        # Find all non-directory files in the closure root.
        closure_root_files = Dir["#{closure_root}/**/*"].find_all{|f| !File.directory? f}

        # Process each file as an asset.
        closure_root_files.each do |asset_path|
          asset = Rails.application.assets[asset_path]
          next if !asset

          if !options[:copy_dot_js] && asset_path.ends_with?('.js')
            js_files << asset_path
          else
            target_asset_path = asset_path.gsub closure_root, target_path
            target_asset_path.gsub! /\.js\.[^.]+$/i, '.js' # foo.js.JS.soy -> foo.js
            FileUtils.mkdir_p Pathname.new(target_asset_path).dirname
            asset.write_to target_asset_path
            js_files << target_asset_path
            processed_roots[closure_root] ||= target_path
          end
        end
      end

      # TODO: Render the start_point, if asked.
      # if options[:start_point]
      #   start_point_asset = Rails.application.assets[options[:start_point]]
      #   start_point_dir = File.join target_path_parent, 'start_point'
      #   FileUtils.mkdir_p start_point_dir
      #   start_point_file = File.join(start_point_dir, 'start_point.js')
      #   start_point_asset.write_to start_point_file
      #   processed_roots[:start_point_dir] = start_point_dir
      #   js_files << start_point_file
      # end

      properties = {
        processed_roots: processed_roots,
        js_files: js_files,
        tmp_dir: target_path_parent
      }

      # Perform the external process.
      yield properties
    ensure
      # Clean up.
      FileUtils.remove_entry_secure target_path_parent
    end
  end

end
end
