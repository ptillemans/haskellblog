from pymongo import MongoClient
from pprint import pprint

user = "snamblog"
pwd = "snamblog"
host = "localhost"
url = f"mongodb://{user}:{pwd}@{host}"
print(f"URL: {url}")
client = MongoClient(url)
db = client.snamblog
pprint(db.Blog.find_one())
client.close()

