# frozen_string_literal: true

# to load all /lib files
$LOAD_PATH.push File.expand_path("lib", __dir__)

require_relative "lib/monopay-ruby/version"

Gem::Specification.new do |spec|
  spec.name = "monopay-ruby"
  spec.version = MonopayRuby::VERSION
  spec.authors = ["loqimean"]
  spec.email = ["vanuha277@gmail.com"]

  spec.summary = "The \"monopay-ruby\" gem is a powerful Ruby library designed for seamless integration with Monobank's payment system. It provides a convenient way to handle Monobank payments within Ruby and Rails applications, simplifying the process and saving you valuable development time."
  spec.description = "The \"monopay-ruby\" gem simplifies Monobank payment integration in Ruby and Rails applications. It provides an intuitive interface and essential functionalities for generating payment requests, verifying transactions, handling callbacks, and ensuring data integrity. With this gem, you can quickly and securely implement Monobank payments, saving development time and delivering a seamless payment experience to your users."
  spec.homepage = "https://github.com/loqimean/monopay-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/loqimean/monopay-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/loqimean/monopay-ruby/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # TODO: Use metal versions of gems where possible to avoid unnecessary extra
  spec.add_dependency "rest-client", "~> 2.1"
  spec.add_dependency "base64", "~> 0.1.1"
  spec.add_dependency "json", "~> 2.5"
  # spec.add_dependency "openssl", "~> 2.1"
  spec.add_dependency "money", "~> 6.13"
  spec.add_dependency "bigdecimal", "~> 3.1.9"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.14.2"
  spec.add_development_dependency "simplecov", "~> 0.22.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
