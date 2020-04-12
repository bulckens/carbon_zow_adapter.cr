class Carbon::ZowAdapter < Carbon::Adapter
  module Alias
    alias DetailsHash = Hash(String, Hash(String, String))
  end
end
