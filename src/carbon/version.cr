class Carbon::ZowAdapter < Carbon::Adapter
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}
end
