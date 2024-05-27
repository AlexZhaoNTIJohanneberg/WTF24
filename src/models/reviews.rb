module Review
    def self.all
        db.execute('SELECT * FROM review')
    end

    def self.find(review_id) 
        db.execute('SELECT * FROM products WHERE id = ?', review_id).first
    end
    
    def self.db 
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end
end