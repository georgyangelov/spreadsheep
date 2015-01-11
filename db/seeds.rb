user = User.create email: 'georgyangelov@gmail.com',
                   password: '1234',
                   full_name: 'Georgy Angelov'

root = user.root_directory

5.times do |i|
  dir = Directory.create name: "Directory #{i}", user: user, parent: root

  3.times do |i|
    Directory.create name: "Subdirectory #{i}", user: user, parent: dir
  end
end
