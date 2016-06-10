require 'bundler/setup'
Bundler.require

if development?
  Activerecord::Base.establish_connection("sqlite3:db/development.db")
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end