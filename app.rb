SHOULD_RUN = $0 == __FILE__

require 'sinatra'
require 'sinatra/assetpack'
require 'sinatra/namespace' if SHOULD_RUN
require 'sinatra/activerecord'
require 'json'
require 'less'
require 'haml'

Dir["#{__dir__}/app/helpers/*.rb"].each { |file| require_relative file }
Dir["#{__dir__}/app/filters/*.rb"].each { |file| require_relative file }
Dir["#{__dir__}/app/models/*.rb" ].each { |file| require_relative file }

if SHOULD_RUN
  use Rack::Session::Cookie, secret: 'alabala-change-me-in-production'

  set :bind, '0.0.0.0'
  set :port, 8080
  set :root,          File.dirname(__FILE__)
  set :views,         proc { File.join(root, 'app', 'views') }

  register Sinatra::AssetPack

  assets do
    serve '/scripts', from: 'assets/scripts'
    serve '/styles',  from: 'assets/styles'
    serve '/images',  from: 'assets/images'
    serve '/styles/images',  from: 'assets/images'

    css :application, '/styles/application.css', [
      '/styles/layout.css',
      '/styles/index.css',
      '/styles/components.css',
    ]
  end

  Dir["#{__dir__}/app/controllers/*.rb" ].each { |file| require_relative file }

  set :socket_channels, SocketChannels.new
end
