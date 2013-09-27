require 'spec_helper'

class PlainObject
  attr_accessor :name
end

class PlainObjectFamili < Famili::GrandMother
  name { 'Plain Object' }
end

describe PlainObjectFamili do
  it 'should build plain object' do
    described_class.build.name.should == 'Plain Object'
  end
end