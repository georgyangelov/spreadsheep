namespace '/' do
  get do
    redirect to '/directory' if user_logged_in?

    haml :index
  end
end
