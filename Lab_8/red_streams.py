import redis

# Підключення до локального контейнера Redis
client = redis.Redis(host='localhost', port=6379, decode_responses=True)

# 1. Додавання нових даних у потік (логіка XADD)
stream_name = 'mystream'
message_data = {'sensor-id': '9999', 'temperature': '22.5', 'status': 'active'}
message_id = client.xadd(stream_name, message_data)
print(f"Дані успішно додано до потоку. ID повідомлення: {message_id}")

# 2. Зчитування нових повідомлень зі стріму (логіка XREAD)
# Читаємо 2 останні повідомлення, починаючи з самого початку ('0')
messages = client.xread({stream_name: '0'}, count=2)

print("Отримані дані з потоку:")
for stream, data_list in messages:
    for message_id, data in data_list:
        print(f"ID: {message_id} -> Значення: {data}")