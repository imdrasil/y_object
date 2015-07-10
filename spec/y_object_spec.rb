require 'rspec'
require 'spec_helper'
require 'yaml'
require 'stringio'

RSpec.describe YObject do
  subject(:empty){ YObject.new }
  subject(:simple) { create_simple_y_object}
  subject(:complex) { YObject.new(path: spec_folder + '/support/test.yaml') }

  let(:path) { spec_folder + '/support/test.yaml' }
  let(:simple_hash) { create_simple_y_object.to_hash }

  context :new do
    it 'should create object from yaml with given path' do
      expect(YObject.new(path: path, object: {a: 1})).to eq(load_hash(path))
    end

    it 'should create object from given hash if path to YAML file is not given' do
      hash = {a: 1}
      expect(YObject.new(object: hash)).to eq(hash)
    end

    it 'should add reference to parent if given' do
      temp = YObject.new
      expect(YObject.new(parent: temp).parent).to eq(temp)
    end

    it 'should make parent value nil unless that option is given' do
      expect(YObject.new.parent).to be_nil
    end

    it 'should convert all inner hashes to YObjects' do
      expect(YObject.new(object: {a: {b: 1}}).a).to be_instance_of(YObject)
    end

    it 'should correctly convert arrays' do
      expect(complex.something2.sample).to eq((1..3).to_a)
    end
  end


  context :== do
    it 'should be equal to parent object (that is given as option)' do
      hash = {a: { b: 1}}
      expect(YObject.new(object: hash)).to eq(hash)
    end

    it 'two objects with the same hashes and parents will be the same' do
      hash = {a: {b: 1}}
      other_hash = {a: {b: 1}}
      expect(YObject.new(object: hash).a).to eq(YObject.new(object: other_hash).a)
    end

    it 'should return false if objects hash same hashes but different parents' do
      hash = {a: {b: 1}}
      other_hash = {a: {a: {b: 1}}}
      expect(YObject.new(object: hash).a).to_not eq(YObject.new(object: other_hash).a.a)
    end
  end


  context :add do
    before(:each) { simple = create_simple_y_object }
    it 'should add key and value from argument to object' do
      expect(simple.add(a: 1)).to eq(simple_hash.merge({a: 1}))
    end

    it 'should raise ArgumentError if given argument is not a Hash' do
      expect{empty.add(2)}.to raise_error(ArgumentError)
    end
  end


  context :update! do
    before(:each) { simple = create_simple_y_object }

    it 'should recreate added by []= hashes to YObjects (even inners)' do
      simple[:add] = {deep: 3}
      simple.update!
      expect(simple).to eq(YObject.new(object: simple_hash.merge(add: {deep: 3})))
    end
  end


  context :to_hash do
    it 'should convert entire YObjects to plain hash' do
      hash = load_hash(path)
      expect(YObject.new(path: path).to_hash.to_a).to eq(hash.to_a)
    end
  end


  context :to_ary do
    before do
      $stdout = StringIO.new
    end
    after(:all) do
      $stdout = STDOUT
    end

    it 'should not raise exceptions while is given to "puts" method' do
      expect{puts simple}.not_to raise_error
    end

    it 'should convert to arrays same way as hash with the same data with method to_a' do
      hash = load_hash(path)
      expect(YObject.new(path: path).to_ary).to eq(hash.to_a)
    end
  end


  context 'access to attributes as methods' do
    after(:all) do
      simple = create_simple_y_object
    end
    it 'should return needed data by call path' do
      expect(complex.something.value).to eq('a')
    end

    it { expect(complex).to respond_to(:something) }

    it { expect{complex.send(:something)}.not_to raise_error }

    it 'should raise KeyAbsentError if there is no such attribute' do
      expect{complex.something.asd}.to raise_error(KeyAbsentError, 'No such key: something.asd')
    end

    it 'raised error should have array with called methods' do
      begin
        complex.something.asd
      rescue KeyAbsentError => e
        expect(e.path).to eq([:asd, :something])
      end
    end

    it 'should change method if "method=" is called' do
      expect{simple.a = 3}.to change(simple, :a).from(simple_hash[:a]).to(3)
    end
  end


  context :[] do
    it { expect(complex[:something].value).to eq('a')}

    it { expect{complex.something[:asd].to raise_error(KeyAbsentError, 'No such key: something.asd')}}

    it 'raised error should have array with called methods' do
      begin
        complex[:something].asd
      rescue KeyAbsentError => e
        expect(e.path).to eq([:asd, :something])
      end
    end

    it { expect{simple[:a]=3}.to change(simple, :a).from(1).to(3)}
  end


  context :base_object do
    it 'should return first parent of object' do
      expect(complex.something.base_object).to eq(complex.to_hash)
    end

    it 'should return same object if there is no any parent' do
      expect(complex.base_object).to eq(complex.to_hash)
    end
  end


  context :save do
    let(:temp_path) { spec_folder+'/support/temp.yaml' }
    after(:each) do
      File.delete(temp_path) if File.exists?(temp_path)
    end
    it 'should write to file same way as hash' do
      complex.save(temp_path)
      expect(complex).to eq(load_hash(temp_path))
    end
  end
end