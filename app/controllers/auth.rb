namespace '/auth' do
  get '/register' do
    haml :'auth/register'
  end

  post '/register' do
    user = User.new params.only(:full_name, :email, :password)

    halt haml :error unless user.valid?

    user.save!

    flash[:notice] = 'You have registered successfully!'
    redirect to '/'
  end

  get '/login' do
    haml :'auth/login'
  end

  post '/login' do
    user = User.find_by(email: params['email']).try(:authenticate, params['password'])

    if user
      login user

      redirect to '/'
    else
      flash[:login_error] = 'Invalid email or password.'

      redirect to '/auth/login'
    end
  end

  get '/logout' do
    logout

    redirect to '/'
  end
end
