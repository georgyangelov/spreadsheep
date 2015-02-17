namespace '/sheet' do
  before { require_user_login! }

  get '/:id' do |id|
    @sheet = Sheet.find id

    ensure_user_access_to @sheet

    haml :'sheet/view', layout: :fullscreen
  end

  get '/:id/data' do |id|
    @sheet = Sheet.find id

    ensure_user_access_to @sheet

    json({
      row_sizes: @sheet.row_sizes,
      column_sizes: @sheet.column_sizes,
      cells: @sheet.cells
    })
  end

  get '/create/:directory_id' do |directory_id|
    @directory = Directory.find directory_id
    ensure_user_access_to @directory

    haml :'sheet/create'
  end

  post '/create/:directory_id' do |directory_id|
    @directory = Directory.find directory_id
    ensure_user_access_to @directory

    Sheet.create! user: current_user,
                  directory: @directory,
                  name: params['name']

    redirect to "/directory/#{@directory.id}/#{@directory.slug}"
  end

  post '/:id/delete' do |id|
    @sheet = Sheet.find id
    ensure_user_access_to @sheet

    redirect_url = "/directory/#{@sheet.directory.id}/#{@sheet.directory.slug}"

    @sheet.destroy!

    redirect to redirect_url
  end

  get '/:id/edit' do |id|
    @sheet = Sheet.find id
    ensure_user_access_to @sheet

    haml :'sheet/create'
  end

  post '/:id/edit' do |id|
    @sheet = Sheet.find id
    ensure_user_access_to @sheet

    @sheet.name = params['name']
    @sheet.save!

    redirect to "/directory/#{@sheet.directory.id}/#{@sheet.directory.slug}"
  end
end
