# frozen_string_literal: true

module Weather
  # Represents a weather observation at the a current or future datetime. Includes
  # high and low temperatures.
  class ForecastDay
    attr_reader :datetime, :high_temp, :low_temp, :icon

    def initialize(data)
      @datetime = Time.zone.at(data['dt']).to_datetime
      @high_temp = data.dig('temp', 'max')
      @low_temp = data.dig('temp', 'min')
      @icon = data.dig('weather', 0, 'icon')
    end
  end
end
