module Sinatra
  module Authentication
    def login(user)
      session[:user_id] = user.id
    end

    def logout
      session[:user_id] = @current_user = nil
    end

    def current_user
      return unless session[:user_id]

      @current_user ||= User.find(session[:user_id])
    end

    def user_logged_in?
      !!current_user
    end
  end

  helpers Authentication
end
