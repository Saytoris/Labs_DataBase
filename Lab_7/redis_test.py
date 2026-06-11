import redis

# Підключення до локального сервера Redis
client = redis.Redis(host='localhost', port=6379, decode_responses=True)

# Збільшення лічильника
client.incr('script_counter')
counter_val = client.get('script_counter')
print(f"Поточне значення лічильника: {counter_val}")

# Робота зі списком задач
client.lpush('script_tasks', 'Write report')
tasks = client.lrange('script_tasks', 0, -1)
print(f"Список задач: {tasks}")

# Публікація повідомлення (Pub/Sub)
client.publish('updates', 'Lab 7 is almost done!')
print("Повідомлення опубліковано у канал 'updates'")