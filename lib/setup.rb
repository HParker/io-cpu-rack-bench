require "active_record"

ActiveRecord::Base.establish_connection(
  adapter: 'trilogy',
  host: 'localhost',
  username: 'root',
  database: 'blog_development'
)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
  end
end

class Post < ActiveRecord::Base
end

Post.destroy_all
100.times { Post.create! }
