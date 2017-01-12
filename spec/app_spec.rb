require File.expand_path '../spec_helper.rb', __FILE__
describe 'Api App' do
  before :all do
    EM.run do
      app.settings.url_repository.clear_db.callback do
        EM.stop
      end
    end
  end
  describe 'POST /' do

    before do
      @params = {
          :longUrl => Faker::Internet.url
      }
    end


    it 'returns correct content type and status ' do
      post '/', JSON.generate(@params)
      em_async_continue
      expect(last_response.status).to eq 200
      expect(last_response.header['Content-Type']).to include('application/json')

    end

    it 'returns correct json' do
      post '/', JSON.generate(@params)
      em_async_continue
      expect { JSON.parse(last_response.body) }.to_not raise_error(Exception)
      responseJson = JSON.parse(last_response.body)
      expect(responseJson).to include('url')
      url = URI.parse(responseJson['url'])
      expect(url.is_a?(URI::HTTP) && !url.host.nil?).to be true

    end

    it 'returns correct json on bad params' do
      @bad_params = {
          :veryLongUrl => Faker::Internet.url
      }
      post '/', JSON.generate(@bad_params)
      em_async_continue
      expect { JSON.parse(last_response.body) }.to_not raise_error(Exception)
      expect(JSON.parse(last_response.body)).to include('error')
    end

    it 'returns correct json on bad input json' do
      bad_json = "{'Very'Bad:: 'Json']"
      post '/', bad_json
      em_async_continue
      expect { JSON.parse(last_response.body) }.to_not raise_error(Exception)
      expect(JSON.parse(last_response.body)).to include('error')
    end


  end

  describe 'GET /:url_key' do
    it 'returns redirect on existed key' do
      original_url = Faker::Internet.url
      @params      = {
          :longUrl => original_url
      }
      post '/', JSON.generate(@params)
      em_async_continue
      response_json = JSON.parse(last_response.body)
      short_url    = URI.parse(response_json['url'])
      key          = short_url.path.delete!('/')
      rack_mock_session.reset_last_response
      get "/#{key}"
      em_async_continue
      expect(last_response.header['Location']).to eq original_url
      expect(last_response.status).to eq 301

    end

    it 'returns error on missed key' do
      key = Faker::Hipster.word #hohoho
      get "/#{key}"
      em_async_continue
      expect(last_response.status).to eq 400
      expect(last_response.body).not_to be_empty
    end
  end
end

