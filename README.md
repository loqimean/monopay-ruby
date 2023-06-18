# Monopay::Ruby

The "monopay-ruby" gem simplifies Monobank payment integration in Ruby and Rails applications. It provides an intuitive interface and essential functionalities for generating payment requests, verifying transactions, handling callbacks, and ensuring data integrity. With this gem, you can quickly and securely implement Monobank payments, saving development time and delivering a seamless payment experience to your users.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add "monopay-ruby"

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install "monopay-ruby"

## Usage

Add API token. There are two ways:
First - add to the initializer file:

```ruby
# config/initializers/monopay.rb
Monopay.configure do |config|
  config.api_token = "your_api_token"
end
```

The second one - add to the environment variable:

```bash
# .env
MONOPAY_API_TOKEN=your_api_token
```

### Generate payment request

```ruby
# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
  def create
    payment = Monopay::Payment.new(
      redirect_url: "https://example.com",
      webhook_url: "https://example.com/payments/webhook"
    )

    if payment.create(amount: 100, description: "Payment description",)
      # your success code processing
    else
      # your error code processing
      # flash[:error] = payment.error_messages
    end
  end
end
```

### Verify transaction

```ruby
# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhook

  def webhook
    webhook_validator = Monopay::Webhooks::Validator.new(request)

    if webhook_validator.valid?
      # your success code processing
    else
      # your error code processing
      # flash[:error] = webhook_validator.error_messages
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/loqimean/monopay-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
