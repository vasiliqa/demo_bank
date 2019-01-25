require 'securerandom'

RSpec.describe DemoBank::Client do
  subject { DemoBank::Client.new }

  describe 'login' do
    let(:email) { 'email@example.com' }
    let(:password) { 'password' }
    let(:token) { SecureRandom.base64(64) }
    let(:token_html) { "<meta name='csrf-token' content=#{ token }" }

    before { stub_get_token_request }

    context 'with valid credentials' do
      it 'returns true' do
        stub_login_request_and_redirect(DemoBank::Client::BANK_URL)

        expect(subject.login(email, password)).to eq true
      end
    end

    context 'with invalid credentials' do
      it 'returns false' do
        stub_login_request_and_redirect("#{ DemoBank::Client::BANK_URL }/login")

        expect(subject.login(email, password)).to eq false
      end
    end

    context 'when something went wrong with API' do
      it 'raises an error' do
        stub_login_request.to_raise Faraday::TimeoutError

        expect { subject.login(email, password) }.to raise_error DemoBank::Error
      end
    end

    def stub_get_token_request
      stub_request(:get, "#{ DemoBank::Client::BANK_URL }/login")
        .to_return(status: 302, body: token_html, headers: {})
    end

    def stub_login_request
      stub_request(:post, "#{ DemoBank::Client::BANK_URL }/login")
        .with(
          body: { 'authenticity_token' => token, 'email' => email, 'password' => password },
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
        )
    end

    def stub_login_request_and_redirect(url)
      stub_login_request.to_return(
        status: 302, body: '', headers: { 'location' => url }
      )
    end
  end

  describe 'accounts' do
    context 'when logged in already' do
      it 'returns accounts list' do
        html = File.read('spec/fixtures/accounts.html')

        stub_accounts_request.to_return(status: 200, body: html, headers: {})

        result = [
          { type: :current, balance: 10_000_855, currency: 'BHD' },
          { type: :savings, balance: 534_599, currency: 'USD' }
        ]
        expect(subject.accounts).to match_array result
      end
    end

    context 'when not logged it yet' do
      it 'raises an error' do
        stub_accounts_request
          .to_return(
            status: 302, body: '',
            headers: { 'location' => "#{ DemoBank::Client::BANK_URL }/login" }
          )

        expect { subject.accounts }.to raise_error DemoBank::Error, 'Invalid credentials'
      end
    end

    context 'when something went wrong with API' do
      it 'raises an error' do
        stub_accounts_request.to_raise Faraday::TimeoutError

        expect { subject.accounts }.to raise_error DemoBank::Error
      end
    end

    def stub_accounts_request
      stub_request(:get, "#{ DemoBank::Client::BANK_URL }/accounts")
    end
  end
end
