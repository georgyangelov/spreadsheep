SHOULD_RUN = $0 == __FILE__

require 'sinatra'
require 'sinatra/assetpack'
require 'sinatra/namespace' if SHOULD_RUN
require 'sinatra/activerecord'
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

  register Sinatra::AssetPack

  assets do
    serve '/scripts', from: 'assets/scripts'
    serve '/styles',  from: 'assets/styles'
    serve '/images',  from: 'assets/images'
    serve '/fonts',   from: 'assets/fonts'
    serve '/styles/images',  from: 'assets/images'

    css :application, '/styles/application.css', [
      '/styles/font-awesome.min.css',
      '/styles/layout.css',
      '/styles/index.css',
      '/styles/components.css',
      '/styles/directory.css',
    ]

    js :application, '/scripts/application.js', [
      '/scripts/helpers.js'
    ]
  end

  Dir["#{__dir__}/app/controllers/*.rb" ].each { |file| require_relative file }

  set :socket_channels, SocketChannels.new
end
