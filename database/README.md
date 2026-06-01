# Database project (e-commerce)

All comments and object names in this project use English. The project contains migration scripts, procedures, functions, triggers, and events for a MySQL database.

## Conventions

- **Table names**: singular (e.g. `user`, `address`, `order`, `product`).
- **System fields** on every main table: `created_by`, `created_dt`, `modified_by`, `modified_dt`, `deleted_dt`.
- **ENUMs**: replaced by lookup tables (e.g. `user_status`, `order_status`, `payment_status`, `coupon_discount_type`, `shipment_status`, `log_level`, `audit_action`) with FK from main tables.
- **History**: each main table has a corresponding `*_history` table (same columns plus `action_description`, `effective_dt`). Triggers on INSERT/UPDATE/DELETE write a row into the history table.
- **Rollback**: single file `rollbacks/rollback_all.sql`; run in reverse order of creation.

## Two schemas (main + archive)

1. **Main schema** (`ecommerce`): operational database. All migrations, triggers, procedures, functions, and events are applied here.
2. **Archive schema** (`ecommerce_archive`): holds soft-deleted rows moved out of main when `deleted_dt` is older than 1 year.

**Creating the schemas**

- Run `schemas/01_create_schemas_main_and_archive.sql` to create both databases.
- Apply migrations V001..V012 to **ecommerce** (main).
- Apply the same migrations V001..V012 to **ecommerce_archive** so archive has the same table structures (no triggers/events on archive).
- Apply `triggers/triggers_history_all.sql` to **ecommerce** only.
- Create the event `events/event_archive_deleted_data.sql` in **ecommerce**. It runs monthly and:
  - Copies rows from `ecommerce.*` to `ecommerce_archive.*` where `deleted_dt IS NOT NULL` and `deleted_dt < NOW() - INTERVAL 1 YEAR`.
  - Deletes those rows from `ecommerce`.

## Project structure

```
database/
├── migrations/       # V001..V012 (lookups, main tables, history tables, product_unit)
├── rollbacks/        # rollback_all.sql (single file)
├── schemas/          # 01_create_schemas_main_and_archive.sql
├── procedures/       # Stored procedures (no DELIMITER // in files)
├── functions/        # Functions
├── triggers/         # triggers_history_all.sql (history on each table)
├── events/           # event_archive_deleted_data, event_cleanup_*, event_recalculate_cart_totals
├── seed/             # seed_test_data.sql (5-10 test rows per table)
├── scripts/          # run_business_flow.sql (end-to-end procedure calls)
└── README.md
```

## Main tables (after migrations)

| Group        | Tables |
|-------------|--------|
| Lookups     | user_status, order_status, payment_status, coupon_discount_type, purchase_order_status, shipment_status, log_level, audit_action |
| Users       | user, address |
| Categories  | category, sub_category |
| Products    | brand, product, product_attribute, product_sku (price, is_serialized), product_unit (one row per physical unit: serial_number, manufacture_date, article, imei, etc.) |
| Orders      | order (partitioned by YEAR(created_dt)), order_item |
| Cart/Wish   | cart, cart_item, wishlist, wishlist_item |
| Payments    | payment_method, payment, coupon, coupon_redemption |
| Warehouse / delivery | warehouse, inventory, product_unit, supplier, supplier_product, delivery_method, order_shipment (outbound: we send to customer; warehouse_id, delivery_method_id), order_shipment_item, purchase_order (inbound: we order from supplier; warehouse = destination, delivery_method), purchase_order_item |
| Reviews     | review, rating |
| Logs        | audit_log, system_log |
| History     | user_history, address_history, ... (one per main table) |

## Order table partitioning

Table `order` is partitioned by `RANGE (YEAR(created_dt))` with partitions p2023..p2026 and p_future (MAXVALUE). Add new year partitions as needed (e.g. ALTER TABLE `order` ADD PARTITION ...).

## Procedures (no DELIMITER // in files)

**Utility**
- `sp_add_column_if_not_exists(table_name, column_name, column_definition)` – idempotent add column.
- `sp_recalculate_cart_total(cart_id)` – recalc cart total (price from product_sku).
- `sp_apply_coupon(code, order_amount, @discount, @valid)` – validate coupon and compute discount.

**Products**
- `sp_create_product(...)` – create product (category, sub_category, brand, name, description, etc.; OUT product_id).
- `sp_create_product_attribute(attribute_type, attribute_value, created_by, OUT product_attribute_id)` – create attribute (e.g. size, color) for SKU variants.
- `sp_create_product_sku(product_id, sku_code, price, size_attribute_id, color_attribute_id, is_serialized, created_by, OUT product_sku_id)` – create SKU; is_serialized=1 to track by product_unit.

**Serialized units (one row per physical item)**  
- `sp_create_product_unit(product_sku_id, warehouse_id, serial_number, manufacture_date, article, imei, batch_number, tracking_info, created_by, OUT product_unit_id)` – create one unit.  
- `sp_receive_serialized_units(items JSON, created_by, OUT count)` – receive many units; JSON e.g. [{"product_sku_id":1,"warehouse_id":1,"serial_number":"SN001","manufacture_date":"2024-01-15","article":"ART-001","imei":"..."}].  
- `sp_allocate_units_to_order_item(order_item_id, warehouse_id, modified_by, OUT allocated)` – allocate available product_units to an order line (sets order_item_id on units).

**Inventory (single source of truth for quantity)**
- `sp_inventory_receive(product_sku_id, warehouse_id, quantity, created_by)` – receive stock (insert or add to existing row).
- `sp_inventory_adjust(product_sku_id, warehouse_id, delta_quantity, modified_by)` – adjust quantity (delta can be negative).
- `sp_get_available_quantity(product_sku_id, warehouse_id, OUT available)` – return available quantity.

**Orders**
- `sp_create_order(user_id, shipping_address_id, created_by, order_items JSON NULL, OUT order_id)` – create order (status = pending); optional JSON line items.
- `sp_order_add_item(...)` – add line; optionally recalc total.
- `sp_order_calculate_total(order_id)` – recalc order total from order_item.
- `sp_order_set_status(order_id, order_status_id, modified_by)` – set order status.

**Payments**
- `sp_create_payment(order_id, amount, payment_method_id, external_id, created_by, OUT payment_id)` – create payment (status = pending).
- `sp_payment_set_status(payment_id, payment_status_id, modified_by, set_order_paid)` – set payment status; if completed and set_order_paid=1, sets order to paid.

**Outbound: order_shipment (we send to customer)**
- `sp_create_shipment(order_id, warehouse_id, delivery_method_id, tracking_number, created_by, OUT order_shipment_id)` – create order shipment (status = pending); optional warehouse and delivery method.
- `sp_shipment_add_item(order_shipment_id, product_id, quantity, created_by, OUT order_shipment_item_id)` – add item (no inventory change).
- `sp_fulfill_shipment(order_shipment_id, warehouse_id, created_by, OUT ok)` – allocate order items from warehouse (inventory or product_unit FIFO), create order_shipment_item, set shipped; sets warehouse_id on order_shipment if not set.
- `sp_shipment_mark_delivered(order_shipment_id, modified_by)` – set delivered_date and status = delivered.
- `sp_can_fulfill_order(order_id, warehouse_id, OUT can_fulfill)` – check if order can be fulfilled from warehouse (1 = yes, 0 = no).

**Suppliers**
- `sp_create_supplier(...)` – create supplier.
- `sp_supplier_link_product(supplier_id, product_id, supplier_sku, cost_price, created_by)` – link product to supplier.

**Inbound: purchase_order (we order from supplier)**
- `sp_create_purchase_order(supplier_id, warehouse_id, delivery_method_id, order_date, expected_delivery_date, notes, created_by, OUT purchase_order_id)` – create PO (status = draft); warehouse = where goods should arrive.
- `sp_purchase_order_add_item(purchase_order_id, product_sku_id, quantity, unit_cost, created_by, OUT purchase_order_item_id)` – add line.
- `sp_purchase_order_set_status(purchase_order_id, purchase_order_status_id, modified_by)` – set status (draft/ordered/in_transit/received/cancelled).
- `sp_receive_purchase_order(purchase_order_id, created_by, OUT ok)` – mark PO received and call sp_inventory_receive for each line to warehouse.

**Bulk receive (no PO)**  
- `sp_receive_from_supplier(warehouse_id, items JSON, created_by, OUT ok)` – receive multiple product_sku quantities (JSON); insert or add to inventory.

When running procedure/function files from the mysql client, set a delimiter (e.g. `delimiter $$`) before sourcing if the body contains semicolons.

## Business flows

**1. Admin: create product → add characteristics → create SKU → receive on warehouse**  
- **Non-serialized:** `sp_create_product_sku(..., is_serialized=0, ...)` then `sp_inventory_receive` or `sp_receive_from_supplier`.  
- **Serialized (e.g. phones, 10 units = 10 rows):** `sp_create_product_sku(..., is_serialized=1, ...)` then `sp_receive_serialized_units('[{"product_sku_id":1,"warehouse_id":1,"serial_number":"SN001","manufacture_date":"2024-01-15","article":"ART-001","imei":"123"}]', ...)` or multiple `sp_create_product_unit(...)`.

**2. User: order → pay → receive (delivery)**  
1. `sp_create_order(user_id, shipping_address_id, created_by, order_items JSON, @oid)` — order_items must include `product_sku_id` per line.  
2. `sp_create_payment(...)` then `sp_payment_set_status(..., 2, ..., 1)` to mark paid.  
3. `sp_create_shipment(order_id, warehouse_id, delivery_method_id, tracking, created_by, @osid)` — optional warehouse and delivery method.  
4. `sp_fulfill_shipment(order_shipment_id, warehouse_id, created_by, @ok)` — allocates from warehouse (inventory or serialized units FIFO), creates order_shipment_item.  
5. `sp_shipment_mark_delivered(order_shipment_id, modified_by)` when delivered.

**3. Admin: order from supplier → receive to warehouse**  
- **With purchase order:** `sp_create_purchase_order(supplier_id, warehouse_id, delivery_method_id, ...)`, `sp_purchase_order_add_item(...)` per product_sku, `sp_purchase_order_set_status(..., 2)` when ordered, then `sp_receive_purchase_order(purchase_order_id, ...)` when goods arrive (receives all lines to warehouse).  
- **Without PO:** `sp_receive_from_supplier(warehouse_id, items JSON, ...)` or multiple `sp_inventory_receive` calls.

## Functions

- `fn_order_total_with_discount(order_id)` – order total minus coupon discounts.
- `fn_product_avg_rating(product_id)` – average rating from review.

## Events (run in main schema)

- **event_archive_deleted_data** – monthly; move soft-deleted rows older than 1 year from main to archive, then delete from main.
- **event_cleanup_old_audit_log** – monthly; delete audit_log rows older than 2 years.
- **event_cleanup_system_logs** – weekly; delete system_log rows older than 90 days.
- **event_recalculate_cart_totals** – daily; recalc cart totals.

Require `SET GLOBAL event_scheduler = ON;` for events to run.

## Execution order

1. Create schemas: `schemas/01_create_schemas_main_and_archive.sql`
2. Migrations on ecommerce: V001 .. V012
3. Migrations on ecommerce_archive: V001 .. V012 (same files)
4. Triggers on ecommerce: `triggers/triggers_history_all.sql`
5. Procedures/functions on ecommerce: procedures/*.sql, functions/*.sql
6. Events on ecommerce: events/*.sql

## Rollback

Run `rollbacks/rollback_all.sql` on the target database. It drops events, functions, procedures, triggers, history tables, main tables, and lookup tables in the correct order. Backup before use.
