namespace '/directory' do
  before { require_user_login! }

  get do
    @directory = current_user.root_directory

    @directories = @directory.directories
    @directories += Directory.root_shares(current_user.id)

    @directories.sort_by!(&:updated_at).reverse!

    haml :'directory/list'
  end

  get '/create/:parent_id' do |parent_directory_id|
    haml :'directory/create'
  end

  post '/create/:parent_id' do |parent_directory_id|
    has_directory_with_same_name = Directory.exists? name: params['name'],
                                                     parent_id: parent_directory_id

    if has_directory_with_same_name
      flash[:error] = 'A directory with the same name already exists'

      redirect to "/directory/create/#{parent_directory_id}"
    end

    shared_with_users = params['shares'].split(',').map do |user_email|
      next if user_email == current_user.email

      User.find_by(email: user_email.strip)
    end.compact

    shared_with_users << current_user

    new_directory = Directory.create name: params['name'],
                                     creator: current_user,
                                     allowed_users: shared_with_users,
                                     parent: Directory.find(parent_directory_id)

    redirect to "/directory/#{new_directory.id}/#{new_directory.slug}"
  end

  post '/delete/:id' do |id|
    directory = Directory.find_by id: id, creator: current_user

    halt 400, haml(:error) if directory.root?

    parent = directory.parent
    redirect_url = "/directory/#{parent.id}/#{parent.slug}"

    directory.destroy!

    redirect to redirect_url
  end

  get '/:id/*' do |id, _|
    @directory = Directory.find(id)

    ensure_user_access_to @directory

    @directories = @directory.directories
    @directories += Directory.root_shares(current_user.id) if @directory.root?

    @directories.to_a.sort_by!(&:updated_at).reverse!

    @parent = @directory.parent_for_user(current_user)

    haml :'directory/list'
  end
end
