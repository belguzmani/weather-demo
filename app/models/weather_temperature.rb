class WeatherTemperature < ApplicationRecord
  attr_accessor :remote_loaded

  def time_until_next_sync
    ((expired_at.to_datetime - DateTime.current) * 24 * 60).to_i
  end

  def update_with_open_weather(data)
    self.remote_loaded = true
    self.location = data.name
    self.temp = data.main.temp_f
    self.feels_like = data.main.feels_like_f
    self.temp_max = data.main.temp_max_f
    self.temp_min = data.main.temp_min_f
    self.expired_at = DateTime.current + 30.minutes
    self.save
  end

  class << self
    def load_from_open_weather(zip)
      ow_client = OpenWeather::Client.new(api_key: Rails.application.credentials.open_weather_api_key)
      ow_client.current_weather(zip: zip)
    end

    def current_weather_for(zip)
      weather_temp = self.find_or_initialize_by(zip_code: zip)
      return weather_temp if weather_temp.persisted? && weather_temp.expired_at > DateTime.current

      data = load_from_open_weather(zip)
      return if data.nil?

      weather_temp.update_with_open_weather(data)
      weather_temp
    rescue Exception => e
      return nil
    end
  end
end
