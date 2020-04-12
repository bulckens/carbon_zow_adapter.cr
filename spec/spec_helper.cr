require "spec"
require "dotenv"
require "webmock"
require "../src/carbon_zow_adapter"
require "./support/**"

Dotenv.load

Spec.after_each do
  WebMock.reset
end
