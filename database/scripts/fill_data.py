#!/usr/bin/env python3
"""
Generate and insert large volumes of test data into the ecommerce database.
Respects all FKs and unique constraints. Uses batch inserts for performance.
Run after migrations and seed (user_id=0 and lookups must exist).

Usage:
  python fill_data.py --host localhost --user root --database ecommerce
  python fill_data.py --users 100000 --orders 2000000 --batch-size 5000
  python fill_data.py --orders 10000000  # other counts use defaults

Connection: --host, --user, --password, --database (or env MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE).
"""

import argparse
import os
import random
import sys
from datetime import datetime, timedelta
from typing import Any, List, Optional, Tuple

try:
    import pymysql
except ImportError:
    print("Install: pip install pymysql", file=sys.stderr)
    sys.exit(1)


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Fill ecommerce DB with generated data")
    p.add_argument("--host", default=os.environ.get("MYSQL_HOST", "localhost"))
    p.add_argument("--user", default=os.environ.get("MYSQL_USER", "root"))
    p.add_argument("--password", default=os.environ.get("MYSQL_PASSWORD", ""))
    p.add_argument("--database", default=os.environ.get("MYSQL_DATABASE", "ecommerce"))
    p.add_argument("--port", type=int, default=int(os.environ.get("MYSQL_PORT", "3306")))
    p.add_argument("--batch-size", type=int, default=10_000, help="Rows per INSERT batch")
    # Counts (use 0 to skip that entity)
    p.add_argument("--users", type=int, default=50_000)
    p.add_argument("--addresses-per-user", type=int, default=2)
    p.add_argument("--categories", type=int, default=50)
    p.add_argument("--subcategories", type=int, default=200)
    p.add_argument("--brands", type=int, default=100)
    p.add_argument("--products", type=int, default=20_000)
    p.add_argument("--skus-per-product", type=int, default=3)
    p.add_argument("--warehouses", type=int, default=10)
    p.add_argument("--suppliers", type=int, default=50)
    p.add_argument("--orders", type=int, default=1_000_000)
    p.add_argument("--order-items-per-order", type=int, default=3)
    p.add_argument("--payments-per-order", type=int, default=1)
    p.add_argument("--shipments-per-order", type=float, default=0.9)
    p.add_argument("--purchase-orders", type=int, default=100_000)
    p.add_argument("--reviews", type=int, default=500_000)
    p.add_argument("--audit-logs", type=int, default=200_000)
    p.add_argument("--system-logs", type=int, default=100_000)
    p.add_argument("--seed", type=int, default=42, help="Random seed for reproducibility")
    return p.parse_args()


def conn(args: argparse.Namespace):
    return pymysql.connect(
        host=args.host,
        user=args.user,
        password=args.password or None,
        database=args.database,
        port=args.port,
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=False,
    )


def run_batch(cursor, sql: str, rows: List[Tuple], batch_size: int, label: str) -> int:
    total = 0
    for i in range(0, len(rows), batch_size):
        chunk = rows[i : i + batch_size]
        cursor.executemany(sql, chunk)
        total += len(chunk)
        if total % (batch_size * 10) == 0 and total > 0:
            print(f"  {label}: {total} rows...")
    return total


def fetch_ids(cursor, table: str, id_col: str = None) -> List[int]:
    tbl = table.replace("`", "")
    if id_col:
        pk = id_col
    elif table == "user":
        pk = "user_id"
    elif tbl == "order":
        tbl = "`order`"
        pk = "order_id"
    else:
        pk = f"{tbl}_id"
    cursor.execute(f"SELECT {pk} FROM {tbl} ORDER BY {pk}")
    return [r[pk] for r in cursor.fetchall()]


def fetch_product_skus(cursor) -> List[Tuple[int, int]]:
    cursor.execute("SELECT product_sku_id, product_id FROM product_sku ORDER BY product_sku_id")
    return [(r["product_sku_id"], r["product_id"]) for r in cursor.fetchall()]


def main() -> None:
    args = parse_args()
    random.seed(args.seed)

    print("Connecting...")
    conn_obj = conn(args)
    cursor = conn_obj.cursor()
    batch = args.batch_size

    def commit():
        conn_obj.commit()

    # Ensure we have user_id=0 and lookups
    cursor.execute("SELECT 1 FROM user WHERE user_id = 0")
    if not cursor.fetchone():
        print("Run seed first (user_id=0 must exist). Exiting.")
        sys.exit(1)

    # Date range for orders/shipments (spread over years to avoid partition overflow)
    base_start = datetime(2023, 1, 1)
    base_end = datetime(2026, 6, 1)

    # ----- Users -----
    existing_users = fetch_ids(cursor, "user")
    max_user = max(existing_users) if existing_users else 0
    if args.users > 0 and max_user < args.users:
        n_new = args.users - max_user
        print(f"Inserting up to {n_new} users...")
        rows = []
        for i in range(1, n_new + 1):
            uid = max_user + i
            rows.append((
                uid,
                f"gen_user_{uid}",
                f"gen_{uid}@test.com",
                "$2a$10$dummy",
                f"First{uid}",
                f"Last{uid}",
                1, 0, 0
            ))
            if len(rows) >= batch:
                cursor.executemany(
                    "INSERT IGNORE INTO user (user_id, username, email, password_hash, first_name, last_name, user_status_id, created_by, modified_by) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)",
                    rows,
                )
                print(f"  users: {len(rows)} batch")
                rows = []
        if rows:
            cursor.executemany(
                "INSERT IGNORE INTO user (user_id, username, email, password_hash, first_name, last_name, user_status_id, created_by, modified_by) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)",
                rows,
            )
        commit()
    user_ids = fetch_ids(cursor, "user")
    print(f"Users: {len(user_ids)} (min={min(user_ids)}, max={max(user_ids)})")

    # ----- Addresses -----
    cursor.execute("SELECT COUNT(*) AS c FROM address")
    addr_count = cursor.fetchone()["c"]
    target_addresses = len(user_ids) * args.addresses_per_user
    if args.addresses_per_user > 0 and addr_count < target_addresses:
        cities = ["Kyiv", "Lviv", "Odesa", "Kharkiv", "Dnipro", "Vinnytsia", "Ivano-Frankivsk", "Ternopil"]
        rows = []
        for u in user_ids:
            for a in range(args.addresses_per_user):
                city = random.choice(cities)
                rows.append((u, f"Street {u} {a}", city, f"{10000 + a}", "Ukraine", 1 if a == 0 else 0, 0, 0))
                if len(rows) >= batch:
                    cursor.executemany(
                        "INSERT IGNORE INTO address (user_id, street, city, postal_code, country, is_default, created_by, modified_by) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)",
                        rows,
                    )
                    rows = []
        if rows:
            cursor.executemany(
                "INSERT IGNORE INTO address (user_id, street, city, postal_code, country, is_default, created_by, modified_by) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)",
                rows,
            )
        commit()
    address_ids = fetch_ids(cursor, "address")
    user_to_addresses: dict = {}
    cursor.execute("SELECT address_id, user_id FROM address")
    for r in cursor.fetchall():
        user_to_addresses.setdefault(r["user_id"], []).append(r["address_id"])
    print(f"Addresses: {len(address_ids)}")

    # ----- Categories & sub_categories -----
    cat_ids = fetch_ids(cursor, "category")
    if args.categories > 0 and len(cat_ids) < args.categories:
        for i in range(len(cat_ids), args.categories):
            slug = f"cat-{i}-{random.randint(1,999999)}"
            cursor.execute(
                "INSERT IGNORE INTO category (name, slug, description, created_by, modified_by) VALUES (%s,%s,%s,0,0)",
                (f"Category {i}", slug, f"Desc {i}"),
            )
        conn_obj.commit()
        cat_ids = fetch_ids(cursor, "category")
    sub_ids = fetch_ids(cursor, "sub_category")
    if args.subcategories > 0 and len(sub_ids) < args.subcategories:
        for i in range(len(sub_ids), args.subcategories):
            parent = random.choice(cat_ids) if cat_ids else 1
            slug = f"sub-{i}-{random.randint(1,999999)}"
            cursor.execute(
                "INSERT IGNORE INTO sub_category (parent_id, name, slug, created_by, modified_by) VALUES (%s,%s,%s,0,0)",
                (parent, f"SubCategory {i}", slug),
            )
        conn_obj.commit()
        sub_ids = fetch_ids(cursor, "sub_category")
    print(f"Categories: {len(cat_ids)}, SubCategories: {len(sub_ids)}")

    # ----- Brands -----
    brand_ids = fetch_ids(cursor, "brand")
    if args.brands > 0 and len(brand_ids) < args.brands:
        for i in range(len(brand_ids), args.brands):
            slug = f"brand-{i}-{random.randint(1,999999)}"
            cursor.execute(
                "INSERT IGNORE INTO brand (name, slug, description, created_by, modified_by) VALUES (%s,%s,%s,0,0)",
                (f"Brand {i}", slug, ""),
            )
        conn_obj.commit()
        brand_ids = fetch_ids(cursor, "brand")
    print(f"Brands: {len(brand_ids)}")

    # ----- Products -----
    product_ids = fetch_ids(cursor, "product")
    if args.products > 0 and len(product_ids) < args.products:
        print(f"Inserting products (target {args.products})...")
        rows = []
        for i in range(len(product_ids), args.products):
            cid = random.choice(cat_ids) if cat_ids else None
            sid = random.choice(sub_ids) if sub_ids else None
            bid = random.choice(brand_ids) if brand_ids else None
            rows.append((
                f"Product {i}", f"Desc {i}", f"Short {i}", cid, sid, bid,
                random.randint(0, 100), None, None, None, None, 0, None, None, 0, 0
            ))
            if len(rows) >= batch:
                cursor.executemany(
                    """INSERT INTO product (name, description, short_description, category_id, sub_category_id, brand_id,
                    stock_quantity, weight_kg, length_cm, width_cm, height_cm, is_featured, meta_title, meta_description, created_by, modified_by)
                    VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                    rows,
                )
                rows = []
        if rows:
            cursor.executemany(
                """INSERT INTO product (name, description, short_description, category_id, sub_category_id, brand_id,
                stock_quantity, weight_kg, length_cm, width_cm, height_cm, is_featured, meta_title, meta_description, created_by, modified_by)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                rows,
            )
        conn_obj.commit()
        product_ids = fetch_ids(cursor, "product")
    print(f"Products: {len(product_ids)}")

    # ----- Product SKUs -----
    sku_ids = fetch_ids(cursor, "product_sku")
    target_skus = len(product_ids) * max(1, args.skus_per_product)
    if args.skus_per_product > 0 and len(sku_ids) < target_skus:
        print("Inserting product_sku...")
        rows = []
        for p in product_ids:
            for v in range(args.skus_per_product):
                sku = f"SKU-{p}-{v}-{random.randint(1000,999999)}"
                price = round(random.uniform(10, 500), 2)
                rows.append((p, sku, None, None, price, 0, 0, 0))
                if len(rows) >= batch:
                    cursor.executemany(
                        "INSERT IGNORE INTO product_sku (product_id, sku, size_attribute_id, color_attribute_id, price, is_serialized, created_by, modified_by) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)",
                        rows,
                    )
                    rows = []
        if rows:
            cursor.executemany(
                "INSERT IGNORE INTO product_sku (product_id, sku, size_attribute_id, color_attribute_id, price, is_serialized, created_by, modified_by) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)",
                rows,
            )
        conn_obj.commit()
    sku_list = fetch_product_skus(cursor)
    product_to_skus: dict = {}
    for sku_id, prod_id in sku_list:
        product_to_skus.setdefault(prod_id, []).append(sku_id)
    print(f"Product SKUs: {len(sku_list)}")

    # ----- Warehouses -----
    warehouse_ids = fetch_ids(cursor, "warehouse")
    if args.warehouses > 0 and len(warehouse_ids) < args.warehouses:
        for i in range(len(warehouse_ids), args.warehouses):
            cursor.execute(
                "INSERT INTO warehouse (name, location, address, created_by, modified_by) VALUES (%s,%s,%s,0,0)",
                (f"Warehouse {i}", f"Location {i}", f"Address {i}"),
            )
        conn_obj.commit()
        warehouse_ids = fetch_ids(cursor, "warehouse")
    print(f"Warehouses: {len(warehouse_ids)}")

    # ----- Inventory -----
    cursor.execute("SELECT COUNT(*) AS c FROM inventory")
    inv_count = cursor.fetchone()["c"]
    if len(sku_list) and len(warehouse_ids) and inv_count < len(sku_list) * len(warehouse_ids) // 2:
        print("Inserting inventory...")
        seen = set()
        rows = []
        for _ in range(min(len(sku_list) * max(1, len(warehouse_ids) // 2), 500_000)):
            sku_id, _ = random.choice(sku_list)
            wh = random.choice(warehouse_ids)
            if (sku_id, wh) in seen:
                continue
            seen.add((sku_id, wh))
            rows.append((sku_id, wh, random.randint(1, 500), 0, 0))
            if len(rows) >= batch:
                cursor.executemany(
                    "INSERT IGNORE INTO inventory (product_sku_id, warehouse_id, quantity, created_by, modified_by) VALUES (%s,%s,%s,%s,%s)",
                    rows,
                )
                rows = []
        if rows:
            cursor.executemany(
                "INSERT IGNORE INTO inventory (product_sku_id, warehouse_id, quantity, created_by, modified_by) VALUES (%s,%s,%s,%s,%s)",
                rows,
            )
        conn_obj.commit()
    print("Inventory: done")

    # ----- Suppliers & delivery_method, payment_method (use existing if any) -----
    supplier_ids = fetch_ids(cursor, "supplier")
    if args.suppliers > 0 and len(supplier_ids) < args.suppliers:
        for i in range(len(supplier_ids), args.suppliers):
            cursor.execute(
                "INSERT INTO supplier (name, contact_info, email, phone, created_by, modified_by) VALUES (%s,%s,%s,%s,0,0)",
                (f"Supplier {i}", f"contact{i}", f"sup{i}@test.com", f"+380{i}",),
            )
        conn_obj.commit()
        supplier_ids = fetch_ids(cursor, "supplier")
    cursor.execute("SELECT delivery_method_id FROM delivery_method LIMIT 1")
    dm = cursor.fetchone()
    delivery_method_id = dm["delivery_method_id"] if dm else None
    cursor.execute("SELECT payment_method_id FROM payment_method LIMIT 1")
    pm = cursor.fetchone()
    payment_method_id = pm["payment_method_id"] if pm else None
    order_status_ids = fetch_ids(cursor, "order_status")
    payment_status_ids = fetch_ids(cursor, "payment_status")
    shipment_status_ids = fetch_ids(cursor, "shipment_status")
    purchase_order_status_ids = fetch_ids(cursor, "purchase_order_status")

    # ----- Orders + order_item (batch to avoid huge memory) -----
    cursor.execute("SELECT COALESCE(MAX(order_id), 0) AS m FROM `order`")
    next_order_id = cursor.fetchone()["m"] + 1
    if args.orders <= 0:
        print("Orders: skip (--orders 0)")
    else:
        print(f"Inserting orders (target {args.orders})...")
        order_rows = []
        item_rows = []
        orders_created = 0
        # Prefetch prices for product_sku to avoid per-row SELECT
        cursor.execute("SELECT product_sku_id, price FROM product_sku")
        sku_prices = {r["product_sku_id"]: float(r["price"]) for r in cursor.fetchall()}
        for _ in range(args.orders):
            oid = next_order_id + orders_created
            uid = random.choice(user_ids)
            addrs = user_to_addresses.get(uid, address_ids)
            addr = random.choice(addrs) if addrs else random.choice(address_ids)
            dt = base_start + timedelta(
                seconds=random.randint(0, int((base_end - base_start).total_seconds()))
            )
            status = random.choice(order_status_ids)
            total = 0.0
            n_items = random.randint(1, max(1, args.order_items_per_order))
            for _ in range(n_items):
                prod_id = random.choice(product_ids)
                skus = product_to_skus.get(prod_id, [x[0] for x in sku_list if x[1] == prod_id])
                if not skus:
                    skus = [random.choice([x[0] for x in sku_list])]
                sku_id = random.choice(skus)
                qty = random.randint(1, 5)
                price = sku_prices.get(sku_id, 99.99)
                item_rows.append((oid, prod_id, sku_id, qty, price, 0, 0))
                total += price * qty
            order_rows.append((oid, uid, round(total, 2), status, addr, 0, dt, 0, dt, None))
            orders_created += 1
            if len(order_rows) >= batch:
                cursor.executemany(
                    """INSERT INTO `order` (order_id, user_id, total_amount, order_status_id, shipping_address_id, created_by, created_dt, modified_by, modified_dt, deleted_dt)
                    VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                    order_rows,
                )
                cursor.executemany(
                    """INSERT INTO order_item (order_id, product_id, product_sku_id, quantity, price, created_by, modified_by)
                    VALUES (%s,%s,%s,%s,%s,%s,%s)""",
                    item_rows,
                )
                next_order_id = oid + 1
                conn_obj.commit()
                print(f"  orders: {orders_created}...")
                order_rows = []
                item_rows = []
        if order_rows:
            cursor.executemany(
                """INSERT INTO `order` (order_id, user_id, total_amount, order_status_id, shipping_address_id, created_by, created_dt, modified_by, modified_dt, deleted_dt)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                order_rows,
            )
            cursor.executemany(
                """INSERT INTO order_item (order_id, product_id, product_sku_id, quantity, price, created_by, modified_by)
                VALUES (%s,%s,%s,%s,%s,%s,%s)""",
                item_rows,
            )
        conn_obj.commit()
        print(f"Orders: {orders_created} inserted")

    # ----- Payments -----
    if args.orders > 0 and args.payments_per_order > 0:
        cursor.execute("SELECT order_id FROM `order` ORDER BY order_id LIMIT %s", (args.orders + 1000,))
        order_ids_pay = [r["order_id"] for r in cursor.fetchall()]
        cursor.execute("SELECT COUNT(*) AS c FROM payment")
        pay_count = cursor.fetchone()["c"]
        to_add = max(0, len(order_ids_pay) * args.payments_per_order - pay_count)
        if to_add > 0:
            print(f"Inserting payments ({to_add})...")
            completed = payment_status_ids[1] if len(payment_status_ids) > 1 else 1
            rows = []
            for oid in order_ids_pay[:to_add]:
                cursor.execute("SELECT total_amount FROM `order` WHERE order_id = %s", (oid,))
                r = cursor.fetchone()
                amt = float(r["total_amount"]) if r else 0.0
                rows.append((oid, payment_method_id, amt, completed, None, 0, 0))
                if len(rows) >= batch:
                    cursor.executemany(
                        "INSERT INTO payment (order_id, payment_method_id, amount, payment_status_id, external_id, created_by, modified_by) VALUES (%s,%s,%s,%s,%s,%s,%s)",
                        rows,
                    )
                    rows = []
            if rows:
                cursor.executemany(
                    "INSERT INTO payment (order_id, payment_method_id, amount, payment_status_id, external_id, created_by, modified_by) VALUES (%s,%s,%s,%s,%s,%s,%s)",
                    rows,
                )
            conn_obj.commit()

    # ----- Order shipments -----
    if args.orders > 0 and args.shipments_per_order > 0 and warehouse_ids and delivery_method_id:
        cursor.execute("SELECT order_id FROM `order` ORDER BY order_id LIMIT %s", (int(args.orders * 1.1) + 1000,))
        order_ids_ship = [r["order_id"] for r in cursor.fetchall()]
        n_ship = int(len(order_ids_ship) * args.shipments_per_order)
        cursor.execute("SELECT COUNT(*) AS c FROM order_shipment")
        ship_count = cursor.fetchone()["c"]
        to_add = max(0, n_ship - ship_count)
        if to_add > 0:
            print(f"Inserting order_shipments ({to_add})...")
            status_shipped = shipment_status_ids[1] if len(shipment_status_ids) > 1 else 1
            rows = []
            for oid in order_ids_ship[:to_add]:
                dt = base_start + timedelta(seconds=random.randint(0, int((base_end - base_start).total_seconds())))
                rows.append((oid, random.choice(warehouse_ids), delivery_method_id, f"TRK-{oid}", None, None, status_shipped, 0, 0))
                if len(rows) >= batch:
                    cursor.executemany(
                        """INSERT INTO order_shipment (order_id, warehouse_id, delivery_method_id, tracking_number, shipped_date, delivered_date, shipment_status_id, created_by, modified_by)
                        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                        rows,
                    )
                    rows = []
            if rows:
                cursor.executemany(
                    """INSERT INTO order_shipment (order_id, warehouse_id, delivery_method_id, tracking_number, shipped_date, delivered_date, shipment_status_id, created_by, modified_by)
                    VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                    rows,
                )
            conn_obj.commit()

    # ----- Purchase orders -----
    po_ids = fetch_ids(cursor, "purchase_order")
    if args.purchase_orders > 0 and len(po_ids) < args.purchase_orders:
        print(f"Inserting purchase_orders ({args.purchase_orders})...")
        status_draft = purchase_order_status_ids[0] if purchase_order_status_ids else 1
        rows = []
        for i in range(len(po_ids), args.purchase_orders):
            dt = base_start + timedelta(days=random.randint(0, 800))
            rows.append((
                random.choice(supplier_ids), random.choice(warehouse_ids), delivery_method_id,
                status_draft, dt.date(), (dt + timedelta(days=7)).date(), None, 0, 0
            ))
            if len(rows) >= batch:
                cursor.executemany(
                    """INSERT INTO purchase_order (supplier_id, warehouse_id, delivery_method_id, purchase_order_status_id, order_date, expected_delivery_date, notes, created_by, modified_by)
                    VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                    rows,
                )
                rows = []
        if rows:
            cursor.executemany(
                """INSERT INTO purchase_order (supplier_id, warehouse_id, delivery_method_id, purchase_order_status_id, order_date, expected_delivery_date, notes, created_by, modified_by)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                rows,
            )
        conn_obj.commit()
        po_ids = fetch_ids(cursor, "purchase_order")
        # Purchase order items
        cursor.execute("SELECT purchase_order_id FROM purchase_order ORDER BY purchase_order_id")
        po_list = [r["purchase_order_id"] for r in cursor.fetchall()]
        rows = []
        for po_id in po_list:
            for _ in range(random.randint(1, 5)):
                sku_id, _ = random.choice(sku_list)
                rows.append((po_id, sku_id, random.randint(1, 100), round(random.uniform(5, 200), 2), 0, 0))
                if len(rows) >= batch:
                    cursor.executemany(
                        "INSERT INTO purchase_order_item (purchase_order_id, product_sku_id, quantity, unit_cost, created_by, modified_by) VALUES (%s,%s,%s,%s,%s,%s)",
                        rows,
                    )
                    rows = []
        if rows:
            cursor.executemany(
                "INSERT INTO purchase_order_item (purchase_order_id, product_sku_id, quantity, unit_cost, created_by, modified_by) VALUES (%s,%s,%s,%s,%s,%s)",
                rows,
            )
        conn_obj.commit()
    print("Purchase orders: done")

    # ----- Reviews -----
    cursor.execute("SELECT COUNT(*) AS c FROM review")
    rev_count = cursor.fetchone()["c"]
    if args.reviews > 0 and rev_count < args.reviews:
        print(f"Inserting reviews ({args.reviews})...")
        seen = set()
        rows = []
        while len(rows) < args.reviews:
            uid = random.choice(user_ids)
            pid = random.choice(product_ids)
            if (uid, pid) in seen:
                continue
            seen.add((uid, pid))
            rows.append((uid, pid, random.randint(1, 5), f"Comment {len(rows)}", 0, 0))
            if len(rows) >= batch:
                cursor.executemany(
                    "INSERT IGNORE INTO review (user_id, product_id, rating, comment, created_by, modified_by) VALUES (%s,%s,%s,%s,%s,%s)",
                    rows,
                )
                rows = []
        if rows:
            cursor.executemany(
                "INSERT IGNORE INTO review (user_id, product_id, rating, comment, created_by, modified_by) VALUES (%s,%s,%s,%s,%s,%s)",
                rows,
            )
        conn_obj.commit()

    # ----- Audit log -----
    cursor.execute("SELECT COUNT(*) AS c FROM audit_log")
    audit_count = cursor.fetchone()["c"]
    if args.audit_logs > 0 and audit_count < args.audit_logs:
        print(f"Inserting audit_log ({args.audit_logs})...")
        actions = [1, 2, 3]
        tables = ["user", "order", "product", "order_item", "payment"]
        rows = []
        for i in range(audit_count, args.audit_logs):
            dt = base_start + timedelta(seconds=random.randint(0, int((base_end - base_start).total_seconds())))
            rows.append((random.choice(tables), str(random.randint(1, 1000000)), random.choice(actions), None, None, 0, dt, 0, 0))
            if len(rows) >= batch:
                cursor.executemany(
                    """INSERT INTO audit_log (table_name, record_id, audit_action_id, old_values, new_values, changed_by, changed_dt, created_by, modified_by)
                    VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                    rows,
                )
                rows = []
        if rows:
            cursor.executemany(
                """INSERT INTO audit_log (table_name, record_id, audit_action_id, old_values, new_values, changed_by, changed_dt, created_by, modified_by)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                rows,
            )
        conn_obj.commit()

    # ----- System log -----
    cursor.execute("SELECT COUNT(*) AS c FROM system_log")
    sys_count = cursor.fetchone()["c"]
    if args.system_logs > 0 and sys_count < args.system_logs:
        print(f"Inserting system_log ({args.system_logs})...")
        levels = [1, 2, 3, 4]
        rows = []
        for i in range(sys_count, args.system_logs):
            rows.append((random.choice(levels), f"Log message {i}", None, "fill_data.py", 0, 0))
            if len(rows) >= batch:
                cursor.executemany(
                    "INSERT INTO system_log (log_level_id, message, context, source, created_by, modified_by) VALUES (%s,%s,%s,%s,%s,%s)",
                    rows,
                )
                rows = []
        if rows:
            cursor.executemany(
                "INSERT INTO system_log (log_level_id, message, context, source, created_by, modified_by) VALUES (%s,%s,%s,%s,%s,%s)",
                rows,
            )
        conn_obj.commit()

    print("Done.")
    cursor.close()
    conn_obj.close()


if __name__ == "__main__":
    main()
