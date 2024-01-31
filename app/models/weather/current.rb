# frozen_string_literal: true

module Weather
  # Represents a weather observation at the current datetime.
  class Current
    attr_reader :datetime, :temp

    def initialize(data)
      @datetime = Time.zone.at(data['dt']).to_datetime
      @temp = data['temp']
    end
  end
end
