

SET NAMES utf8mb4;

SET @user_id     = 2;
SET @address_id  = 1;
SET @category_id = 1;
SET @sub_cat_id  = 1;
SET @brand_id    = 1;
SET @warehouse_id = 1;
SET @delivery_method_id = 1;
SET @payment_method_id  = 1;
SET @supplier_id = 1;
SET @created_by  = 1;

-- =============================================================================
-- STEP 1: Create product (and attributes if needed), then SKUs
-- =============================================================================
-- 1.1 Create product
CALL sp_create_product(
    'Smartphone X',                           -- name
    'Latest smartphone with great camera',    -- description
    'Smartphone X 128GB',                     -- short_description
    @category_id, @sub_cat_id, @brand_id,    -- category, sub_category, brand
    0.2,                                      -- weight_kg
    1,                                        -- is_featured
    @created_by,
    @product_id
);
SELECT @product_id AS product_id_created;

-- 1.2 Create attributes (if not in seed: size/color already in seed, use IDs 1-10)
-- We use existing: size M = 2, color Black = 5.

-- 1.3 Create SKU (non-serialized, for simple inventory)
CALL sp_create_product_sku(
    @product_id,   -- product_id
    'SMX-512-BLK', -- sku
    799.99,        -- price
    2,             -- size_attribute_id (M)
    5,             -- color_attribute_id (Black)
    0,             -- is_serialized
    @created_by,
    @product_sku_id
);
SET @sku_simple = @product_sku_id;
SELECT @sku_simple AS product_sku_id_simple;

-- 1.4 Create second SKU (serialized, for phones with serial number)
CALL sp_create_product_sku(
    @product_id,
    'SMX-256-BLK',
    399.99,
    2, 5,
    1,            -- is_serialized = 1
    @created_by,
    @product_sku_id
);
SET @sku_serialized = @product_sku_id;
SELECT @sku_serialized AS product_sku_id_serialized;

-- =============================================================================
-- STEP 2: Receive stock on warehouse
-- =============================================================================
-- 2.1 Receive non-serialized SKU (quantity to inventory)
CALL sp_inventory_receive(@sku_simple, @warehouse_id, 50, @created_by);

-- 2.2 Receive serialized SKU (individual units with serial numbers)
SET @json_units = CONCAT('[
    {"product_sku_id": ', @sku_serialized, ', "warehouse_id": ', @warehouse_id, ', "serial_number": "SN001", "manufacture_date": "2024-06-01", "article": "ART-SMX-001", "imei": "111111111"},
    {"product_sku_id": ', @sku_serialized, ', "warehouse_id": ', @warehouse_id, ', "serial_number": "SN002", "manufacture_date": "2024-06-01", "article": "ART-SMX-002", "imei": "222222222"},
    {"product_sku_id": ', @sku_serialized, ', "warehouse_id": ', @warehouse_id, ', "serial_number": "SN003", "manufacture_date": "2024-06-02", "article": "ART-SMX-003", "imei": "333333333"}
]');
CALL sp_receive_serialized_units(@json_units, @created_by, @units_count);
SELECT @units_count AS serialized_units_received;

-- =============================================================================
-- STEP 3: Customer places order (with line items in JSON)
-- =============================================================================
CALL sp_create_order(
        @user_id,
        @address_id,
        @created_by,
        CONCAT('[
        {"product_id": ', @product_id, ', "product_sku_id": ', @sku_simple, ', "quantity": 2, "price": 299.99},
        {"product_id": ', @product_id, ', "product_sku_id": ', @sku_serialized, ', "quantity": 1, "price": 399.99}
    ]'),
        @order_id
     );
SELECT @order_id AS order_id_created;

-- =============================================================================
-- STEP 4: Payment (mark order as paid)
-- =============================================================================
CALL sp_create_payment(@order_id, 999.97, @payment_method_id, NULL, @created_by, @payment_id);
CALL sp_payment_set_status(@payment_id, 2, @created_by, 1);
-- (2 = completed, 1 = set order to paid)

-- =============================================================================
-- STEP 5: Create order shipment and fulfill from warehouse
-- =============================================================================
CALL sp_create_shipment(@order_id, @warehouse_id, @delivery_method_id, 'TRACK-001', @created_by, @order_shipment_id);
SELECT @order_shipment_id AS order_shipment_id;

-- Fulfill: allocate inventory/serialized units, create shipment items
CALL sp_fulfill_shipment(@order_shipment_id, @warehouse_id, @created_by, @ok);
SELECT @ok AS fulfill_ok;

-- Mark as delivered
CALL sp_shipment_mark_delivered(@order_shipment_id, @created_by);

-- =============================================================================
-- STEP 6: Replenish: purchase order from supplier, then receive to warehouse
-- =============================================================================
-- 6.1 Link product to supplier (we buy this product from supplier)
CALL sp_supplier_link_product(@supplier_id, @product_id, 'SUP-SMX', 250.00, @created_by);

-- 6.2 Create purchase order (we order from supplier, destination = our warehouse)
CALL sp_create_purchase_order(
        @supplier_id,
        @warehouse_id,
        5, -- delivery_method_id (e.g. supplier truck)
        CURDATE(), -- order_date
        DATE_ADD(CURDATE(), INTERVAL 7 DAY), -- expected_delivery_date
        'Test replenishment',
        @created_by,
        @purchase_order_id
     );
SELECT @purchase_order_id AS purchase_order_id;

-- 6.3 Add lines to purchase order
CALL sp_purchase_order_add_item(@purchase_order_id, @sku_simple, 20, 250.00, @created_by, @po_item_id1);
CALL sp_purchase_order_add_item(@purchase_order_id, @sku_serialized, 5, 320.00, @created_by, @po_item_id2);

-- 6.4 Mark as ordered (optional)
CALL sp_purchase_order_set_status(@purchase_order_id, 2, @created_by);

-- 6.5 When goods arrive: receive purchase order (increases inventory / creates product_units)
CALL sp_receive_purchase_order(@purchase_order_id, @created_by, @receive_ok);
SELECT @receive_ok AS receive_purchase_order_ok;

-- 6.6 Mark PO as received
CALL sp_purchase_order_set_status(@purchase_order_id, 4, @created_by);

-- =============================================================================
-- Done. Summary:
-- =============================================================================
SELECT 'Flow completed: product created -> stock received -> order placed -> paid -> shipped -> delivered -> replenished via PO' AS summary;
SELECT @product_id        AS product_id,
       @order_id          AS order_id,
       @order_shipment_id AS order_shipment_id,
       @purchase_order_id AS purchase_order_id;
