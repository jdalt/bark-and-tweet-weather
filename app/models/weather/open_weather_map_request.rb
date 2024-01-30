# frozen_string_literal: true

module Weather
  class OpenWeatherMapRequest
    attr_reader :lat
    attr_reader :lon
    attr_reader :result
    attr_reader :current
    attr_reader :forecast_days

    # Query params for the OpenWeatherMap API Requests
    def self.request_params(lat:, lon:)
      {
        lat: lat,
        lon: lon,
        appid: OPEN_WEATHER_MAP_TOKEN,
        units: 'imperial',
        exclude: 'minutely,hourly,alerts',
      }
    end

    # Configure Faraday connection to raise errors.
    def self.connection
      Faraday.new do |faraday|
        faraday.response(:raise_error)
      end
    end

    # Primary entry point for retrieving weather data from the OpenWeatherMap API.
    # Executes request and populates in memory objects.
    #
    # For OpenWeatherMap API documentation see:
    # https://openweathermap.org/api/one-call-3
    def self.retrieve(lat:, lon:)
      response = connection.get('https://api.openweathermap.org/data/3.0/onecall') do |request|
        request.params = request_params(lat: lat, lon: lon)
      end
      result = JSON.parse(response.body)
      self.new(lat: lat, lon: lon, result: result)
    end

    def initialize(lat:, lon:, result:)
      @lat = lat
      @lon = lon
      @result = result
      @current = Weather::Current.new(result['current'])
      @forecast_days = result['daily'].map { |day_data| Weather::ForecastDay.new(day_data) }
    end
  end
end
