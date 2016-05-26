require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'rack-flash'
require 'bcrypt'
 

DataMapper::setup(:default, "sqlite://#{Dir.pwd}/db.sqlite")
class User
  include DataMapper::Resource
  include BCrypt

  property :id, Serial, :key => true
  property :username, String, :length => 3..50
  property :email, String
  property :password, BCryptHash

	has n, :cart
end

class Product
	include DataMapper::Resource

	property :id, Serial, :key => true
	property :name, String
	property :price, Float

	has n, :cartItem
end

class Cart
	include DataMapper::Resource

	property :id, Serial, :key => true
	
	belongs_to :user
	has n, :cartItem 
end

class CartItem
	include DataMapper::Resource 
	
	property :id, Serial, :key => true
	property :quantity, Integer

	belongs_to :cart 
	belongs_to :product
end
DataMapper.finalize
DataMapper.auto_upgrade!