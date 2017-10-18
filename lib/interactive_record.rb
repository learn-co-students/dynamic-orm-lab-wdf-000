require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    columns = DB[:conn].execute("PRAGMA table_info( #{table_name} )")
    columns.map do |column|
      column["name"]
    end.compact
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    names = self.class.column_names.delete_if do |name|
      name == "id"
    end
    names.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |name|
      values << "'#{send(name)}'" unless send(name) == nil
    end
    values.join(", ")
  end

  self.column_names.each { |name| attr_accessor name.to_sym}

  def initialize(attributes = {})
    attributes.each { |attribute, value| self.send("#{attribute}=", value) }
  end

  def save
    DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    DB[:conn].results_as_hash = true
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = '#{name}'")
  end

  def self.find_by(hash)
    key = hash.keys[0].to_s
    value = hash.values[0]
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{key} = '#{value}'")
  end


end