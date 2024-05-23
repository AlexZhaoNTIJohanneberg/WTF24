class App < Sinatra::Base

    enable :sessions

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    # def order
    #     @order = db.execute('INSERT INTO orders (total_items, total_cost, user_id) VALUES (?,?,?) RETURNING id', 0, 0, session[:user])
    #     # @order = db.execute("SELECT * FROM orders JOIN users ON orders.user_id = user.id WHERE user_id = ?", session[:user_id])
    #     # @products = db.execute("SELECT * FROM orders JOIN cart_items ON orders.id = cart_items.order_id WHERE user_id = ?", session[:user_id])
    # end

    get '/' do
        session[:user_id]
        @products = db.execute('SELECT * FROM products')
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
        @products = db.execute('SELECT * FROM products').first
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
        @product_selected = db.execute('SELECT * FROM products WHERE id = ?', product_id.to_i).first
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
  
end