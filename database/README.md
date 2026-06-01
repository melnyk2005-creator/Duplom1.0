# Проєкт бази даних (е-комерція)


## Угоди про найменування

- **Назви таблиць**: в однині (наприклад, `user`, `address`, `order`, `product`).
- **Системні поля** в кожній основній таблиці: `created_by`, `created_dt`, `modified_by`, `modified_dt`, `deleted_dt`.
- **ENUM-и**: замінено таблицями-довідниками (наприклад, `user_status`, `order_status`, `payment_status`, `coupon_discount_type`, `shipment_status`, `log_level`, `audit_action`) із зовнішнім ключем з основних таблиць.
- **Історія**: кожна основна таблиця має відповідну таблицю `*_history` (ті самі колонки плюс `action_description`, `effective_dt`). Тригери на INSERT/UPDATE/DELETE записують рядок у таблицю історії.
- **Відкат**: єдиний файл `rollbacks/rollback_all.sql`; виконується у зворотному порядку створення.

## Дві схеми (основна + архівна)

1. **Основна схема** (`ecommerce`): операційна база даних. Усі міграції, тригери, процедури, функції та події застосовуються тут.
2. **Архівна схема** (`ecommerce_archive`): містить м'яко видалені рядки, перенесені з основної бази, коли `deleted_dt` старіший за 1 рік.

**Створення схем**

- Запустіть `schemas/01_create_schemas_main_and_archive.sql` для створення обох баз даних.
- Застосуйте міграції V001..V012 до **ecommerce** (основна).
- Застосуйте ті самі міграції V001..V012 до **ecommerce_archive**, щоб архів мав однакову структуру таблиць (без тригерів/подій в архіві).
- Застосуйте `triggers/triggers_history_all.sql` лише до **ecommerce**.
- Створіть подію `events/event_archive_deleted_data.sql` в **ecommerce**. Вона запускається щомісяця та:
  - Копіює рядки з `ecommerce.*` до `ecommerce_archive.*`, де `deleted_dt IS NOT NULL` і `deleted_dt < NOW() - INTERVAL 1 YEAR`.
  - Видаляє ці рядки з `ecommerce`.

## Структура проєкту

```
database/
├── migrations/       # V001..V012 (довідники, основні таблиці, таблиці історії, product_unit)
├── rollbacks/        # rollback_all.sql (єдиний файл)
├── schemas/          # 01_create_schemas_main_and_archive.sql
├── procedures/       # Збережені процедури (без DELIMITER // у файлах)
├── functions/        # Функції
├── triggers/         # triggers_history_all.sql (історія по кожній таблиці)
├── events/           # event_archive_deleted_data, event_cleanup_*, event_recalculate_cart_totals
├── seed/             # seed_test_data.sql (5-10 тестових рядків на таблицю)
├── scripts/          # run_business_flow.sql (наскрізні виклики процедур)
└── README.md
```

## Основні таблиці (після міграцій)

| Група              | Таблиці |
|--------------------|---------|
| Довідники          | user_status, order_status, payment_status, coupon_discount_type, purchase_order_status, shipment_status, log_level, audit_action |
| Користувачі        | user, address |
| Категорії          | category, sub_category |
| Продукти           | brand, product, product_attribute, product_sku (price, is_serialized), product_unit (один рядок на фізичну одиницю: serial_number, manufacture_date, article, imei тощо) |
| Замовлення         | order (партиціонована по YEAR(created_dt)), order_item |
| Кошик / Бажане     | cart, cart_item, wishlist, wishlist_item |
| Платежі            | payment_method, payment, coupon, coupon_redemption |
| Склад / Доставка   | warehouse, inventory, product_unit, supplier, supplier_product, delivery_method, order_shipment (вихідне: ми відправляємо клієнту; warehouse_id, delivery_method_id), order_shipment_item, purchase_order (вхідне: ми замовляємо у постачальника; warehouse = пункт призначення, delivery_method), purchase_order_item |
| Відгуки            | review, rating |
| Логи               | audit_log, system_log |
| Історія            | user_history, address_history, ... (по одній на кожну основну таблицю) |

## Партиціонування таблиці order

Таблиця `order` партиціонована за `RANGE (YEAR(created_dt))` з партиціями p2023..p2026 та p_future (MAXVALUE). Додавайте нові річні партиції за потреби (наприклад, `ALTER TABLE \`order\` ADD PARTITION ...`).

## Процедури (без DELIMITER // у файлах)

**Утиліти**
- `sp_add_column_if_not_exists(table_name, column_name, column_definition)` — ідемпотентне додавання колонки.
- `sp_recalculate_cart_total(cart_id)` — перерахунок підсумку кошика (ціна з product_sku).
- `sp_apply_coupon(code, order_amount, @discount, @valid)` — перевірка купона та обчислення знижки.

**Продукти**
- `sp_create_product(...)` — створення продукту (категорія, підкатегорія, бренд, назва, опис тощо; OUT product_id).
- `sp_create_product_attribute(attribute_type, attribute_value, created_by, OUT product_attribute_id)` — створення атрибута (наприклад, розмір, колір) для варіантів SKU.
- `sp_create_product_sku(product_id, sku_code, price, size_attribute_id, color_attribute_id, is_serialized, created_by, OUT product_sku_id)` — створення SKU; is_serialized=1 для відстеження по product_unit.

**Серійні одиниці (один рядок на фізичний товар)**
- `sp_create_product_unit(product_sku_id, warehouse_id, serial_number, manufacture_date, article, imei, batch_number, tracking_info, created_by, OUT product_unit_id)` — створення однієї одиниці.
- `sp_receive_serialized_units(items JSON, created_by, OUT count)` — приймання кількох одиниць; JSON, наприклад: `[{"product_sku_id":1,"warehouse_id":1,"serial_number":"SN001","manufacture_date":"2024-01-15","article":"ART-001","imei":"..."}]`.
- `sp_allocate_units_to_order_item(order_item_id, warehouse_id, modified_by, OUT allocated)` — виділення доступних product_unit для рядка замовлення (встановлює order_item_id на одиницях).

**Залишки на складі (єдине джерело правди щодо кількості)**
- `sp_inventory_receive(product_sku_id, warehouse_id, quantity, created_by)` — приймання товару (вставка або збільшення існуючого рядка).
- `sp_inventory_adjust(product_sku_id, warehouse_id, delta_quantity, modified_by)` — коригування кількості (дельта може бути від'ємною).
- `sp_get_available_quantity(product_sku_id, warehouse_id, OUT available)` — повертає доступну кількість.

**Замовлення**
- `sp_create_order(user_id, shipping_address_id, created_by, order_items JSON NULL, OUT order_id)` — створення замовлення (статус = pending); опційні JSON-рядки позицій.
- `sp_order_add_item(...)` — додавання рядка; опційний перерахунок підсумку.
- `sp_order_calculate_total(order_id)` — перерахунок підсумку замовлення з order_item.
- `sp_order_set_status(order_id, order_status_id, modified_by)` — встановлення статусу замовлення.

**Платежі**
- `sp_create_payment(order_id, amount, payment_method_id, external_id, created_by, OUT payment_id)` — створення платежу (статус = pending).
- `sp_payment_set_status(payment_id, payment_status_id, modified_by, set_order_paid)` — встановлення статусу платежу; якщо completed і set_order_paid=1, переводить замовлення у статус оплаченого.

**Вихідне відвантаження: order_shipment (ми відправляємо клієнту)**
- `sp_create_shipment(order_id, warehouse_id, delivery_method_id, tracking_number, created_by, OUT order_shipment_id)` — створення відвантаження (статус = pending); склад і метод доставки опційні.
- `sp_shipment_add_item(order_shipment_id, product_id, quantity, created_by, OUT order_shipment_item_id)` — додавання позиції (без зміни залишків).
- `sp_fulfill_shipment(order_shipment_id, warehouse_id, created_by, OUT ok)` — виділення позицій замовлення зі складу (залишки або product_unit за принципом FIFO), створення order_shipment_item, встановлення статусу shipped; встановлює warehouse_id на відвантаженні, якщо не задано.
- `sp_shipment_mark_delivered(order_shipment_id, modified_by)` — встановлення delivered_date та статусу = delivered.
- `sp_can_fulfill_order(order_id, warehouse_id, OUT can_fulfill)` — перевірка можливості виконати замовлення зі складу (1 = так, 0 = ні).

**Постачальники**
- `sp_create_supplier(...)` — створення постачальника.
- `sp_supplier_link_product(supplier_id, product_id, supplier_sku, cost_price, created_by)` — прив'язка продукту до постачальника.

**Вхідне замовлення: purchase_order (ми замовляємо у постачальника)**
- `sp_create_purchase_order(supplier_id, warehouse_id, delivery_method_id, order_date, expected_delivery_date, notes, created_by, OUT purchase_order_id)` — створення замовлення на постачання (статус = draft); warehouse = куди мають надійти товари.
- `sp_purchase_order_add_item(purchase_order_id, product_sku_id, quantity, unit_cost, created_by, OUT purchase_order_item_id)` — додавання рядка.
- `sp_purchase_order_set_status(purchase_order_id, purchase_order_status_id, modified_by)` — встановлення статусу (draft/ordered/in_transit/received/cancelled).
- `sp_receive_purchase_order(purchase_order_id, created_by, OUT ok)` — позначення замовлення як отриманого та виклик sp_inventory_receive для кожного рядка до складу.

**Масове приймання (без замовлення на постачання)**
- `sp_receive_from_supplier(warehouse_id, items JSON, created_by, OUT ok)` — приймання кількох product_sku (JSON); вставка або збільшення залишків.

При запуску файлів процедур/функцій через mysql-клієнт задайте розділювач (наприклад, `delimiter $$`) перед завантаженням, якщо тіло містить крапки з комою.

## Бізнес-процеси

**1. Адмін: створити продукт → додати характеристики → створити SKU → прийняти на склад**
- **Несерійний:** `sp_create_product_sku(..., is_serialized=0, ...)`, потім `sp_inventory_receive` або `sp_receive_from_supplier`.
- **Серійний (наприклад, телефони, 10 одиниць = 10 рядків):** `sp_create_product_sku(..., is_serialized=1, ...)`, потім `sp_receive_serialized_units('[{"product_sku_id":1,"warehouse_id":1,"serial_number":"SN001","manufacture_date":"2024-01-15","article":"ART-001","imei":"123"}]', ...)` або кілька викликів `sp_create_product_unit(...)`.

**2. Користувач: замовлення → оплата → отримання (доставка)**
1. `sp_create_order(user_id, shipping_address_id, created_by, order_items JSON, @oid)` — order_items має містити `product_sku_id` для кожного рядка.
2. `sp_create_payment(...)`, потім `sp_payment_set_status(..., 2, ..., 1)` для позначення як оплаченого.
3. `sp_create_shipment(order_id, warehouse_id, delivery_method_id, tracking, created_by, @osid)` — склад і метод доставки опційні.
4. `sp_fulfill_shipment(order_shipment_id, warehouse_id, created_by, @ok)` — виділяє зі складу (залишки або серійні одиниці за FIFO), створює order_shipment_item.
5. `sp_shipment_mark_delivered(order_shipment_id, modified_by)` після доставки.

**3. Адмін: замовлення у постачальника → приймання на склад**
- **З замовленням на постачання:** `sp_create_purchase_order(supplier_id, warehouse_id, delivery_method_id, ...)`, `sp_purchase_order_add_item(...)` для кожного product_sku, `sp_purchase_order_set_status(..., 2)` після відправки замовлення, потім `sp_receive_purchase_order(purchase_order_id, ...)` після надходження товарів (приймає всі рядки на склад).
- **Без замовлення на постачання:** `sp_receive_from_supplier(warehouse_id, items JSON, ...)` або кілька викликів `sp_inventory_receive`.

## Функції

- `fn_order_total_with_discount(order_id)` — підсумок замовлення з урахуванням купонних знижок.
- `fn_product_avg_rating(product_id)` — середній рейтинг продукту з відгуків.

## Події (виконуються в основній схемі)

- **event_archive_deleted_data** — щомісяця; переміщує м'яко видалені рядки старші за 1 рік з основної бази до архіву, потім видаляє їх з основної.
- **event_cleanup_old_audit_log** — щомісяця; видаляє рядки audit_log старші за 2 роки.
- **event_cleanup_system_logs** — щотижня; видаляє рядки system_log старші за 90 днів.
- **event_recalculate_cart_totals** — щодня; перераховує підсумки кошиків.

Для роботи подій необхідно виконати `SET GLOBAL event_scheduler = ON;`.

## Порядок виконання

1. Створити схеми: `schemas/01_create_schemas_main_and_archive.sql`
2. Міграції на ecommerce: V001 .. V012
3. Міграції на ecommerce_archive: V001 .. V012 (ті самі файли)
4. Тригери на ecommerce: `triggers/triggers_history_all.sql`
5. Процедури/функції на ecommerce: `procedures/*.sql`, `functions/*.sql`
6. Події на ecommerce: `events/*.sql`

## Відкат

Запустіть `rollbacks/rollback_all.sql` на цільовій базі даних. Він видаляє події, функції, процедури, тригери, таблиці історії, основні таблиці та таблиці-довідники у правильному порядку. Зробіть резервну копію перед використанням.
