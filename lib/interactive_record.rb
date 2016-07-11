require 'pry'
require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
	def self.table_name
		self.to_s.downcase.pluralize
	end

	def table_name_for_insert
		self.class.table_name
	end
	
	def save
		sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
		DB[:conn].execute(sql)
		@id = DB[:conn].execute("SELECT MAX(id) FROM #{table_name_for_insert}")[0][0]
	end

	def self.find_by_name(name)
		sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
		DB[:conn].execute(sql)
	end

	def self.find_by(hash)
		sql = "SELECT * FROM #{self.table_name} WHERE #{hash.keys[0]} = ? "
		DB[:conn].execute(sql, hash.values[0].class == Fixnum ?  hash.values[0] : "#{hash.values[0]}" )
	end

	def initialize(options={})
		options.each do |property, value|
			self.send("#{property}=", value)
		end
	end

	def values_for_insert
		self.class.column_names.collect do |col_name|
			"'#{send(col_name)}'" if send(col_name)
		end.compact.join(", ")
	end

	def col_names_for_insert
		tmp = self.class.column_names
		tmp.shift
		tmp.join(", ")
	end

	def self.column_names
		DB[:conn].results_as_hash = true
		sql = "pragma table_info('#{table_name}')"
		table_info = DB[:conn].execute(sql)
		table_info.map { |row| row["name"] }.compact
	end

end
