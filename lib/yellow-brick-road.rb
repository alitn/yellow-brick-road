require 'yellow-brick-road/version'
require 'yellow-brick-road/config'
require 'yellow-brick-road/utils'
begin
  require 'protobuf-closure-library'
  require 'yellow-brick-road/protobuf_js'
rescue LoadError
end
require 'yellow-brick-road/directive_processor'
require 'yellow-brick-road/soy_processor'
require 'yellow-brick-road/engine'
