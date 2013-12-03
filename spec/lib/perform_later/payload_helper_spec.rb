require 'spec_helper'

describe PerformLater::PayloadHelper do
  subject { PerformLater::PayloadHelper }

  describe :get_digest do
    let(:user) { User.create }
    let(:expected_digest) do
      digest = Digest::MD5.hexdigest({ :class => "DummyClass",
        :method => :some_method.to_s,
        :args => ["AR:User:#{user.id}"]
        }.to_s)
      digest = "#{digest}"
    end

    it "creates the correct payload" do
      digest = "loner:#{expected_digest}"
      args = PerformLater::ArgsParser.args_to_resque(user)
      subject.get_digest("DummyClass", :some_method, args).should == digest
    end

    it "creates the correct payload when the loner prefix is different then the default" do
      PerformLater.config.should_receive(:loner_prefix).and_return("my_loner_prefix")
      digest = "my_loner_prefix:#{expected_digest}"
      args = PerformLater::ArgsParser.args_to_resque(user)
      subject.get_digest("DummyClass", :some_method, args).should == digest
    end
  end
end