namespace '/' do
  get do
    redirect to '/directory/list' if user_logged_in?

    haml :index
  end
end
