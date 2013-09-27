require 'spec_helper'

class HashObjectFamili < Famili::GrandMother
  last_name { 'Smith' }
  first_name { 'John' }
  full_name { "#{last_name}, #{first_name}" }

  def born(child)
    result = Hash.new
    child.bind(result) { |name, value| result[name.to_sym] = value }
    child.resolve_attributes
    child.unbind
    result
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