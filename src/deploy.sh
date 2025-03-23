# Поднимаем наши сервисы
docker compose up -d 

# Открываем терминал контейнера с Postgresql
docker exec -it $(docker ps | grep postgres | awk '{print $1}') bash

# Создание таблицы и вставка записей
psql -h localhost -d customers -p 5432 -U postgres-user -w

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    product_name VARCHAR(100),
    quantity INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Добавление пользователей
INSERT INTO users (name, email) VALUES ('John Doe', 'john@example.com');
INSERT INTO users (name, email) VALUES ('Jane Smith', 'jane@example.com');
INSERT INTO users (name, email) VALUES ('Alice Johnson', 'alice@example.com');
INSERT INTO users (name, email) VALUES ('Bob Brown', 'bob@example.com');

-- Добавление заказов
INSERT INTO orders (user_id, product_name, quantity) VALUES (1, 'Product A', 2);
INSERT INTO orders (user_id, product_name, quantity) VALUES (1, 'Product B', 1);
INSERT INTO orders (user_id, product_name, quantity) VALUES (2, 'Product C', 5);
INSERT INTO orders (user_id, product_name, quantity) VALUES (3, 'Product D', 3);
INSERT INTO orders (user_id, product_name, quantity) VALUES (4, 'Product E', 4); 

exit

exit 

# Создаем коннектор
curl -X PUT localhost:8083/connectors/customers_connector/config -H 'Content-Type:application/json' --data @debezium-connector.json | jq

# Проверяем статус
curl -s localhost:8083/connectors/customers_connector/status | jq

# Переходим в контейнер кафка для чтения топика
docker exec -it src-kafka-0-1 bash

cd /opt/bitnami/kafka/bin

kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic db_customers.public-.public.users --from-beginning

kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic db_customers.public-.public.orders --from-beginning

# Завершаем работу наших сервисов
docker compose down -v 
