class CreateWeatherTemperatures < ActiveRecord::Migration[7.0]
  def change
    create_table :weather_temperatures do |t|
      t.string :zip_code
      t.string :location
      t.string :temp
      t.string :feels_like
      t.string :temp_max
      t.string :temp_min
      t.datetime :expired_at
      t.timestamps
    end
  end
end
