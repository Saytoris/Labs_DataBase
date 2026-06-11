import random
import datetime
from pymongo import MongoClient

# Підключення до MongoDB
client = MongoClient("mongodb://localhost:27020")
db = client["performance_test"]
collection = db["sales"]

# Створення тестових даних
categories = ["Electronics", "Clothing", "Books", "Home", "Sports"]

documents = [
    {
        "customer_id": random.randint(1, 1000),
        "category": random.choice(categories),
        "amount": random.uniform(5, 500),
        "timestamp": datetime.datetime(2024, random.randint(1, 12), random.randint(1, 28))
    }
    for _ in range(100000)
]

# Вставка даних у MongoDB
print("Починаю вставку 100 000 документів...")
collection.insert_many(documents)
print("Дані успішно вставлено!")