# frozen_string_literal: true

module Weather
  class Current
    attr_reader :datetime
    attr_reader :temp

    def initialize(data)
      @datetime = Time.at(data['dt']).to_datetime
      @temp = data['temp']
    end
  end
end
