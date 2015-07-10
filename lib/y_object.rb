require 'yaml'
require 'y_object/key_absent_error'

class YObject < Hash
  attr_reader :parent

  def initialize(args = {})
    super
    self.merge!(if args[:path]
                  construct_hash(YAML.load((File.open(args[:path], 'r'){ |f| f.readlines}).join("\n")))
                elsif args[:object]
                  construct_hash(args[:object])
                else
                  {}
                end)
    @parent = args[:parent]
  end

  def add(value)
    raise ArgumentError, 'argument isn`t a hash' unless value.is_a?(Hash)
    self.merge! construct_hash(value)
  end

  def update!
    go_deep_update(self)
  end

  def ==(other)
    unless other.is_a? YObject
      to_hash == other
    else
      to_hash == other.to_hash && base_object.to_hash == other.base_object.to_hash
    end
  end

  def save(path)
    File.open(path, 'w') { |f| f.write self.to_hash.to_yaml }
  end

  def to_hash
    go_deep_to_hash(self)
  end

  def [](key)
    if key?(key)
      fetch key
    else
      raise_key_absent_error(key)
    end
  end

  def method_missing(method_name, args = nil, &block)
    if key?(method_name)
      self[method_name]
    elsif key?(method_name.to_s.tr('=','').to_sym)
      self[method_name.to_s.tr('=','').to_sym] = args
    elsif @parent && !self.respond_to?(method_name)
      raise_key_absent_error(method_name)
    else
      super(method_name, args, block)
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    self.keys.include?(method_name) || super(method_name, include_private)
  end

  def to_ary
    to_hash.to_a
  end

  def base_object
    temp = @parent || self
    temp = temp.parent while temp.parent
    temp
  end

  private

  def construct_hash(hash)
    temp = {}
    hash.each_pair { |k, v| temp[k.to_sym] = v.class != Hash ? v : YObject.new(object: v, parent: self) }
    temp
  end

  def go_deep_update(obj)
    obj.each_pair do |key, value|
      if value.class == Hash
        obj[key] = construct_hash(value)
      end
      if value.is_a? Hash
        go_deep_update(value)
      end
    end
  end

  def go_deep_to_hash(obj)
    temp = {}
    obj.each_pair{ |k, v| temp[k] = v.is_a?(Hash) ? go_deep_to_hash(v) : v }
    temp
  end

  def raise_key_absent_error(method_name)
    current = self.parent
    previous = self
    path = [method_name]
    while current
      path << current.select{|k, v| v == previous }.keys[0]
      previous = current
      current = current.parent
    end
    raise KeyAbsentError.new(path), "No such key: #{path.reverse.join('.')}"
  rescue KeyAbsentError => e
    2.times{ e.backtrace.delete_at(0) }
    e.backtrace[0] += ": #{e.message}"
    raise e
  end

end

require "y_object/version"