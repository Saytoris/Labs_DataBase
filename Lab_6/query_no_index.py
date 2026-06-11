import time
from pymongo import MongoClient

# Підключення до MongoDB
client = MongoClient("mongodb://localhost:27017")
db = client["performance_test"]
collection = db["sales"]

# Виконання запиту та вимір часу
start_time = time.time()
results = list(collection.find({"category": "Electronics"}))
end_time = time.time()

# Вивід результатів
print(f"Time taken: {end_time - start_time:.6f} seconds")
print(f"Знайдено документів: {len(results)}")