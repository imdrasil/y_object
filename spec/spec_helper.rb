require 'y_object'
require 'bundler/setup'

Bundler.setup

def spec_folder
  File.expand_path '..', __FILE__
end

def load_hash(path)
  validate_hash(YAML.load((File.open(path, 'r'){ |f| f.readlines}).join("\n")))
end

def validate_hash(hash)
  temp = {}
  hash.each_pair do |k, v|
    temp[k.to_sym] = if v.is_a? Hash
                       validate_hash(v)
                     else
                       v
                     end
  end
  temp
end

def create_simple_y_object
  YObject.new(object: {a: 1})
end