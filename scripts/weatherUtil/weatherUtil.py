#!/usr/bin/env python3
import urllib.request
import urllib.error
import json
import os

def get_location_data():
    req = urllib.request.Request("https://ipinfo.io/json")
    with urllib.request.urlopen(req, timeout=5) as response:
        data = json.loads(response.read().decode())
        loc = data.get("loc", "0,0").split(",")
        return {
            "latitude": float(loc[0]),
            "longitude": float(loc[1]),
            "city": data.get("city", "Unknown City"),
            "country": data.get("country", "Unknown Country")
        }

loc_data = get_location_data()
locationString = f"{loc_data['city']}, {loc_data['country']}"

url = (
    f"https://api.open-meteo.com/v1/forecast"
    f"?latitude={loc_data['latitude']}&longitude={loc_data['longitude']}"
    f"&current=temperature_2m,apparent_temperature,precipitation,rain,weather_code"
    f"&daily=weather_code,temperature_2m_max,temperature_2m_min"
    f"&timezone=Europe%2FBerlin&forecast_days=1"
)

req = urllib.request.Request(url)
with urllib.request.urlopen(req, timeout=5) as response:
    weather_data = json.loads(response.read().decode())

current = weather_data.get("current", {})
daily = weather_data.get("daily", {})

current_weather_code = current.get("weather_code", 0)

WMO_CODES = {
    0: "Clear sky", 1: "Mainly clear", 2: "Partly cloudy", 3: "Overcast",
    45: "Fog", 48: "Depositing rime fog", 51: "Light drizzle", 53: "Moderate drizzle",
    55: "Dense drizzle", 61: "Slight rain", 63: "Moderate rain", 65: "Heavy rain",
    71: "Slight snow fall", 73: "Moderate snow fall", 75: "Heavy snow fall",
    77: "Snow grains", 80: "Slight rain showers", 81: "Moderate rain showers",
    82: "Violent rain showers", 85: "Slight snow showers", 86: "Heavy snow showers",
    95: "Thunderstorm", 96: "Thunderstorm with slight hail", 99: "Thunderstorm with heavy hail",
}

WEATHER_ICONS = {
    0: "\uf00d", 1: "\uf002", 2: "\uf002", 3: "\uf013", 4: "\uf062", 5: "\uf0b6", 
    6: "\uf063", 7: "\uf063", 8: "\uf063", 9: "\uf082", 10: "\uf014", 11: "\uf014", 
    12: "\uf014", 13: "\uf016", 17: "\uf01e", 18: "\uf050", 19: "\uf056", 20: "\uf01c", 
    21: "\uf019", 22: "\uf01b", 23: "\uf017", 24: "\uf017", 25: "\uf01a", 30: "\uf082", 
    31: "\uf082", 32: "\uf082", 33: "\uf082", 34: "\uf082", 35: "\uf082", 36: "\uf064", 
    37: "\uf064", 38: "\uf064", 39: "\uf064", 40: "\uf014", 41: "\uf014", 42: "\uf014", 
    43: "\uf014", 44: "\uf014", 45: "\uf014", 46: "\uf014", 47: "\uf014", 48: "\uf014", 
    49: "\uf014", 50: "\uf01c", 51: "\uf01c", 52: "\uf01c", 53: "\uf01c", 54: "\uf01c", 
    55: "\uf01c", 56: "\uf017", 57: "\uf017", 58: "\uf01c", 59: "\uf01c", 60: "\uf019", 
    61: "\uf019", 62: "\uf019", 63: "\uf019", 64: "\uf019", 65: "\uf019", 66: "\uf017", 
    67: "\uf017", 68: "\uf017", 69: "\uf017", 70: "\uf01b", 71: "\uf01b", 72: "\uf01b", 
    73: "\uf01b", 74: "\uf01b", 75: "\uf01b", 76: "\uf076", 77: "\uf01b", 78: "\uf01b", 
    79: "\uf017", 80: "\uf01a", 81: "\uf01a", 82: "\uf01a", 83: "\uf01a", 84: "\uf01a", 
    85: "\uf076", 86: "\uf076", 87: "\uf015", 88: "\uf015", 89: "\uf015", 90: "\uf01e", 
    91: "\uf01e", 92: "\uf01e", 93: "\uf01e", 94: "\uf01e", 95: "\uf01e", 96: "\uf01e", 
    97: "\uf01e", 98: "\uf01e", 99: "\uf01e",
}

aggregated_data = {
    "location": locationString,
    "description": WMO_CODES.get(current_weather_code, "No description"),
    "icon": WEATHER_ICONS.get(current_weather_code, ""),
    "temp": f"{current.get('temperature_2m', 0):.2f}",
    "feels": f"{current.get('apparent_temperature', 0):.2f}",
    "rain": str(current.get("rain", 0)),
    "precipitation": str(current.get("precipitation", 0)),
    "high": f"{daily.get('temperature_2m_max', [0])[0]:.2f}",
    "low": f"{daily.get('temperature_2m_min', [0])[0]:.2f}"
}

json_data = json.dumps(aggregated_data, indent=4)
print(json_data)

try:
    with open(os.path.expanduser("~/.cache/.weather_cache"), "w") as file:
        file.write(json_data)
except Exception as e:
    print(f"Failed to write cache: {e}")
