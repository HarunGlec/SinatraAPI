Sinatra Basic API Implementation
--------------------------------


----------


 - Username : admin
 -  Password : test

**Auth**

 - POST /auth/login
	 - Username : string
	 - Password : string
 - GET /auth/logout

**User**

 - GET /users 
 - POST /users
	 - username: string
	 - email: string
	 - password: string
 - GET /users/{user_id}
 - GET /users/{user_id}/carts
 - POST /users/{user_id}/carts *"Create a new card"*

**Products**

 - GET /products
 - POST /products
	 - name: string
	 - price: int
 - GET /product/{product_id}

**Cart**

 - GET /carts/{cart_id}
 - POST /carts/{cart_id}/products
	 - product_id: int
	 - quantity: int (optional)
 - DELETE /carts/{cart_id}/products/{product_id}
 - PUT /carts/{cart_id}/products/{product_id}
	 - quantity: int
 - PUT /carts/{cart_id}/clean *"Clean the card"*
