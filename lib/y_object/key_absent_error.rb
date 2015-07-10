require 'y_object/y_object_error'
class KeyAbsentError < YObjectError
  attr_reader :path
  def initialize(path)
    @path = path + []
  end
end