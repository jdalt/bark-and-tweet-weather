# frozen_string_literal: true

module Weather
  class ForecastDay
    attr_reader :datetime
    attr_reader :high_temp
    attr_reader :low_temp
    attr_reader :icon

    def initialize(data)
      @datetime = Time.at(data['dt']).to_datetime
      @high_temp = data.dig('temp', 'max')
      @low_temp = data.dig('temp', 'min')
      @icon = data.dig('weather', 0, 'icon')
    end
  end
end
