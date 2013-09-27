require 'spec_helper'

class HashObjectFamili < Famili::GrandMother
  last_name { 'Smith' }
  first_name { 'John' }
  full_name { "#{last_name}, #{first_name}" }

  def born(child)
    child.resolve_attributes(Hash.new) { |instance, name, value| instance[name.to_sym] = value }
  end
end

describe HashObjectFamili do
  it 'should build plain object' do
    hash = described_class.build
    hash[:last_name].should == 'Smith'
    hash[:first_name].should == 'John'
    hash[:full_name].should == 'Smith, John'
  end
end