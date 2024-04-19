class App < Sinatra::Base

    enable :sessions

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get '/everydaymart' do
        # session[:user_id]
        @products = db.execute('SELECT * FROM products')
        @categories = db.execute('SELECT * FROM categories')
        erb :index
    end

    get '/everydaymart/signup' do
        erb :signup
    end

    post '/everydaymart/signup' do  
        username = params['username'] 
        email = params['email'] 
        password = params['password']
        hashed_password = BCrypt::Password.create(password) 
        query = 'INSERT INTO users (username, email, password) VALUES (?,?,?) RETURNING id'
        result = db.execute(query, username, email, hashed_password).first 
        redirect "/everydaymart/login" 
    end

    get '/everydaymart/login' do
        erb :login
    end

    post '/everydaymart/login' do 
        username = params['username']
        cleartext_password = params['password'] 

        user = db.execute('SELECT * FROM users WHERE username = ?', username).first

        password_from_db = BCrypt::Password.new(user['password'])

        if password_from_db == cleartext_password 
            session[:user_id] = user['id']
            session[:customer] = true
            redirect "/everydaymart"
        else

        end
    end

    get '/everydaymart/logout' do
        session.destroy
        erb :logout
        redirect "/everydaymart"
    end

    get '/everydaymart/cart' do
        user_id = session[:user_id]
        if session[:customer] != true
            redirect "/everydaymart/login"
        end
        @cart_items = db.execute('SELECT * FROM cart_items Where id=?', user_id)
        erb :cart
    end

    get '/everydaymart/:category' do |category|
        @category_selected = db.execute('SELECT * FROM categories WHERE id = ?', category.to_i).first
        @category_products = db.execute('SELECT * FROM categories as cat JOIN products as p ON cat.id = p.category_id WHERE cat.id = ?', category.to_i)
        erb :category
    end
    
    get '/everydaymart/:category/:product_id' do |category, product_id|
        user_id = session[:user_id]
        @category_selected = category
        @category_products = db.execute('SELECT * FROM categories as cat JOIN products as p ON cat.id = p.category_id WHERE cat.name = ?', category.to_s)
        @product_selected = db.execute('SELECT * FROM products WHERE id = ?', product_id.to_i).first
        @reviews = db.execute('SELECT * FROM reviews JOIN products ON reviews.product_id = products.id WHERE product_id = ?', product_id.to_i)
        erb :show
    end

    post '/everydaymart/:category/:product_id' do
        id = params[@product_selected['id']]
        query = 'INSERT INTO cart_items (id) VALUES (?) RETURNING id'
        result = db.execute(query, id).first
    end
  
end