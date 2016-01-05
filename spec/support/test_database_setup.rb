require 'active_record'

# create a postgresql database:
ActiveRecord::Base.establish_connection adapter: :postgresql, database: 'pg_flash_json_test', username: ENV['PG_DB_USERNAME'], password: ENV['PG_DB_PASSWORD']

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

def seed_data
  create_post_table  unless ActiveRecord::Migration.table_exists?(:posts)
  create_comment_table unless ActiveRecord::Migration.table_exists?(:comments)
  100.times do |i|
    post = Post.create!(title: "Post ##{i}", content: "some post content #{(i).to_s}")
    1.times {|ci| Comment.create(content: "comment content #{ci}", post_id: post.id)}
  end
end

def create_post_table
  ActiveRecord::Migration.create_table :posts do |t|
    t.string :title
    t.text :content
  end
end

def create_comment_table
  ActiveRecord::Migration.create_table :comments do |t|
    t.string :content
    t.integer :post_id
  end
end

RSpec.configure do |config|
  config.before :suite do
    seed_data
  end
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
  config.after :suite do
    Post.delete_all
    Comment.delete_all
  end

end

# ActiveRecord::Base.logger = Logger.new(STDOUT)