namespace '/' do
  get do
    haml :index
  end

  get 'home' do
    haml :index
  end
end
