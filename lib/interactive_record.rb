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

  def initialize(options = {})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def self.find_by(attribute)
    # value = attribute_hash.values.first
    # formatted_value = value.class == Fixnum ? value : "'#{value}'"
    # sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
    # DB[:conn].execute(sql)
    hash = []
    if attribute[:grade]
      sql = <<-SQL
            SELECT * FROM #{self.table_name}
            WHERE grade = ?
            SQL
      hash = DB[:conn].execute(sql, attribute[:grade])
    elsif attribute[:name]
      sql = <<-SQL
            SELECT * FROM #{self.table_name}
            WHERE name = ?
            SQL
      hash = DB[:conn].execute(sql, attribute[:name])
    else
      sql = <<-SQL
            SELECT * FROM #{self.table_name}
            WHERE name = ? AND grade = ?
            SQL
      hash = DB[:conn].execute(sql, attribute[:name], attribute[:grade])
    end
    #sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}' AND grade = '#{grade}'"
    hash
  end

  def self.find_by_name(name)
    sql = <<-SQL
          SELECT * FROM #{self.table_name}
          WHERE name = ?
          SQL
    DB[:conn].execute(sql, name)

  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  
end