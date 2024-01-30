require 'rails_helper'

RSpec.describe HomeHelper, type: :helper do
  class FakeLocation
    attr_reader :data

    def initialize(data)
      @data = data
    end
  end

  describe '#address_text' do
    it 'returns an empty string if location is nil' do
      expect(helper.address_text(nil)).to eq('')
    end

    it 'concatenates nominatim address parts into a string with newlines (fit for a textarea)' do
      data = {
        address: {
          house_number: '1600',
          road: 'Pennsylvania Avenue Northwest',
          city: 'Washington',
          state: 'District of Columbia',
          postcode: '20500'
        }
      }
      location = FakeLocation.new(data.with_indifferent_access)
      expect(helper.address_text(location)).to eq("1600 Pennsylvania Avenue Northwest\nWashington, District of Columbia\n20500")
    end
  end
end
