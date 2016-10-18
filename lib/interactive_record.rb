require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names #Must return an array of column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info('#{table_name}')"  #runs the class method .table_name and queries with that name
    table_info = DB[:conn].execute(sql)
    table_info.collect do |column|
      column["name"]
    end
  end

  self.column_names.each do |column_name|
    attr_accessor column_name.to_sym
  end

  def values_for_insert
    self.class.column_names.collect do |column_name|
      "'#{send(column_name)}'" unless send(column_name).nil?
    end.compact.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|column| column == "id"}.join(", ")
  end

  def table_name_for_insert
    self.class.table_name
  end

  def save
    sql ="INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(options={})
    sql = "SELECT * FROM #{self.table_name} WHERE #{options.keys[0].to_s} = '#{options.values[0].to_s}'"
    DB[:conn].execute(sql)
  end

  def initialize(attributes={})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end
end
