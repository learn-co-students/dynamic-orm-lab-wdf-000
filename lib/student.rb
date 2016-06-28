require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
   self.column_names.each{|col| attr_accessor col.to_sym}

  def initialize(options=nil)
   if options
      options.each{|prop,val| self.send("#{prop}=",val)}
    end
  end
end
