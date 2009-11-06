class Message < RedisMapper
  property :title, :index => true    # enables Message.find
  property :text
  property :user_id, :index => true # connects it to User (atm it doesn't support model's associations via methods but it will be added soon)
end

class User < RedisMapper
  property :name, :index => true
end
