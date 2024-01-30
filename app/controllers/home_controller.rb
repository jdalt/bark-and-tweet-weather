class HomeController < ApplicationController

  class AddressNotFound < StandardError; end

  # See Geocoder documentation for enumeration of all possible errors.
  # Geocoder::Error has multiple descendant error classes.
  # https://github.com/alexreisner/geocoder/blob/master/README.md#error-handling
  rescue_from SocketError, Timeout::Error, Geocoder::Error do
    render_error('Address lookup service unavailable.')
  end

  rescue_from AddressNotFound do
    render_error("Could not find address: \"#{params[:address]}\"")
  end

  rescue_from Faraday::Error do
    render_error('Weather service unavailable.')
  end

  private def render_error(msg)
    flash.now[:error] = msg
    render 'home/index'
  end

  def index
    if params[:address]
      @location = Geocoder.search(params[:address]).first
      raise AddressNotFound unless @location
    end

    if @location
      # NOTE: We're rounding down to 4 decimal places to both match the resolution
      # of the OpenWeather API.
      lat, lon = @location.coordinates.map{|n| n.round(4)}
      @cache_hit = true
      @weather_request = Rails.cache.fetch(@location.postal_code, expires_in: 30.minutes) do
        @cache_hit = false
        Weather::OpenWeatherMapRequest.retrieve(lat: lat, lon: lon)
      end
    end

    # We're passing @location, @weather_request, @cache_hit, and @cache_hit into the view.
    render 'home/index'
  end

end
