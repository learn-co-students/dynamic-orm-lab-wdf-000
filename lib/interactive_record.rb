require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def self.get_attributes
    self.column_names.each do |col_name|
      attr_accessor col_name.to_sym
    end
  end

  def initialize(attributes = {})
    self.class.get_attributes
    attributes.each{|key, value| self.send("#{key}=", value)}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE name = '#{name}'")
  end

  def col_names_for_insert
    self.class.column_names.select{|column| column != "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      self.send("#{col_name}") == nil || values << "'#{send(col_name)}'"
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{self.class.table_name} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by(hash)
    if hash.values[0].class == String
      sql = "SELECT * FROM students WHERE #{hash.keys[0]} = '#{hash.values[0]}'"
    else
      sql =  "SELECT * FROM students WHERE #{hash.keys[0]} = #{hash.values[0]}"
    end
    DB[:conn].execute(sql)
  end

end
