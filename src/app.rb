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
        erb :index
    end

    
end