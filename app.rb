SHOULD_RUN = $0 == __FILE__

require 'sinatra'
require 'sinatra/json'
require 'sinatra/assetpack'
require 'sinatra/namespace' if SHOULD_RUN
require 'sinatra/activerecord'
require 'sinatra-websocket'
require 'rack-flash'
require 'json'
require 'less'
require 'haml'
require 'rack/csrf'

Dir["#{__dir__}/app/helpers/*.rb"].each { |file| require_relative file }
Dir["#{__dir__}/app/filters/*.rb"].each { |file| require_relative file }
Dir["#{__dir__}/app/validators/*.rb" ].each { |file| require_relative file }
Dir["#{__dir__}/app/models/*.rb" ].each { |file| require_relative file }

if SHOULD_RUN
  use Rack::Session::Cookie, secret: 'alabala-change-me-in-production'
  use Rack::Flash, sweep: true

  set :bind, '0.0.0.0'
  set :port, 8080
  set :root,          File.dirname(__FILE__)
  set :views,         proc { File.join(root, 'app', 'views') }

  # Add jsx as a supported format
  module Sinatra::AssetPack
    class << self
      alias_method :original_supported_formats, :supported_formats

      def supported_formats
        original_supported_formats

        @supported_formats |= ['jsx']
      end
    end
  end

  configure do
    mime_type :jsx, 'text/jsx'
  end

  register Sinatra::AssetPack

  assets do
    serve '/scripts', from: 'assets/scripts'
    serve '/styles',  from: 'assets/styles'
    serve '/images',  from: 'assets/images'
    serve '/fonts',   from: 'assets/fonts'
    serve '/styles/images',  from: 'assets/images'

    css :sheet_view, '/styles/sheet_view.css', [
      '/styles/fullscreen.css'
    ]
    css :application, '/styles/application.css', [
      '/styles/font-awesome.min.css',
      '/styles/layout.css',
      '/styles/index.css',
      '/styles/components.css',
      '/styles/directory.css',
      '/styles/selectize.css',
    ]

    js :sheet_view, '/scripts/sheet_view.js', [
      '/scripts/libs/handsontable_full_modified.js',
      '/scripts/handsontable_plugins/remote_selections.js',

      '/scripts/socket.js',
      '/scripts/sheet.js'
    ]
    js :application, '/scripts/application.js', [
      '/scripts/helpers.js'
    ]
  end

  Dir["#{__dir__}/app/controllers/*.rb" ].each { |file| require_relative file }

  set :socket_channels, SocketChannels.new
end
