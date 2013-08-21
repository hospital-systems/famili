require 'spec_helper'

class CustomInstantiatedObject
  attr :name

  def initialize(name)
    @name = name
  end
end

class CustomInstantiatedObjectFamili < Famili::Mother
  def instantiate(attributes)
    CustomInstantiatedObject.new(attributes[:name])
  end

  name { 'Custom Object' }
end

describe CustomInstantiatedObjectFamili do
  it 'should build object using instantiate method' do
    described_class.build.name.should == 'Custom Object'
  end
end