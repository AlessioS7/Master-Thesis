import sys
import threading
import time
from threading import Thread
from queue import Queue
import json
import datetime
import random
from http_setup import my_session, base_url, default_response_kwargs
import time
import atexit

concurrent = len(open('measurements.csv').readlines())
lock = threading.Lock()
requests_sent = 0
responses_codes = {}


def format_data(farm_name, field_id, topic, val):
    records = []

    for i in range(1):
        key = {"topic": f"{topic}", "farm_name": f"{farm_name}", "field_id": f"{field_id}", "db": "measurements"}
        value = {"farm_id": f"{farm_name}", "zone_id": f"{field_id}", "val": f"{val}",
                 "timestamp": f"{datetime.datetime.now()}"}
        records.append({"key": key, "value": value})

    return json.dumps({"records": records})


def do_work():
    global requests_sent, responses_codes
    data = q.get()
    farm_name, field_id = data[0], data[1]
    measurements = {"temperature": data[2], "light": data[3], "humidity": data[4]}

    try:
        while True:
            for topic, val in measurements.items():
                time.sleep(random.uniform(.05, .1))
                val = "{0:.2f}".format(random.gauss(float(val), .1))
                body = format_data(farm_name, field_id, topic, val)
                url = '{}topics/{}'.format(base_url, topic)
                # print("Thread", threading.get_ident(), " POSTing", body)

                lock.acquire()
                requests_sent += 1
                lock.release()

                response = my_session.post(url, data=body, **default_response_kwargs)

                lock.acquire()
                responses_codes[response.status_code] = responses_codes.setdefault(response.status_code, 0) + 1
                lock.release()

                # print("Thread", threading.get_ident(), "response:", farm_name, field_id, topic, response.status_code,
                #      response.content)
    except:
        q.task_done()


if __name__ == '__main__':
    q = Queue(concurrent)
    for i in range(concurrent):
        t = Thread(target=do_work)
        t.daemon = True
        t.start()

    try:
        for data in open("measurements.csv"):
            q.put(data.split(","))

        while True:
            tic = time.perf_counter()
            time.sleep(10)
            toc = time.perf_counter()
            lock.acquire()
            print(f"Number of requests sent in 10 seconds {requests_sent} and status codes: {responses_codes}")
            requests_sent = 0
            responses_codes = {}
            lock.release()

        q.join()
    except (KeyboardInterrupt, SystemExit):

        sys.exit(1)
