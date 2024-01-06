from string import ascii_uppercase
import random

MIN_TEMP, MAX_TEMP = 40.00, 120.00 # Fahrenheit
MIN_LIGHT, MAX_LIGHT = 10.00, 100.00 # Footcandles
MIN_HUMIDITY, MAX_HUMIDITY = 20.00, 80.00 # Percentage of humidity

FILE_NAME = "measurements.csv"
FARMS_NUMBER = 10
MIN_FIELDS_PER_FARM, MAX_FIELDS_PER_FARM = 10, 10

if __name__ == '__main__':
    c = 0

    with open(FILE_NAME, 'w') as f:
        for farm_name in ascii_uppercase:
            for i in range(1, random.randint(MIN_FIELDS_PER_FARM, MAX_FIELDS_PER_FARM) + 1):
                temp = "{0:.2f}".format(random.uniform(MIN_TEMP, MAX_TEMP))
                light = "{0:.2f}".format(random.uniform(MIN_LIGHT, MAX_LIGHT))
                humidity = "{0:.2f}".format(random.uniform(MIN_HUMIDITY, MAX_HUMIDITY))

                f.write(f"{farm_name},{i},{temp},{light},{humidity}\n")

            c += 1
            if c == FARMS_NUMBER : break

