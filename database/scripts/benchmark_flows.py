#!/usr/bin/env python3
"""
Benchmark business flows: measure execution time and capture EXPLAIN plans.
Compares performance with foreign_key_checks ON vs OFF for write flows.
Run on DB with ~50k records and again with ~5M records to compare scale.

Usage:
  python benchmark_flows.py --host localhost --user root --database ecommerce
  python benchmark_flows.py --scale 50k --runs 5 --fk both --output results.json
  python benchmark_flows.py --scale 5m --runs 3
"""

import argparse
import json
import os
import sys
import time
from contextlib import contextmanager
from typing import Any, Callable, Dict, List, Optional, Tuple

try:
    import pymysql
except ImportError:
    print("Install: pip install pymysql", file=sys.stderr)
    sys.exit(1)


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Benchmark ecommerce flows (time + EXPLAIN)")
    p.add_argument("--host", default=os.environ.get("MYSQL_HOST", "database.ctey8scg6zng.us-east-2.rds.amazonaws.com"))
    p.add_argument("--user", default=os.environ.get("MYSQL_USER", "admin"))
    p.add_argument("--password", default=os.environ.get("MYSQL_PASSWORD", "Fb62RJRRO4ryqlgfSKM7"))
    p.add_argument("--database", default=os.environ.get("MYSQL_DATABASE", "ecommerce"))
    p.add_argument("--port", type=int, default=int(os.environ.get("MYSQL_PORT", "3306")))
    p.add_argument("--scale", default="auto", help="Label: 50k, 5m, or auto (from row counts)")
    p.add_argument("--runs", type=int, default=5, help="Iterations per flow for timing")
    p.add_argument("--fk", choices=["on", "off", "both"], default="on", help="Run with FK checks on, off, or both")
    p.add_argument("--output", default="", help="Write results to JSON file")
    p.add_argument("--explain-only", action="store_true", help="Only run EXPLAIN, no timing")
    return p.parse_args()


def connect(args: argparse.Namespace):
    return pymysql.connect(
        host=args.host,
        user=args.user,
        password=args.password or None,
        database=args.database,
        port=args.port,
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=True,
    )


def get_row_counts(cursor) -> Dict[str, int]:
    tables = [
        "user", "address", "`order`", "order_item", "product", "product_sku",
        "inventory", "payment", "order_shipment", "purchase_order", "review"
    ]
    counts = {}
    for t in tables:
        try:
            cursor.execute(f"SELECT COUNT(*) AS c FROM {t}")
            counts[t.replace("`", "")] = cursor.fetchone()["c"]
        except Exception as e:
            counts[t.replace("`", "")] = -1
    return counts


def infer_scale_label(counts: Dict[str, int]) -> str:
    o = counts.get("order", 0)
    if o <= 0:
        return "unknown"
    if o < 100_000:
        return "50k"
    if o < 2_000_000:
        return "100k-1m"
    return "5m"


# ---------------------------------------------------------------------------
# Flow definitions: (name, flow_func, explain_query or None)
# flow_func(cursor, cursor) -> None; we time it. explain_query is the main SELECT/INSERT to EXPLAIN.
# ---------------------------------------------------------------------------

def flow_orders_by_user(cursor) -> None:
    cursor.execute("SELECT user_id FROM user WHERE user_id > 0 ORDER BY RAND() LIMIT 1")
    r = cursor.fetchone()
    if not r:
        return
    uid = r["user_id"]
    cursor.execute(
        """SELECT o.order_id, o.total_amount, o.order_status_id, o.created_dt
           FROM `order` o WHERE o.user_id = %s ORDER BY o.created_dt DESC LIMIT 20""",
        (uid,),
    )
    cursor.fetchall()


def explain_orders_by_user() -> str:
    return """EXPLAIN SELECT o.order_id, o.total_amount, o.order_status_id, o.created_dt
           FROM `order` o WHERE o.user_id = 1 ORDER BY o.created_dt DESC LIMIT 20"""


def flow_order_with_items(cursor) -> None:
    cursor.execute("SELECT order_id FROM `order` ORDER BY RAND() LIMIT 1")
    r = cursor.fetchone()
    if not r:
        return
    oid = r["order_id"]
    cursor.execute(
        """SELECT o.order_id, o.user_id, o.total_amount, o.order_status_id, o.created_dt,
                  oi.order_item_id, oi.product_id, oi.product_sku_id, oi.quantity, oi.price
           FROM `order` o
           JOIN order_item oi ON oi.order_id = o.order_id
           WHERE o.order_id = %s""",
        (oid,),
    )
    cursor.fetchall()


def explain_order_with_items() -> str:
    return """EXPLAIN SELECT o.order_id, o.user_id, o.total_amount, o.order_status_id, o.created_dt,
                  oi.order_item_id, oi.product_id, oi.product_sku_id, oi.quantity, oi.price
           FROM `order` o
           JOIN order_item oi ON oi.order_id = o.order_id
           WHERE o.order_id = 1"""


def flow_orders_paginated(cursor) -> None:
    cursor.execute(
        """SELECT order_id, user_id, total_amount, order_status_id, created_dt
           FROM `order` ORDER BY created_dt DESC LIMIT 50 OFFSET 1000"""
    )
    cursor.fetchall()


def explain_orders_paginated() -> str:
    return """EXPLAIN SELECT order_id, user_id, total_amount, order_status_id, created_dt
           FROM `order` ORDER BY created_dt DESC LIMIT 50 OFFSET 1000"""


def flow_can_fulfill_order(cursor) -> None:
    cursor.execute("SELECT order_id FROM `order` LIMIT 1")
    r = cursor.fetchone()
    if not r:
        return
    oid = r["order_id"]
    cursor.execute("SELECT warehouse_id FROM warehouse LIMIT 1")
    wh = cursor.fetchone()
    if not wh:
        return
    wid = wh["warehouse_id"]
    cursor.execute(
        """SELECT oi.product_sku_id, oi.quantity,
                  COALESCE(SUM(inv.quantity), 0) AS available
           FROM order_item oi
           LEFT JOIN inventory inv ON inv.product_sku_id = oi.product_sku_id AND inv.warehouse_id = %s
           WHERE oi.order_id = %s
           GROUP BY oi.product_sku_id, oi.quantity""",
        (wid, oid),
    )
    cursor.fetchall()


def explain_can_fulfill_order() -> str:
    return """EXPLAIN SELECT oi.product_sku_id, oi.quantity,
                  COALESCE(SUM(inv.quantity), 0) AS available
           FROM order_item oi
           LEFT JOIN inventory inv ON inv.product_sku_id = oi.product_sku_id AND inv.warehouse_id = 1
           WHERE oi.order_id = 1
           GROUP BY oi.product_sku_id, oi.quantity"""


def flow_product_with_skus(cursor) -> None:
    cursor.execute("SELECT product_id FROM product ORDER BY RAND() LIMIT 1")
    r = cursor.fetchone()
    if not r:
        return
    pid = r["product_id"]
    cursor.execute(
        """SELECT p.product_id, p.name, p.description, ps.product_sku_id, ps.sku, ps.price
           FROM product p
           JOIN product_sku ps ON ps.product_id = p.product_id
           WHERE p.product_id = %s""",
        (pid,),
    )
    cursor.fetchall()


def explain_product_with_skus() -> str:
    return """EXPLAIN SELECT p.product_id, p.name, p.description, ps.product_sku_id, ps.sku, ps.price
           FROM product p
           JOIN product_sku ps ON ps.product_id = p.product_id
           WHERE p.product_id = 1"""


def flow_available_quantity(cursor) -> None:
    cursor.execute("SELECT product_sku_id, warehouse_id FROM inventory LIMIT 1")
    r = cursor.fetchone()
    if not r:
        return
    cursor.execute(
        "SELECT quantity FROM inventory WHERE product_sku_id = %s AND warehouse_id = %s",
        (r["product_sku_id"], r["warehouse_id"]),
    )
    cursor.fetchone()


def explain_available_quantity() -> str:
    return "EXPLAIN SELECT quantity FROM inventory WHERE product_sku_id = 1 AND warehouse_id = 1"


def flow_create_order_with_items(cursor, with_fk_off: bool) -> None:
    conn = cursor.connection
    cursor.execute("SELECT user_id FROM user WHERE user_id > 0 LIMIT 1")
    u = cursor.fetchone()
    cursor.execute("SELECT address_id FROM address LIMIT 1")
    a = cursor.fetchone()
    cursor.execute("SELECT product_id FROM product LIMIT 1")
    p = cursor.fetchone()
    cursor.execute("SELECT product_sku_id FROM product_sku WHERE product_id = %s LIMIT 1", (p["product_id"],))
    sku = cursor.fetchone()
    if not all([u, a, p, sku]):
        return
    was_autocommit = conn.get_autocommit()
    conn.autocommit(False)
    if with_fk_off:
        cursor.execute("SET SESSION foreign_key_checks = 0")
    try:
        cursor.execute(
            """INSERT INTO `order` (user_id, total_amount, order_status_id, shipping_address_id, created_by, modified_by)
               VALUES (%s, 0, 1, %s, 0, 0)""",
            (u["user_id"], a["address_id"]),
        )
        oid = cursor.lastrowid
        cursor.execute(
            """INSERT INTO order_item (order_id, product_id, product_sku_id, quantity, price, created_by, modified_by)
               VALUES (%s, %s, %s, 1, 99.99, 0, 0)""",
            (oid, p["product_id"], sku["product_sku_id"]),
        )
        cursor.execute("UPDATE `order` SET total_amount = 99.99 WHERE order_id = %s", (oid,))
    finally:
        conn.rollback()
        if with_fk_off:
            cursor.execute("SET SESSION foreign_key_checks = 1")
        conn.autocommit(was_autocommit)


def flow_insert_payment(cursor, with_fk_off: bool) -> None:
    conn = cursor.connection
    cursor.execute("SELECT order_id FROM `order` ORDER BY order_id DESC LIMIT 1")
    r = cursor.fetchone()
    if not r:
        return
    oid = r["order_id"]
    cursor.execute("SELECT payment_method_id FROM payment_method LIMIT 1")
    pm = cursor.fetchone()
    if not pm:
        return
    was_autocommit = conn.get_autocommit()
    conn.autocommit(False)
    if with_fk_off:
        cursor.execute("SET SESSION foreign_key_checks = 0")
    try:
        cursor.execute(
            """INSERT INTO payment (order_id, payment_method_id, amount, payment_status_id, external_id, created_by, modified_by)
               VALUES (%s, %s, 100, 1, 'bench-test', 0, 0)""",
            (oid, pm["payment_method_id"]),
        )
    finally:
        conn.rollback()
        if with_fk_off:
            cursor.execute("SET SESSION foreign_key_checks = 1")
        conn.autocommit(was_autocommit)


def flow_reviews_by_product(cursor) -> None:
    cursor.execute("SELECT product_id FROM product ORDER BY RAND() LIMIT 1")
    r = cursor.fetchone()
    if not r:
        return
    cursor.execute(
        """SELECT review_id, user_id, rating, comment, created_dt
           FROM review WHERE product_id = %s AND deleted_dt IS NULL ORDER BY created_dt DESC LIMIT 10""",
        (r["product_id"],),
    )
    cursor.fetchall()


def explain_reviews_by_product() -> str:
    return """EXPLAIN SELECT review_id, user_id, rating, comment, created_dt
           FROM review WHERE product_id = 1 AND deleted_dt IS NULL ORDER BY created_dt DESC LIMIT 10"""


# Flows that are read-only (no FK check effect) + one write flow
FLOWS_READ = [
    ("orders_by_user", flow_orders_by_user, explain_orders_by_user),
    ("order_with_items", flow_order_with_items, explain_order_with_items),
    ("orders_paginated", flow_orders_paginated, explain_orders_paginated),
    ("can_fulfill_order", flow_can_fulfill_order, explain_can_fulfill_order),
    ("product_with_skus", flow_product_with_skus, explain_product_with_skus),
    ("available_quantity", flow_available_quantity, explain_available_quantity),
    ("reviews_by_product", flow_reviews_by_product, explain_reviews_by_product),
]

FLOWS_WRITE = [
    ("create_order_with_items", lambda c: flow_create_order_with_items(c, False), None),
    ("create_order_with_items_fk_off", lambda c: flow_create_order_with_items(c, True), None),
    ("insert_payment", lambda c: flow_insert_payment(c, False), None),
    ("insert_payment_fk_off", lambda c: flow_insert_payment(c, True), None),
]


def run_timing(cursor, flow_func: Callable, runs: int) -> Tuple[List[float], float]:
    times_ms = []
    for _ in range(runs):
        start = time.perf_counter()
        try:
            flow_func(cursor)
        except Exception as e:
            print(f"  Flow error: {e}", file=sys.stderr)
            times_ms.append(-1)
            continue
        elapsed_ms = (time.perf_counter() - start) * 1000
        times_ms.append(elapsed_ms)
    avg = sum(times_ms) / len(times_ms) if times_ms else 0
    return times_ms, avg


def run_explain(cursor, explain_sql: str) -> List[Dict]:
    try:
        cursor.execute(explain_sql)
        return cursor.fetchall()
    except Exception as e:
        return [{"error": str(e)}]


def main() -> None:
    args = parse_args()
    conn = connect(args)
    cursor = conn.cursor()

    counts = get_row_counts(cursor)
    scale = args.scale
    if scale == "auto":
        scale = infer_scale_label(counts)

    print(f"Scale label: {scale}")
    print(f"Row counts: order={counts.get('order', 0)}, user={counts.get('user', 0)}, product={counts.get('product', 0)}")
    print()

    results = {
        "scale": scale,
        "row_counts": counts,
        "runs": args.runs,
        "fk_mode": args.fk,
        "flows": [],
        "explain_plans": {},
    }

    # Run read flows (timing + EXPLAIN)
    for name, flow_func, explain_sql in FLOWS_READ:
        print(f"Flow: {name}")
        if explain_sql:
            plan = run_explain(cursor, explain_sql())
            results["explain_plans"][name] = plan
            print(f"  EXPLAIN rows: {len(plan)}")
        if not args.explain_only:
            times_ms, avg = run_timing(cursor, flow_func, args.runs)
            results["flows"].append({
                "name": name,
                "type": "read",
                "fk_checks": "on",
                "times_ms": times_ms,
                "avg_ms": round(avg, 2),
                "min_ms": round(min(times_ms), 2) if times_ms else None,
                "max_ms": round(max(times_ms), 2) if times_ms else None,
            })
            print(f"  avg_ms: {avg:.2f}  min: {min(times_ms):.2f}  max: {max(times_ms):.2f}")
        print()

    # Write flows: with FK on/off if requested
    if not args.explain_only:
        for name, flow_func, _ in FLOWS_WRITE:
            if "fk_off" in name and args.fk == "on":
                continue
            if "fk_off" not in name and args.fk == "off":
                continue
            print(f"Flow: {name}")
            times_ms, avg = run_timing(cursor, flow_func, args.runs)
            fk_val = "off" if "fk_off" in name else "on"
            results["flows"].append({
                "name": name,
                "type": "write",
                "fk_checks": fk_val,
                "times_ms": times_ms,
                "avg_ms": round(avg, 2),
                "min_ms": round(min(times_ms), 2) if times_ms else None,
                "max_ms": round(max(times_ms), 2) if times_ms else None,
            })
            print(f"  avg_ms: {avg:.2f}  (fk_checks={fk_val})")
            print()

    # Summary table
    print("--- Summary ---")
    print(f"{'Flow':<35} {'Type':<6} {'FK':<4} {'avg_ms':>10} {'min_ms':>10} {'max_ms':>10}")
    print("-" * 80)
    for f in results["flows"]:
        print(f"{f['name']:<35} {f['type']:<6} {f['fk_checks']:<4} {f['avg_ms']:>10.2f} {f.get('min_ms') or 0:>10.2f} {f.get('max_ms') or 0:>10.2f}")

    if args.output:
        # Serialize EXPLAIN rows (datetime etc.)
        out_data = {
            "scale": results["scale"],
            "row_counts": results["row_counts"],
            "runs": results["runs"],
            "fk_mode": results["fk_mode"],
            "flows": results["flows"],
            "explain_plans": {k: [dict(r) for r in v] for k, v in results["explain_plans"].items()},
        }
        with open(args.output, "w", encoding="utf-8") as out:
            json.dump(out_data, out, indent=2, default=str)
        print(f"\nResults written to {args.output}")

    cursor.close()
    conn.close()


if __name__ == "__main__":
    main()
