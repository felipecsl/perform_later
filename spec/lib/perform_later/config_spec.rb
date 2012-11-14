require 'spec_helper'

describe PerformLater::Config do
  before(:each) { PerformLater.config.enabled = false }

  it "returns the correct default loner prefix" do
    PerformLater.config.loner_prefix.should eq("loner")
  end

  it "sets the loner prefix" do
    PerformLater.config.loner_prefix = "my_loner_test_string"
    PerformLater.config.loner_prefix.should eq("my_loner_test_string")
  end

  it "should set the perform later mode" do
    PerformLater.config.enabled?.should be_false
    PerformLater.config.enabled = true
    PerformLater.config.enabled?.should == true
  end
end