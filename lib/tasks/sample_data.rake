namespace :db do
  desc "Fill database with sample data"

  task populate: :environment do
    make_users
    make_tvveets
    make_relationships
  end

  def make_users
    admin = User.create!(name: "David",
                         email: "hoodavy@gmail.com",
                         password: "foobar",
                         password_confirmation: "foobar")
    admin.toggle!(:admin)

    99.times do |n|
      name = Faker::Name.name
      email = "example#{n+1}@gmail.com"
      password = "foobar"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
  end

  def make_tvveets
    users = User.all(limit: 6)
    50.times do
      content = Faker::Lorem.sentence(8)
      users.each { |user| user.tvveets.create!(content: content) }
    end
  end

  def make_relationships
    users = User.all
    me = users.first
    my_idols = users[2..50]
    my_fans = users[3..40]

    my_idols.each { |idol| me.follow!(idol) }
    my_fans.each { |fan| fan.follow!(me) }
  end
end