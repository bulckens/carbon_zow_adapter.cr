# carbon_zow_adapter.cr

A Zow Mailer API adapter for Carbon, Lucky's mail handler.

## Installation

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  carbon_zow_adapter:
    git: git@github.com:bulckens/carbon_zow_adapter.cr.git
```

Run `shards install`

## Usage

Require this shard in Lucky's shards.cr file:

```crystal
require "carbon_zow_adapter"
```

Then set it up in Lucky's email.cr initializer:

```crystal
BaseEmail.configure do |settings|
  secret = ENV["ZOW_MAILER_SECRET"]
  entity = ENV["ZOW_MAILER_ENTITY"]

  settings.adapter = Carbon::ZowAdapter.new(entity: entity, secret: secret)
end
```

If you're using an internationalization library, the current language can be
set as follows:

```crystal
settings.adapter = Carbon::ZowAdapter.new(
  entity: entity,
  secret: secret,
  language: I18n.locale || "en")
```

## Contributing

1. Fork it (<https://github.com/bulckens/carbon_zow_adapter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [wout](https://github.com/wout) - creator and maintainer
