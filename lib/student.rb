require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  self.column_names.each { |name| attr_accessor name.to_sym }

  def initialize(attributes = {})
    attributes.each { |attribute, value| self.send("#{attribute}=", value) }
  end

end
