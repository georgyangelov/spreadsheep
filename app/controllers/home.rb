namespace '/' do
  get do
    redirect to '/home' if user_logged_in?

    haml :index
  end

  get 'home' do
    redirect to '/' unless user_logged_in?

    haml :index
  end
end
