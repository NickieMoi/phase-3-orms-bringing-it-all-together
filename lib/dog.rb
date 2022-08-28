class Dog
    attr_accessor :id

    def initialize(attributes)
        attributes.each do |key,value|
            self.class.attr_accessor(key)
            self.send("#{key}=",value)   
        end      
    end

    def self.create_table
        query=<<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(query)
    end

    def self.drop_table
        query=<<-SQL 
        DROP TABLE IF EXISTS  dogs
        SQL

        DB[:conn].execute(query)
    end

    def save
        query=<<-SQL
        INSERT INTO dogs(name,breed)
        VALUES (?,?)
        SQL

        DB[:conn].execute(query,self.name,self.breed)
        set_id
        self
    end

    def self.create(row)
        Dog.new(row).save
    end

    def self.new_from_db(row)
        self.new(id:row[0],name:row[1],breed: row[2])
    end

    def self.all
        query=<<-SQL
        SELECT * FROM dogs
        SQL

        DB[:conn].execute(query).map{|dog| new_from_db(dog)}
    end

   def self.find_by_name(name)
        query=<<-SQL
        SELECT * FROM dogs
        WHERE name=?
        LIMIT 1
        SQL

        self.new_from_db(DB[:conn].execute(query,name).first)
   end

   def  self.find(id)
    self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id=?",id).first)
   end


    private

    def set_id
        self.id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
end
