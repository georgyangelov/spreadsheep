namespace '/user' do
  get '/search/:query' do |query|
    subword_query = "%#{query}%"
    users = User.where('full_name like ? or email like ?', subword_query, subword_query)

    json users.as_json only: [:id, :full_name, :email]
  end
end
