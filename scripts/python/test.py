from http_setup import my_session, base_url, default_response_kwargs
import datetime
import json


def format_data(city, zone_id, topic, coordinates, val):
    records = []

    for i in range(1):
        key = {"topic": f"{topic}", "zone_id": f"{zone_id}", "db": "measurements"}
        value = {"zone_id": f"{zone_id}", "city": f"{city}", "coordinates": f"{coordinates}", "value": f"{val}",
                 "timestamp": f"{datetime.datetime.now()}"}
        records.append({"key": key, "value": value})

    return json.dumps({"records": records})


url = '{}{}'.format(base_url, "bridge/topics/signals")  # "historical/temperature/A/1")
data = format_data("San Francisco", "2", "signals", "37.757803,-122.510809", "2.222")
print(data)
with my_session.post(url, data=data, **default_response_kwargs) as response:
    print("Response:", response.status_code, response.content)
