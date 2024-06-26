module Product
    def self.all
        db.execute('SELECT * FROM products')
    end

    def self.find(product_id) 
        db.execute('SELECT * FROM products WHERE id = ?', product_id).first
    end
    
    def self.db 
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end
end
