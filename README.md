[![Actions Status](https://github.com/loqimean/monopay-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/loqimean/monopay-ruby/actions)
[![Listed on OpenSource-Heroes.com](https://opensource-heroes.com/badge-v1.svg)](https://opensource-heroes.com/r/loqimean/fake_picture)

# MonopayRuby

The "monopay-ruby" gem simplifies Monobank payment integration in Ruby and Rails applications. It provides an intuitive interface and essential functionalities for generating payment requests, verifying transactions, handling callbacks, and ensuring data integrity. With this gem, you can quickly and securely implement Monobank payments, saving development time and delivering a seamless payment experience to your users.

This gem was developed for Monobank API [https://api.monobank.ua/docs/acquiring.html](https://api.monobank.ua/docs/acquiring.html)

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add "monopay-ruby"
```

If bundler is not being used to manage dependencies, install the gem by executing the:

```ruby
gem install "monopay-ruby"
```

## Configuration

Add API token. There are two ways:
First - add to the initializer file:

```ruby
# config/initializers/monopay-ruby.rb
MonopayRuby.configure do |config|
  config.api_token = "your_api_token"
end
```

The second one - add to the environment variable:

```bash
# .env
MONOPAY_API_TOKEN=your_api_token
```

#### You can get the API token depending on the environment:

Development: [https://api.monobank.ua/](https://api.monobank.ua/)

Production: [https://fop.monobank.ua/](https://fop.monobank.ua/)

Just get the token and go to earn money! 🚀


_______________________________________________________________

Optional

You may add a minimum value to your payment:

```ruby
# config/initializers/monopay-ruby.rb
MonopayRuby.configure do |config|
  config.min_price = 1
end
```
* 0.01 UAH - it is a minimal valid value for Monobank:
  - if you use 1 as an Integer it is equal to 0.01 UAH
  - if you use BigDecimal(1) it's equal to 1 UAH

The default value is 1 (0.01 UAH)


### Generate payment request

Simple:

```ruby
# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
  def create
    payment = MonopayRuby::Invoices::SimpleInvoice.new(
      "https://example.com",
      "https://example.com/payments/webhook"
    )

    if payment.create(amount: 100, destination: "Payment description")
      # your successful code processing
    else
      # your error code processing
      # flash[:error] = payment.error_messages
    end
  end
end
```

With discount:

```ruby
# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
  def create
    payment = MonopayRuby::Invoices::SimpleInvoice.new(
      "https://example.com",
      "https://example.com/payments/webhook"
    )

    if payment.create(amount: 100, discount: 20, discount_is_fixed: true, destination: "Payment description")
      # your successful code processing
    else
      # your error code processing
      # flash[:error] = payment.error_messages
    end
  end
end
```

Options:
- discount - is an number, which represents a % of discount if discount_is_fixed: false and an amount of discount if discount_is_fixed: true
- discount_is_fixed - a Boolean which sets the type of discount:
  - ```true``` fixed amount of discount will be applied, for example a coupon
  - ```false``` discount amount will be preceded by %.
* can be Integer, Float or BigDecimal


### Verify transaction

```ruby
# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhook

  def webhook
    webhook_validator = MonopayRuby::Webhooks::Validator.new(request)

    if webhook_validator.valid?
      # your successful code processing
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

## Thanks for your support!
[<img width="100" alt="RailsJazz" src="https://avatars.githubusercontent.com/u/104008706?s=200">](https://github.com/railsjazz)
