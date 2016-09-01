require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  # def initialize(options={})
  #   options.each do |property, value|      #inserts the values with matching methods
  #     self.send("#{property}=", value)
  #   end
  # end
  #
  # def self.table_name
  #     self.to_s.downcase.pluralize
  # end
  #
  # def self.column_names
  #   sql = "pragma table_info('#{table_name}')"
  #   column = []
  #   DB[:connection].execute(sql).each do |row|
  #     column << row["name"]
  #   end
  #   column.compact
  # end
  #
  # self.column.each do |column_name|
  #   attr_accessor column_name.to_sym
  # end
  #
  # def col_names_for_insert
  #   self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  # end

    def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"   #gets the column names of db

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  # self.column_names.each do |col_name|   #turns column names into methods
  #   attr_accessor col_name.to_sym
  # end

  def initialize(options={})
    options.each do |property, value|      #inserts the values with matching methods
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert   #gets the table name of the specific object
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(input={})
    col_name = input.keys.first
    col_val = input.values.first
    sql = "SELECT * FROM #{self.table_name} WHERE #{col_name} = '#{col_val}'"
    DB[:conn].execute(sql)
  end
end
