require 'rubygems'
require File.expand_path(File.dirname(__FILE__)) + '/../lib/redismapper'

# setup
RedisMapper.setup(Redis.new :db => 14)
@r = RedisMapper.db

# load your models
require 'models'

# clean db
RedisMapper.delete_db

# insert
u = User.create(:name => "makevoid")
Message.create(:title => "Hello!", :text => "Welcome in the world of redismapper...", :user_id => u.id)
u = User.create(:name => "me")
Message.create(:title => "Hello!", :text => "bla bla...", :user_id => u.id)
Message.create(:title => "Hey", :text => "bla bla..", :user_id => u.id)

# read
puts "messages (#{Message.count}):"
p Message.all
# Message.all(:select => :title) # faster, fetches only the title
puts

puts "users (#{User.count}):"
p User.all
puts

puts "Finding a user and his messages"
u = User.first(:name => "me")
p Message.all(:user_id => u.id)
# to be implemented
# Message.all(:)

