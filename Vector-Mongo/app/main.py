# -*- coding: utf-8 -*-

import pymongo
import os
import json
from bson import json_util

conn = pymongo.MongoClient(host=os.environ.get('MONGO_HOST'), port=int(os.environ.get('MONGO_PORT')), username=os.environ.get('MONGO_USERNAME'), password=os.environ.get('MONGO_PASSWORD'))
db = conn[os.environ.get('MONGO_DBNAME')]

def lambda_handler(event, context):
    image_key = ''

    for data in event:
        image_key = data['key'].split('/')[-1]
        db.cakes.update_one({'image.converte_name': image_key}, {'$set': {data['model']: data['vector']}})

    return {
        'result': json.loads(json_util.dumps(db.cakes.find_one({'image.converte_name': image_key}))),
    }