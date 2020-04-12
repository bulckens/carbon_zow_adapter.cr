require "yaml"
require "../spec_helper"

describe Carbon::ZowAdapter::VERSION do
  it "returns the current version" do
    Carbon::ZowAdapter::VERSION.should eq(`git describe --abbrev=0 --tags`.strip)
  end

  describe "shard.yml" do
    it "matches the current version" do
      info = YAML.parse(File.read("./shard.yml"))
      version = info["version"]
      Carbon::ZowAdapter::VERSION.should eq("v#{version}")
    end
  end
end
