require 'rubygems'
require 'redismapper'

RedisMapper.setup(Redis.new :db => 3)
@r = RedisMapper.db

p @r.info