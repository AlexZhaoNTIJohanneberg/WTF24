require 'sqlite3'

def db
    if @db == nil
        @db = SQLite3::Database.new('./db/db.sqlite')
        @db.results_as_hash = true
    end
    return @db
end

def drop_tables
    db.execute('DROP TABLE IF EXISTS fruits')
end

def create_tables

    db.execute('CREATE TABLE fruits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
    )')

end

def seed_tables

    fruits = [
        {name: 'Pear', description: 'a sweet, juicy, yellow or green fruit with a round base and slightly pointed top'},
        {name: 'Apple', description: 'a round, edible fruit having a red, green, or yellow skin'},
        {name: 'Banana', description: 'a long, curved fruit with a usually yellow skin and soft, sweet flesh inside'},
        {name: 'Orange', description: 'a round, orange-colored fruit that is valued mainly for its sweet juice'}
    ]

    fruits.each do |fruit|
        db.execute('INSERT INTO fruits (name, description) VALUES (?,?)', fruit[:name], fruit[:description])
    end

end

drop_tables
create_tables
seed_tables