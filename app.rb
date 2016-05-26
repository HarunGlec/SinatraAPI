require 'rubygems'
require 'sinatra'
require 'bcrypt'
require 'json'

require './model'

enable:sessions
#auth kontrolü yap
before do
	if request.path=="/auth/login" then
		pass
	end
	if session[:u]==nil || session[:s]==nil then
	 	redirect '/auth/login'
	end
end

get '/auth/login' do
 	return_message = {} 	
	return_message[:code]=403
	return_message[:message]="Access denied"
	
	content_type :json
	return_message.to_json
end

post '/auth/login' do
 	return_message = {} 	
	@users = User.all
	@users.each do |user|
		if user.username==params[:username] && user.password==params[:password] then
			session[:u]=user.username
			session[:s]=BCrypt::Password.create user.username+user.password
			return_message[:code]=200
			return_message[:message]="Access granted!"
			break					
		else
			return_message[:code]=403
			return_message[:message]="Access denied"	
		end
	end
	content_type :json
	return_message.to_json
end

get '/auth/logout' do
	return_message = {}
	session[:u]=nil
	session[:s]=nil
	return_message[:code]=200
	return_message[:message]="Logged out succesfully!"
	content_type :json
	return_message.to_json
end

get '/users' do
	mess={}		
	users = User.all
	users.each do |user|
		return_message = {} 
		return_message[:id]=user.id
		return_message[:username]=user.username
		return_message[:email]=user.email

		mess["#{user.id}"]=return_message
	end
	content_type :json
	mess.to_json
end

post '/users' do
	return_message = {}
	user=User.new
	user.username=params[:username]
	user.email=params[:email]
	user.password=params[:password]
	if user.save
		return_message[:code]=200
		return_message[:message]="User created successfully!"
	else
		return_message[:code]=503
		return_message[:message]="Service Unavailable"
	end

	content_type :json
	return_message.to_json
end

get '/users/:user_id' do
	return_message={}
	user=User.get params[:user_id]
	unless user
		return_message[:code]=404
		return_message[:message]="User cannot found!"
	else
		return_message[:id]=user.id
		return_message[:username]=user.username
		return_message[:email]=user.email	
	end
	content_type :json
	return_message.to_json
end

get '/users/:user_id/carts' do
	return_message={}
	carts=Cart.all(:user_id => params[:user_id])
	unless carts
		return_message[:code]=404
		return_message[:message]="Cart cannot found!"
	else
		carts.each do |cart|
			mess={}				 
			mess[:id]=cart.id
			cartitems=CartItem.all(:cart_id => cart.id)
			products_hash={}
			cartitems.each do |cartitem|
				product_mess={}
				products=Product.first(:id => cartitem.product_id)
				product_mess[:name]=product.name
				product_mess[:price]=product.price				
				product_mess[:quantity]=cartitem.quantity
				product_hash["#{product.id}"]=product_mess
			end
			mess["products"]=products_hash
			return_message["#{cart.id}"]=mess	
		end 
	end
	content_type :json
	return_message.to_json
end

post '/users/:user_id/carts' do
	return_message={}
	cart=Cart.new
	cart.user_id=params[:user_id]
	if cart.save
		return_message[:code]=200
		return_message[:message]="Cart created successfully!"
	else
		return_message[:code]=503
		return_message[:message]="Service Unavailable"
	end

	content_type :json
	return_message.to_json
end

get '/products' do
	return_message={}
	products = Product.all
	products.each do |product|
		mess = {} 
		mess[:id]=product.id
		mess[:name]=product.name
		mess[:price]=product.price
		return_message["#{product.id}"]=mess
	end

	content_type :json, :charset => 'utf-8'
	return_message.to_json
end

post '/products' do
	return_message={}
	product=Product.new
	product.name=params[:name]
	product.price=params[:price]
	if product.save
		return_message[:code]=200
		return_message[:message]="Product created successfully!"
	else
		return_message[:code]=503
		return_message[:message]="Service Unavailable"
	end

	content_type :json
	return_message.to_json
end

get '/product/:product_id' do
	return_message={}
	product = Product.get(params[:product_id]) 
	return_message[:id]=product.id
	return_message[:name]=product.name
	return_message[:price]=product.price

	content_type :json
	return_message.to_json
end

get '/carts/:cart_id' do
	return_message={}
	cart=Cart.get(params[:cart_id])
	unless cart
		return_message[:code]=404
		return_message[:message]="Cart cannot found!"
	else
		return_message[:id]=cart.id
		cartitems=CartItem.all(:cart_id => cart.id)
		mess={}	
		cartitems.each do |cartitem|
			product_mess={}
			product=Product.get(cartitem.product_id)
			product_mess[:id]=product.id
			product_mess[:name]=product.name
			product_mess[:price]=product.price
			product_mess[:quantity]=cartitem.quantity		
			mess["#{product_id}"]=product_mess
		end
		return_message["products"]=mess
	end

	content_type :json
	return_message.to_json
end

post '/carts/:cart_id/products' do
	return_message={}
	cartitem=CartItem.new
	cartitem.cart_id=params[:cart_id]
	cartitem.product_id=params[:product_id]
	if params.has_key?("quantity")
		cartitem.quantity=params[:quantity]
	else
		cartitem.quantity=1
	end
	if cartitem.save
		return_message[:code]=200
		return_message[:message]="CartItem created successfully!"
	else
		return_message[:code]=503
		return_message[:message]="Service Unavailable"
	end
	
	content_type :json
	return_message.to_json
end

delete '/carts/:cart_id/products/:product_id' do
	return_message={}	
	cartitem = CartItem.all(:cart_id => params[:cart_id])
	cartitem = cartitem.all(:product_id => params[:product_id])
  if cartitem.destroy
    return_message[:code]=200
		return_message[:message]="CartItem deleted successfully!"
  else
		return_message[:code]=503
		return_message[:message]="Service Unavailable"
  end

	content_type :json
	return_message.to_json
end

put '/carts/:cart_id/products/:product_id' do
	return_message={}	
	cartitem = CartItem.all(:cart_id => params[:cart_id])
	cartitem = cartitem.first(:product_id => params[:product_id])
	cartitem.quantity=params[:quantity]
	if cartitem.save
		return_message[:code]=200
		return_message[:message]="CartItem updated successfully!"
	else
		return_message[:code]=503
		return_message[:message]="Service Unavailable"
	end
	
	content_type :json
	return_message.to_json
end

put '/carts/:cart_id/clean' do
	return_message={}
	cartitem=CartItem.all(:cart_id => params[:cart_id])
	if cartitem.destroy
		return_message[:code]=200
		return_message[:message]="Cart cleaned successfully!"
	else
		return_message[:code]=503
		return_message[:message]="Service Unavailable"
	end

	content_type :json
	return_message.to_json
end

