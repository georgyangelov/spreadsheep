user = User.create email: 'georgyangelov@gmail.com',
                   password: '1234',
                   full_name: 'Georgy Angelov'

User.create email: 'gangelov@asteasolutions.com',
            password: '1234',
            full_name: 'Joro Angelov'

User.create email: 'pe6o@gmail.com',
            password: '1234',
            full_name: 'Petar Petrov'

root = user.root_directory

5.times do |i|
  dir = Directory.create name: "Directory #{i}",
                         creator: user,
                         allowed_users: [user],
                         parent: root

  3.times do |i|
    Directory.create name: "Subdirectory #{i}",
                     creator: user,
                     allowed_users: [user],
                     parent: dir
  end
end
