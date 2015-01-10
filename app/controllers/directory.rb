namespace '/directory' do
  before { require_user_login! }

  get '/list' do
    @directory = current_user.root_directory

    haml :'directory/list'
  end
end
