require 'rails_helper'

module Weather
  RSpec.describe OpenWeatherMapRequest, type: :model do
    let(:full_request_url) do
      'https://api.openweathermap.org/data/3.0/onecall?appid=OWM_TEST_TOKEN&exclude=minutely,hourly,alerts&lat=45.0&lon=-93.0&units=imperial'
    end

    it 'executes request and hyrdates objects' do
      # The following result hash is an attenuated response payload relative to a
      # "normal" OpenWeatherMap onecall response. Included here are the relevant
      # parts of the JSON for hydrating Weather::Current and Weather::ForecastDay
      # objects.
      #
      # For full response example see:
      # https://openweathermap.org/api/one-call-3#example
      result_hash = {
        lat: 45,
        lon: -93,
        current: {
          dt: 1706637713,
          temp: 37.51,
          weather: [
            {
              id: 804,
              main: 'Clouds',
              description: 'overcast clouds',
              icon: '04d'
            }
          ]
        },
        daily: [
          {
            dt: 1706637600,
            temp: {
              day: 37.51,
              min: 32.61,
              max: 40.28,
            },
            weather: [
              {
                id: 804,
                main: 'Clouds',
                description: 'overcast clouds',
                icon: '04d'
              }
            ]
          },
          {
            dt: 1706724000,
            temp: {
              day: 40.81,
              min: 33.79,
              max: 48.12,
            },
            weather: [
              {
                id: 800,
                main: 'Clear',
                description: 'clear sky',
                icon: '01d'
              }
            ]
          }
        ]
      }

      stub_request(:get, full_request_url).
          to_return(status: 200, body: result_hash.to_json, headers: {})

      request = described_class.retrieve(lat: 45.0, lon: -93.0)
      expect(request.lat).to eq(45.0)
      expect(request.lon).to eq(-93.0)
      expect(request.current.temp).to eq(37.51)
      expect(request.forecast_days.first.high_temp).to eq(40.28)
      expect(request.forecast_days.first.low_temp).to eq(32.61)
      expect(request.forecast_days.last.high_temp).to eq(48.12)
      expect(request.forecast_days.last.low_temp).to eq(33.79)
    end

    it 'raises/proxies error when rate limited' do
      result_hash = {
        cod: 429,
        message: 'Too many requests. Key quota exceeded.',
        parameters: []
      }

      stub_request(:get, full_request_url).
          to_return(status: result_hash[:cod], body: result_hash.to_json, headers: {})

      # NOTE - Faraday::TooManyRequestsError inherits Faraday::ClientError which is
      #        what we'll likely want to catch.
      expect { described_class.retrieve(lat: 45.0, lon: -93.0) }.to raise_error(Faraday::TooManyRequestsError)
    end

    it 'raises/proxies an error on server error' do
      # Unknown whether this is really an OWM 5xx error but there's nothing saying
      # it's not, so let's be prepared ;-)
      result_hash = {
        cod: 599,
        message: 'Quantum Uncertainty Error',
        parameters: []
      }

      stub_request(:get, full_request_url).
          to_return(status: result_hash[:cod], body: result_hash.to_json, headers: {})

      expect { described_class.retrieve(lat: 45.0, lon: -93.0) }.to raise_error(Faraday::ServerError)
    end

  end
end
