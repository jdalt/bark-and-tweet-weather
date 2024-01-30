token_key = Rails.env.test? ? :test : :prod
OPEN_WEATHER_MAP_TOKEN = Rails.application.credentials.dig(:open_weather_map, token_key)
