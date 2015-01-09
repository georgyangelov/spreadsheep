require 'sinatra/activerecord/rake'

require_relative 'app'

task :run do
  exec 'rerun -d app -p "**/*.{rb,yml,haml}" -- ruby app.rb'
end

task :console do
  exec 'pry -r ./app.rb'
end
