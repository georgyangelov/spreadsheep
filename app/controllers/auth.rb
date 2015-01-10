namespace '/auth' do
  get '/register' do
    haml :'auth/register'
  end

  post '/register' do
    user = User.new params.only(:full_name, :email, :password)

    halt haml :error unless user.valid?

    user.save!

    flash[:notice] = 'You have registered successfully!'
    redirect to '/home'
  end
end
