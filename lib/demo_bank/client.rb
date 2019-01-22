module DemoBank
  class Client
    attr_accessor :cookie, :connection
    BANK_URL = 'https://verify-demo-bank.herokuapp.com'.freeze

    def initialize
      @connection = Faraday.new(url: BANK_URL) do |faraday|
        faraday.request :url_encoded
        faraday.use :cookie_jar
        faraday.options[:timeout] = 20
        faraday.use Faraday::Response::RaiseError
        faraday.adapter Faraday.default_adapter
      end

      @cookie = ''
    end

    # By requirements the method should  return the Boolean. I think that it is a bad idea -
    # to return false on invalid credentials and on Faraday errors,
    # so it returns a true/false value or raises an error
    def login(email, password)
      token = fetch_token(connection.get('/login').body)
      response = connection.post(
        '/login', email: email, password: password, authenticity_token: token
      )

      clear_cookie and return false if redirect_to_login?(response)

      add_cookie(response.headers)
      true
    rescue Faraday::Error => e
      raise DemoBank::Error, e.message
    end

    def accounts
      raise DemoBank::Error, 'You should login first' if cookie.empty?

      response = connection.get do |request|
        request.url '/accounts'
        request.headers['Cookie'] = cookie
        request.options[:timeout] = 30
      end

      clear_cookie and raise DemoBank::Error, 'Invalid credentials' if redirect_to_login?(response)

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

    def clear_cookie
      self.cookie = ''
    end

    def add_cookie(headers)
      self.cookie = headers['set-cookie'].strip.split(';')[0]
    end

    def redirect_to_login?(response)
      response.status == 302 && response.headers['location'] == "#{ BANK_URL }/login"
    end
  end
end
