require './app'
require 'rack/sassc'

use Rack::SassC, {
  check: ENV['RACK_ENV'] != 'production',
  syntax: :scss,
  css_location: 'public',
  scss_location: 'public/scss',
  create_map_file: true,
}
run Sinatra::Application
