# DemoBank

## The assignment

- Create a new http client for the mythical "[Demo Bank](https://verify-demo-bank.herokuapp.com/)" that we have setup
- Create a public repository for the project on GitHub. When you are done, share the repository link with us
- http client should be created as a gem, we can easily install and use it.

## Grading

We feel this work sample is a great way to measure many things, only one of which is your ability to develop software. We will be looking at the following when evaluating your work sample:

- Ability to follow specific instructions
- Ability to follow existing software patterns
- Thoroughness
- Comfort working with the complete development stack (version control, test frameworks, etc...)

## Specification

We expect your library to have following methods:

- `login` - accepts `credentials` in the form of an email and a password. It returns a Boolean depending on the login result. Method should not take more than **20 seconds** to return a result.
- `accounts` - returns the list of bank accounts in the following format:

```ruby
[
  { type: :current, balance: 100, currency: 'USD' }
]
```

Balance should be represented as an integer in the smallest currency units. For example, $10 USD balance is represented as 1000 (i.e. 1000 cents).

We expect you to build a pure http client, without resorting to the use of a browser automation solution (e.g. Capybara, Puppeteer, PhantomJS, etc).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'demo_bank'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install demo_bank

## Usage

```ruby
# create a client to interact with DemoBank
client = DemoBank::Client.new

# login with you credentials
client.login(email, password)

# get accounts list
client.accounts
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vasiliqa/demo_bank.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
