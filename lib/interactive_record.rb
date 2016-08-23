require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord



  def self.table_name
    self.to_s.downcase.pluralize
  end

  #this method creates a new table name. remember we use self because we want the
  #the code to be reusable throughout any class which inherates from this
  #parent class. we are just creating the table name here not inserting or anything
  #becase we need to create it before inserting it into a query statement. These methods are
  #to be used seperately.



  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info('#{table_name}')"
     table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |column|
      column_names << column["name"]
    end
    column_names.compact
  end

#our database will output a hash because of result_as_hash set equal to true
#the sql variable is set to query statement which returns an array of hashes.
#we create an array to store our column names
#we iterate over the array of hashes and for each hash we grab the key value for key string name
#name points to the column name
#we then shove the column name into our empty array and compact it meaning it cannot be nil when added into
#our array.



  self.column_names.each do |col_name|
      attr_accessor col_name.to_sym
    end

  #over here you are assigning attr_accessors (methods) for your column names




  def initialize(options ={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end


  #the initialize method will take in a hash or regular attributes


  def table_name_for_insert
    self.class.table_name
  end

  #here you are creating an instance method which will reference the class method
  #because remember it is the classes job to create the table name but the instances job
  #to include the table name inorder to include the instance attributes into the database


    def col_names_for_insert
      self.class.column_names.delete_if  {|col| col == "id"}.join(", ")
    end

    #here we are making sure we do not insert a id into the column names which we will insert
    #because rememebr the id is given at the time of when the data is already added to the list
    #we then take the array of column names and convert it into a larger string.


    def values_for_insert
      values = []
      self.class.column_names.each do |col|
        values << "'#{send(col)}'" unless send(col) == nil
      end
      values.join(", ")
    end

  #here we are retrieving the values for each column. We are working with a hash at the moment
  #and so we retrive the the value of the colmn key by using the send keyword which will return its value.
  #we shove it into an array as strings unless the value is not available for the key


  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end


  #we create a method which allows us to create a table with the given table name along with inserting the
  #cloumn names with the values of the column names. we then as usual
  #assign the given id for the instance of the class the same id as the database instance.

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  #name is a string and therefore we select from the given table and then we include the given name






  def self.find_by(x)
    sql = "SELECT * FROM #{self.table_name} WHERE #{x.keys.join(" ")} = ?"
    values = x.values
    DB[:conn].execute(sql, values)


    #values can we a integer therefore we only convert the key as a key


  end










end
