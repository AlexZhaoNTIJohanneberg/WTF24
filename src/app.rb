require_relative 'models/products'

class App < Sinatra::Base

    enable :sessions

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get '/' do
        session[:user_id]
        @products = Product.all
        @categories = db.execute('SELECT * FROM categories')
        erb :index
    end

    get '/signup' do
        erb :signup
    end

    post '/signup' do  
        username = params['username'] 
        email = params['email'] 
        password = params['password']
        hashed_password = BCrypt::Password.create(password) 
        query = 'INSERT INTO users (username, email, password, authorization) VALUES (?,?,?,?) RETURNING id'
        result = db.execute(query, username, email, hashed_password, 0).first 
        redirect "/login" 
    end

    get '/login' do
        erb :login
    end

    post '/login' do 
        username = params['username']
        cleartext_password = params['password'] 

        user = db.execute('SELECT * FROM users WHERE username = ?', username).first

        password_from_db = BCrypt::Password.new(user['password'])

        if password_from_db == cleartext_password
            session[:username] = user['username']
            session[:user_id] = user['id']
            session[:authorization] = user['authorization']
            session[:cart_items] = []
            result = db.execute('INSERT INTO cart (user_id) VALUES (?) RETURNING id', session[:user_id]).first
            redirect "/"
        else

        end
    end

    get '/logout' do
        session.destroy
        redirect "/"
    end

    get '/new' do
        erb :new
    end

    get '/cart' do
        user_id = session[:user_id]
        @items = session[:cart_items] # session
        @cart_items = db.execute('SELECT * FROM cart_items WHERE user_id = ?', user_id) #sparad i databas
        if session[:user_id] == nil
            redirect "/login"
        end
        @products = Product.all
        erb :cart
    end

    get '/category/:category' do |category|
        user_id = session[:user_id]
        @category_selected = db.execute('SELECT * FROM categories WHERE id = ?', category.to_i).first
        @category_products = db.execute('SELECT * FROM categories as cat JOIN products as p ON cat.id = p.category_id WHERE cat.id = ?', category.to_i)
        erb :category
    end
    
    get '/product/:category/:product_id' do |category, product_id|
        user_id = session[:user_id]
        @category_selected = category
        @category_products = db.execute('SELECT * FROM categories as cat JOIN products as p ON cat.id = p.category_id WHERE cat.name = ?', category.to_s)
        # @product_selected = db.execute('SELECT * FROM products WHERE id = ?', product_id.to_i).first
        @product_selected = Product.find(product_id)
        @reviews = db.execute('SELECT * FROM reviews JOIN products ON reviews.product_id = products.id WHERE product_id = ?', product_id.to_i)
        erb :show
    end
   
    post '/product/:category/:product_id' do |category, product_id|
        user_id = session[:user_id]
        if  session[:user_id] == nil
            redirect "/login"
        end

        quantity = params['quantity'].to_i
        cost = params['cost'].to_i
        product_id = params['product_id'].to_i
        user_id = session[:user_id]
        query = 'INSERT INTO cart_items (quantity, product_id, cost, user_id) VALUES (?,?,?,?) RETURNING id'
        result = db.execute(query, product_id, quantity, cost, user_id).first
        session[:cart_items] << product_id.to_i
        redirect "/cart"
    end

    post '/reviews/:product_id' do
        if session[:user_id] == nil
            redirect "/login"
        end

        rating = params['rating'].to_i
        review = params['review'].to_s
        product_id = params['product_id'].to_i
        user_id = session[:user_id].to_i
        query = 'INSERT INTO reviews (rating, review, product_id, user_id) VALUES (?,?,?,?) RETURNING id'
        result = db.execute(query, rating, review, product_id, user_id).first
        redirect back
    end

    get '/reviews/:product_id/update' do |product_id|
        @product_selected = db.execute('SELECT * FROM products WHERE id = ?', product_id).first
        @reviews = db.execute('SELECT * from reviews')
        erb :edit
    end

    post '/review/:product_id/update' do 
        rating = params['rating'].to_i
        review = params['review'].to_s
        product_id = params['product_id'].to_i
        user_id = session[:user_id].to_i
        query = 'UPDATE reviews SET rating = ?, review = ? WHERE user_id = ?'
        result = db.execute(query, rating, review, user_id).first
        redirect '/'
    end

    post '/review/:product_id/delete' do
        product_id = params['product_id'].to_i
        user_id = session[:user_id].to_i
        result = db.execute('DELETE FROM reviews WHERE user_id = ? and product_id = ?', user_id, product_id)
        redirect back
    end

    get '/product/new' do
        @products = db.execute('SELECT * FROM products')
        erb :new
    end

    post '/product/new' do
        name = params['product_name']
        cost = params['product_cost']
        description = params['product_description']
        category_id = params['category_id']
        query = 'INSERT INTO products (name, cost, description, category_id) VALUES (?,?,?,?) RETURNING ID'
        result = db.execute(query, name, cost, description, category_id).first
        redirect back
    end
  
end