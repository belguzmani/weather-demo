class HomeController < ApplicationController
  helper_method :location_term

  def index
    unless location_term.blank?
      @weather_data = WeatherTemperature.current_weather_for(location_term)
    end
  end

  private

  def location_term
    params[:location]
  end
end
