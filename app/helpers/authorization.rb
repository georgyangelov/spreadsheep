module Sinatra
  module Authorization
    def ensure_user_access_to(object)
      raise Sinatra::NotFound unless object
      halt 403, haml(:error)  unless object.has_access? current_user
    end

    def ensure_user_creator_of(object)
      raise Sinatra::NotFound unless object
      halt 403, haml(:error)  unless object.creator_id == current_user.id
    end
  end

  helpers Authorization
end
