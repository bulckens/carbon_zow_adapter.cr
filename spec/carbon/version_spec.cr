require "yaml"
require "../spec_helper"

describe Carbon::ZowAdapter::VERSION do
  describe "shard.yml" do
    it "matches the current version" do
      info = YAML.parse(File.read("./shard.yml"))
      version = info["version"]
      Carbon::ZowAdapter::VERSION.should eq(version)
    end
  end
end
