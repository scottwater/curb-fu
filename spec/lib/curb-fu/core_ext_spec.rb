require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'curb-fu/core_ext'

describe "module inclusion" do
  it "should include appropriate InstanceMethods" do
    class Tester
      include CurbFu::ObjectExtensions
    end

    Tester.new.should respond_to(:to_param_pair)
  end
end

describe String do
  it "should respond_to #to_param_pair" do
    "".should respond_to(:to_param_pair)
  end
  describe "to_param_pair" do
    it "should return itself as the value for the passed-in name" do
      "foo".to_param_pair("quux").should == "quux=foo"
    end
    it "should be CGI escaped" do
      "Whee, some 'unsafe' uri things".to_param_pair("safe").should == "safe=Whee%2C+some+%27unsafe%27+uri+things"
    end
  end
end

describe Hash do
  it "should respond to #to_param_pair" do
    {}.should respond_to(:to_param_pair)
  end
  describe "to_param_pair" do
    it "should collect its keys and values into parameter pairs, prepending the provided prefix" do
      {
        "kraplach" => "messy",
        "zebot" => 2003
      }.to_param_pair("things").should == "things[kraplach]=messy&things[zebot]=2003"
    end
    it "should handle having an array as one of its parameters" do
      result = {
        "vielleicht" => "perhaps",
        "ratings" => [5, 3, 5, 2, 4]
      }.to_param_pair("things")
      result.split('&').size.should == 6
      result.should =~ /things\[vielleicht\]=perhaps/
      result.should =~ /things\[ratings\]\[\]=5/
      result.should =~ /things\[ratings\]\[\]=3/
      result.should =~ /things\[ratings\]\[\]=5/
      result.should =~ /things\[ratings\]\[\]=2/
      result.should =~ /things\[ratings\]\[\]=4/
    end
  end
end

describe Array do
  it "should respond_to #to_param_pair" do
    [].should respond_to(:to_param_pair)
  end
  describe "to_param_pair" do
    it "should join each element, prepending a provided key prefix" do
      [1, 23, 5].to_param_pair("magic_numbers").should == ["magic_numbers[]=1", "magic_numbers[]=23", "magic_numbers[]=5"].join("&")
    end
    it "should call to_param_pair on each element, too" do
      [1, 23, {"barkley" => 5}].to_param_pair("magic_numbers").should == "magic_numbers[]=1&magic_numbers[]=23&magic_numbers[][barkley]=5"
    end
  end
end

describe Integer do
  it "should respond_to #to_param_pair" do
    1.should respond_to(:to_param_pair)
  end
  describe "to_param_pair" do
    it "should return a stringified version of itself, using the provided key" do
      5.to_param_pair("integer").should == "integer=5"
    end
  end
end
