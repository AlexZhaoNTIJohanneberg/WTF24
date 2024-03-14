require 'sqlite3'

def db
    if @db == nil
        @db = SQLite3::Database.new('./db/db.sqlite')
        @db.results_as_hash = true
    end
    return @db
end

def drop_tables
    db.execute('DROP TABLE IF EXISTS cart_items'),
    db.execute('DROP TABLE IF EXISTS categories'),
    db.execute('DROP TABLE IF EXISTS orders'),
    db.execute('DROP TABLE IF EXISTS payments'),
    db.execute('DROP TABLE IF EXISTS products'),
    db.execute('DROP TABLE IF EXISTS reviews'),
    db.execute('DROP TABLE IF EXISTS users')

end

def create_tables

    db.execute('CREATE TABLE "cart_items" (
        "id"	INTEGER,
        "quantity"	INTEGER NOT NULL,
        "cost"	INTEGER NOT NULL,
        "name"  TEXT NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
    );')

    db.execute('CREATE TABLE "categories" (
        "id"	INTEGER,
        "name"	TEXT NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
    );')

    db.execute('CREATE TABLE "orders" (
        "id"	INTEGER,
        "total_items"	INTEGER NOT NULL,
        "total_cost"	INTEGER NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
    );')

    db.execute('CREATE TABLE "payments" (
        "id"	INTEGER,
        "amount"	INTEGER NOT NULL,
        "payment_type"  TEXT NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
    );')

    db.execute('CREATE TABLE "products" (
        "id"	INTEGER,
        "name"	TEXT NOT NULL,
        "price"	TEXT NOT NULL,
        "description"	TEXT,
        "category_id"   INTEGER,
        PRIMARY KEY("id" AUTOINCREMENT)
    );')

    db.execute('CREATE TABLE "reviews" (
        "id"	INTEGER,
        "rating"	INTEGER NOT NULL,
        "comment"	TEXT NOT NULL,
        "product_id"	TEXT NOT NULL
        PRIMARY KEY("id" AUTOINCREMENT)
    );')

    db.execute('CREATE TABLE "users" (
        "id"	INTEGER,
        "first_name"	TEXT NOT NULL,
        "last_name"	TEXT NOT NULL,
        "address"	TEXT NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
    );')

end

def seed_tables

    products = [
        {name: 'blue t-shirt', price: '200', rating: '5', description: 'plain blue t-shirt made out of cotton'}
    ]


    products.each do |product|
        db.execute('INSERT INTO products (name, price, rating, description) VALUES (?,?,?,?)', product[:name], product[:price], product[:rating], product[:description])
    end

end

drop_tables
create_tables
seed_tables