import json
import requests


def hello(event, context):
    domain = event['domain']
    response = requests.get(f"https://{domain}").text

    return response
