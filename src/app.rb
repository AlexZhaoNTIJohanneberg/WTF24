class App < Sinatra::Base

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get '/everydaymart' do
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
        @error = false
        erb :login
    end

    post '/everydaymart/login' do 
        @authenticated = false
        username = params['username']
        cleartext_password = params['password'] 

        user = db.execute('SELECT * FROM users WHERE username = ?', username).first

        password_from_db = BCrypt::Password.new(user['password'])

        if password_from_db == cleartext_password 
            session[:user_id] = user['id']
            redirect "/everydaymart"
            @authenticated = true
        else
            @error = true 
            @authenticated = false
        end
    end

    get '/everydaymart/cart' do
        if @authenticated == false
            redirect "/everydaymart/login"
        end
        erb :cart
    end

    get '/everydaymart/:category' do |category|
        @category_selected = db.execute('SELECT * FROM categories WHERE id = ?', category.to_i).first
        @category_products = db.execute('SELECT * FROM categories as cat JOIN products as p ON cat.id = p.category_id WHERE cat.id = ?', category.to_i)
        erb :category
    end
    
    get '/everydaymart/:category/:product_id' do |category, product_id|
        @category_products = db.execute('SELECT * FROM categories as cat JOIN products as p ON cat.id = p.category_id WHERE cat.name = ?', category.to_s)
        @product_selected = db.execute('SELECT * FROM products WHERE id = ?', product_id.to_i).first
        @reviews = db.execute('SELECT * FROM reviews JOIN products ON reviews.product_id = products.id WHERE product_id = ?', product_id.to_i)
        erb :show
    end

    # get '/everydaymart/:id' do |product_id|
    #     @product_selected = db.execute('SELECT * FROM products WHERE id = ?', product_id.to_i).first
    #     @reviews = db.execute('SELECT * FROM reviews JOIN products ON reviews.product_id = products.id WHERE product_id = ?', product_id.to_i)
    #     erb :show
    # end

    # get '/everydaymart/:show' do |show|
    #     @prodcat_selected = db.execute('SELECT * FROM products,categories WHERE route_name = ?', show.to_s).first
    #     erb :test
    # end

    # get '/everydaymart/:show' do |show|
    #     @category_selected = db.execute('SELECT * FROM categories WHERE name = ?', category.to_s).first
    #     @product_selected = db.execute('SELECT * FROM products WHERE route_name = ?', product.to_s).first
    #     @category_products = db.execute('SELECT * FROM categories as cat JOIN products as p ON cat.id = p.category_id WHERE cat.name = ?', category.to_s)
    #     @reviews = db.execute('SELECT * FROM reviews WHERE review_id = ?', @product_selected[''])
    #     erb :show
    # end


  
end