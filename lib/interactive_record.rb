require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    t_info = DB[:conn].execute("pragma table_info('#{table_name}')")
    c_names = []
    t_info.each {|row| c_names << row["name"]}
    c_names.compact
  end

  self.column_names.each {|c_name| attr_accessor c_name.to_sym}

  def initialize(options={})
    options.each {|p, v| self.send("#{p}=", v)}
  end

  def save
    sql = <<-SQL
	INSERT INTO #{self.class.table_name}
	(#{col_names_for_insert})
	VALUES (#{values_for_insert})
      SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each {|c_name| values << "'#{send(c_name)}'" if !send(c_name).nil?}
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.reject {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = '#{name}'")
  end

  def self.find_by(input)
    criteria = input.keys[0].to_s
    value = input[criteria.to_sym]
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{criteria}='#{value}'")
  end
end
