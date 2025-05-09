## [1.1.0] - 2024-08-12
- add ability make payments' requests more advanced by adding more params into `MonopayRuby::Invoices::AdvancedInvoice::create` method
- change private methods to protected
- modify `request_body` for additional params

## [1.0.0] - 2023-06-27

### Changed

### Breaking Change
Updated method signatures in the gem to use keyword arguments instead of named arguments.

###### Specifically
`MonopayRuby::Invoices::SimpleInvoice::new` method was affected by this change.
###### Previously
the method was called like `new("redirect/url", "webhook/url")`. Now, it should be called like `new(redirect_url: "redirect/url", webhook_url: "webhook/url")`.
#### Note
This is a breaking change and will require updating your code if you are updating to this version of the gem from an earlier version.

## [0.1.1] - 2023-06-19

- Fix typo in a `README.md` file
- Add ability to pass reference to an invoice by `reference` parameter in a `MonopayRuby::Invoices::SimpleInvoice::create` method
- Use keyword parameter of `destination` for "MonopayRuby::Invoices::SimpleInvoice::create" method

## [0.1.0] - 2023-06-18

- Initial public release
