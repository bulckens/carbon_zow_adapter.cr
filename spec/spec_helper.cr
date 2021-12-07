require "spec"
require "webmock"
require "../src/carbon_zow_adapter"
require "./support/**"

Spec.after_each do
  WebMock.reset
end
