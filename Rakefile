require 'sinatra/activerecord/rake'

require_relative 'app'

task :run do
  exec 'rerun --no-growl -d . -p "**/*.{rb,yml}" -- ruby app.rb'
end

task :console do
  exec 'pry -r ./app.rb'
end
