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

    get '/everydaymart/:id' do |product_id|
        @product_selected = db.execute('SELECT * FROM products WHERE id = ?', product_id.to_i).first
        @reviews = db.execute('SELECT * FROM reviews JOIN products ON reviews.product_id = products.id WHERE product_id = ?', product_id.to_i)
        erb :show
    end

    get '/everydaymart/:name' do |category|
        @category_selected = db.execute('SELECT * FROM category')
    end

    
end