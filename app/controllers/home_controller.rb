# frozen_string_literal: true

# Controller for root route. Handles Geocoding and Weather request.
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

  def index
    if params[:address]
      @location = Geocoder.search(params[:address]).first
      raise AddressNotFound unless @location

      lat, lon = @location.coordinates
      @cache_hit = true
      @weather_request = Rails.cache.fetch(@location.postal_code, expires_in: 30.minutes) do
        @cache_hit = false
        Weather::OpenWeatherMapRequest.retrieve(lat:, lon:)
      end
    end

    # We're passing @location, @weather_request, and @cache_hit into the view.
    render 'home/index'
  end

  private

  def render_error(msg)
    flash.now[:error] = msg
    render 'home/index'
  end
end
