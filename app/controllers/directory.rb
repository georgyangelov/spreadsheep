namespace '/directory' do
  before { require_user_login! }

  get do
    @directory = current_user.root_directory

    haml :'directory/list'
  end

  get '/:id/*' do |id, _|
    @directory = Directory.find_by id: id, users: current_user

    haml :'directory/list'
  end

  post '/delete/:id' do |id|
    directory = Directory.find_by id: id, user: current_user

    halt 400, haml(:error) if directory.root?

    parent = directory.parent
    redirect_url = "/directory/#{parent.id}/#{parent.slug}"

    directory.destroy!

    redirect to redirect_url
  end
end
