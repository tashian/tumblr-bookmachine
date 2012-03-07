require 'mongo_mapper'

MongoMapper.connection = Mongo::Connection.new('localhost', 27017, :pool_size => 5, :pool_timeout => 5)
MongoMapper.database = 'tumblr-bookmachine'
