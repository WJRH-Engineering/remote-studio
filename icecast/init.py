#!/usr/bin/python

import sys
import redis

r = redis.Redis(host='redis', port=6379)
subscriber = r.pubsub()
subscriber.subscribe("icecast-ready")

while True:
    message = subscriber.get_message()
    if message and message['type'] == 'message':
        sys.exit(0)
