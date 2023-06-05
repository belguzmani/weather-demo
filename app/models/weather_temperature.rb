class WeatherTemperature < ApplicationRecord
  attr_accessor :remote_loaded

  def time_until_next_sync
    ((expired_at.to_datetime - DateTime.current) * 24 * 60).to_i
  end

  class << self
    def ow_client
      OpenWeather::Client.new(api_key: Rails.application.credentials.open_weather_api_key)
    end

    def current_weather_for(zip)
      weather_temp = self.find_or_initialize_by(zip_code: zip)
      return weather_temp if weather_temp.persisted? && weather_temp.expired_at > DateTime.current

      data = ow_client.current_weather(zip: zip)
      return if data.nil?

      weather_temp.remote_loaded = true
      weather_temp.location = data.name
      weather_temp.temp = data.main.temp_f
      weather_temp.feels_like = data.main.feels_like_f
      weather_temp.temp_max = data.main.temp_max_f
      weather_temp.temp_min = data.main.temp_min_f
      weather_temp.expired_at = DateTime.current + 30.minutes
      weather_temp.save
      weather_temp
    rescue Exception => e
      return nil
    end
  end
end
