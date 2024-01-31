# frozen_string_literal: true

# Extra methods for HomeController Views
module HomeHelper
  def address_text(location)
    if location
      address = location.data['address']
      "#{address['house_number']} #{address['road']}\n#{address['city']}, #{address['state']}\n#{address['postcode']}"
    else
      ''
    end
  end
end
