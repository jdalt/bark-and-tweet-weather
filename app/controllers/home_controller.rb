class HomeController < ApplicationController

  def index
    if params[:address]
      @location = Geocoder.search(params[:address]).first
    end

    if @location
      # NOTE: We're rounding down to 4 decimal places to both match the resolution
      # of the OpenWeather API and significantly increase the cache hit rate.
      @lat, @lon = @location.coordinates.map{|n| n.round(4)}
      @weather_request = Weather::OpenWeatherMapRequest.retrieve(lat: @lat, lon: @lon)
    end

    # We're passing @location and @weather_request into the view.
    render 'home/index'
  end

end
