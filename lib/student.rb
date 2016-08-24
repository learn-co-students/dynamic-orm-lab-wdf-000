require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require 'pry'

class Student < InteractiveRecord
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def self.find_by(info_hash)
    if info_hash[:grade] != nil
      sql = <<-SQL
        SELECT * from #{table_name}
        WHERE #{column_names[2]} = ?
      SQL
      DB[:conn].execute(sql, info_hash[:grade])
    else
      sql = <<-SQL
        SELECT * from #{table_name}
        WHERE #{column_names[1]} = ?
      SQL
      DB[:conn].execute(sql, info_hash[:name])
    end
  end

end

#
