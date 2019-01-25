module DemoBank
  class Client
    attr_accessor :connection
    BANK_URL = 'https://verify-demo-bank.herokuapp.com'.freeze

    def initialize
      @connection = Faraday.new(url: BANK_URL) do |faraday|
        faraday.request :url_encoded
        faraday.use :cookie_jar
        faraday.use Faraday::Response::RaiseError
        faraday.adapter Faraday.default_adapter
      end
    end

    # By requirements the method should  return the Boolean. I think that it is a bad idea -
    # to return false on invalid credentials and on Faraday errors,
    # so it returns a true/false value or raises an error
    def login(email, password)
      token = fetch_token(connection.get('/login').body)

      response = connection.post do |request|
        request.url '/login'
        request.body = { email: email, password: password, authenticity_token: token }
        request.options[:timeout] = 20
      end

      !redirect_to_login?(response)
    rescue Faraday::Error => e
      raise DemoBank::Error, e.message
    end

    def accounts
      response = connection.get('/accounts')

      raise DemoBank::Error, 'Invalid credentials' if redirect_to_login?(response)

      parse_accounts(response.body)
    rescue Faraday::Error => e
      raise DemoBank::Error, e.message
    end

    private

    def fetch_token(html)
      Nokogiri::HTML(html).at_css('meta[name="csrf-token"]')['content']
    end

    def parse_accounts(html)
      accounts = Nokogiri::HTML(html).css('table:last-child > tbody > tr')

      result = []
      accounts.each do |acc|
        # I suppose here that we always have digits after dot, eg 15.000.
        # In other case we need to create a dictionary for possible currencies with subunits
        type = acc.css('th').text.downcase.to_sym
        balance = acc.css('td:first-of-type').text.delete(',.').to_i
        currency = acc.css('td:last-of-type').text

        result << { type: type, balance: balance, currency: currency }
      end
      result
    end

    def redirect_to_login?(response)
      response.status == 302 && response.headers['location'] == "#{ BANK_URL }/login"
    end
  end
end
