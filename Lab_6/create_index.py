from pymongo import MongoClient

# Підключення до MongoDB
client = MongoClient("mongodb://localhost:27017")
db = client["performance_test"]
collection = db["sales"]

# Створення індексу
collection.create_index("category")
print("Індекс створено")