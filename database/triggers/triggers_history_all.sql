-- Triggers: on INSERT/UPDATE of each main table, insert a row into the corresponding history table with action_description.
-- No DELETE triggers (soft delete only: set deleted_dt). Run after V011 (history tables exist).
--
-- action_description from session variable @current_action_desc (MySQL triggers cannot have parameters).
-- Before DML: SET @current_action_desc = 'Your message'; If not set: COALESCE(@current_action_desc, 'System Unknown Action').
DELIMITER //

-- user
DROP TRIGGER IF EXISTS tr_user_after_insert//
CREATE TRIGGER tr_user_after_insert
    AFTER INSERT
    ON user
    FOR EACH ROW
    INSERT INTO user_history (user_id, username, email, password_hash, first_name, last_name, user_status_id,
                              created_by, created_dt, modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.user_id, NEW.username, NEW.email, NEW.password_hash, NEW.first_name, NEW.last_name, NEW.user_status_id,
            NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_user_after_update//
CREATE TRIGGER tr_user_after_update
    AFTER UPDATE
    ON user
    FOR EACH ROW
    INSERT INTO user_history (user_id, username, email, password_hash, first_name, last_name, user_status_id,
                              created_by, created_dt, modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.user_id, NEW.username, NEW.email, NEW.password_hash, NEW.first_name, NEW.last_name, NEW.user_status_id,
            NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

-- address
DROP TRIGGER IF EXISTS tr_address_after_insert//
CREATE TRIGGER tr_address_after_insert
    AFTER INSERT
    ON address
    FOR EACH ROW
    INSERT INTO address_history (address_id, user_id, street, city, postal_code, country, is_default, created_by,
                                 created_dt, modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.address_id, NEW.user_id, NEW.street, NEW.city, NEW.postal_code, NEW.country, NEW.is_default,
            NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_address_after_update//
CREATE TRIGGER tr_address_after_update
    AFTER UPDATE
    ON address
    FOR EACH ROW
    INSERT INTO address_history (address_id, user_id, street, city, postal_code, country, is_default, created_by,
                                 created_dt, modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.address_id, NEW.user_id, NEW.street, NEW.city, NEW.postal_code, NEW.country, NEW.is_default,
            NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

-- category
DROP TRIGGER IF EXISTS tr_category_after_insert//
CREATE TRIGGER tr_category_after_insert
    AFTER INSERT
    ON category
    FOR EACH ROW
    INSERT INTO category_history (category_id, name, slug, description, created_by, created_dt, modified_by,
                                  modified_dt, deleted_dt, action_description)
    VALUES (NEW.category_id, NEW.name, NEW.slug, NEW.description, NEW.created_by, NEW.created_dt, NEW.modified_by,
            NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_category_after_update//
CREATE TRIGGER tr_category_after_update
    AFTER UPDATE
    ON category
    FOR EACH ROW
    INSERT INTO category_history (category_id, name, slug, description, created_by, created_dt, modified_by,
                                  modified_dt, deleted_dt, action_description)
    VALUES (NEW.category_id, NEW.name, NEW.slug, NEW.description, NEW.created_by, NEW.created_dt, NEW.modified_by,
            NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

-- sub_category
DROP TRIGGER IF EXISTS tr_sub_category_after_insert//
CREATE TRIGGER tr_sub_category_after_insert
    AFTER INSERT
    ON sub_category
    FOR EACH ROW
    INSERT INTO sub_category_history (sub_category_id, parent_id, name, slug, created_by, created_dt, modified_by,
                                      modified_dt, deleted_dt, action_description)
    VALUES (NEW.sub_category_id, NEW.parent_id, NEW.name, NEW.slug, NEW.created_by, NEW.created_dt, NEW.modified_by,
            NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_sub_category_after_update//
CREATE TRIGGER tr_sub_category_after_update
    AFTER UPDATE
    ON sub_category
    FOR EACH ROW
    INSERT INTO sub_category_history (sub_category_id, parent_id, name, slug, created_by, created_dt, modified_by,
                                      modified_dt, deleted_dt, action_description)
    VALUES (NEW.sub_category_id, NEW.parent_id, NEW.name, NEW.slug, NEW.created_by, NEW.created_dt, NEW.modified_by,
            NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

-- brand
DROP TRIGGER IF EXISTS tr_brand_after_insert//
CREATE TRIGGER tr_brand_after_insert
    AFTER INSERT
    ON brand
    FOR EACH ROW
    INSERT INTO brand_history (brand_id, name, slug, description, logo_url, website_url, created_by, created_dt,
                               modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.brand_id, NEW.name, NEW.slug, NEW.description, NEW.logo_url, NEW.website_url, NEW.created_by,
            NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_brand_after_update//
CREATE TRIGGER tr_brand_after_update
    AFTER UPDATE
    ON brand
    FOR EACH ROW
    INSERT INTO brand_history (brand_id, name, slug, description, logo_url, website_url, created_by, created_dt,
                               modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.brand_id, NEW.name, NEW.slug, NEW.description, NEW.logo_url, NEW.website_url, NEW.created_by,
            NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

-- product
DROP TRIGGER IF EXISTS tr_product_after_insert//
CREATE TRIGGER tr_product_after_insert
    AFTER INSERT
    ON product
    FOR EACH ROW
    INSERT INTO product_history (product_id, name, description, short_description, category_id, sub_category_id,
                                 brand_id, stock_quantity, weight_kg, length_cm, width_cm, height_cm, is_featured,
                                 meta_title, meta_description, created_by, created_dt, modified_by, modified_dt,
                                 deleted_dt, action_description)
    VALUES (NEW.product_id, NEW.name, NEW.description, NEW.short_description, NEW.category_id, NEW.sub_category_id,
            NEW.brand_id, NEW.stock_quantity, NEW.weight_kg, NEW.length_cm, NEW.width_cm, NEW.height_cm,
            NEW.is_featured, NEW.meta_title, NEW.meta_description, NEW.created_by, NEW.created_dt, NEW.modified_by,
            NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_product_after_update//
CREATE TRIGGER tr_product_after_update
    AFTER UPDATE
    ON product
    FOR EACH ROW
    INSERT INTO product_history (product_id, name, description, short_description, category_id, sub_category_id,
                                 brand_id, stock_quantity, weight_kg, length_cm, width_cm, height_cm, is_featured,
                                 meta_title, meta_description, created_by, created_dt, modified_by, modified_dt,
                                 deleted_dt, action_description)
    VALUES (NEW.product_id, NEW.name, NEW.description, NEW.short_description, NEW.category_id, NEW.sub_category_id,
            NEW.brand_id, NEW.stock_quantity, NEW.weight_kg, NEW.length_cm, NEW.width_cm, NEW.height_cm,
            NEW.is_featured, NEW.meta_title, NEW.meta_description, NEW.created_by, NEW.created_dt, NEW.modified_by,
            NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

-- product_attribute
DROP TRIGGER IF EXISTS tr_product_attribute_after_insert//
CREATE TRIGGER tr_product_attribute_after_insert
    AFTER INSERT
    ON product_attribute
    FOR EACH ROW
    INSERT INTO product_attribute_history (product_attribute_id, attribute_type, attribute_value, created_by,
                                           created_dt, modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.product_attribute_id, NEW.attribute_type, NEW.attribute_value, NEW.created_by, NEW.created_dt,
            NEW.modified_by, NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_product_attribute_after_update//
CREATE TRIGGER tr_product_attribute_after_update
    AFTER UPDATE
    ON product_attribute
    FOR EACH ROW
    INSERT INTO product_attribute_history (product_attribute_id, attribute_type, attribute_value, created_by,
                                           created_dt, modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.product_attribute_id, NEW.attribute_type, NEW.attribute_value, NEW.created_by, NEW.created_dt,
            NEW.modified_by, NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

-- product_sku
DROP TRIGGER IF EXISTS tr_product_sku_after_insert//
CREATE TRIGGER tr_product_sku_after_insert
    AFTER INSERT
    ON product_sku
    FOR EACH ROW
    INSERT INTO product_sku_history (product_sku_id, product_id, sku, size_attribute_id, color_attribute_id, price,
                                     is_serialized, created_by, created_dt, modified_by, modified_dt, deleted_dt,
                                     action_description)
    VALUES (NEW.product_sku_id, NEW.product_id, NEW.sku, NEW.size_attribute_id, NEW.color_attribute_id, NEW.price,
            NEW.is_serialized, NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_product_sku_after_update//
CREATE TRIGGER tr_product_sku_after_update
    AFTER UPDATE
    ON product_sku
    FOR EACH ROW
    INSERT INTO product_sku_history (product_sku_id, product_id, sku, size_attribute_id, color_attribute_id, price,
                                     is_serialized, created_by, created_dt, modified_by, modified_dt, deleted_dt,
                                     action_description)
    VALUES (NEW.product_sku_id, NEW.product_id, NEW.sku, NEW.size_attribute_id, NEW.color_attribute_id, NEW.price,
            NEW.is_serialized, NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

-- order
DROP TRIGGER IF EXISTS tr_order_after_insert//
CREATE TRIGGER tr_order_after_insert
    AFTER INSERT
    ON `order`
    FOR EACH ROW
    INSERT INTO order_history (order_id, user_id, total_amount, order_status_id, shipping_address_id, created_by,
                               created_dt, modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.order_id, NEW.user_id, NEW.total_amount, NEW.order_status_id, NEW.shipping_address_id, NEW.created_by,
            NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_order_after_update//
CREATE TRIGGER tr_order_after_update
    AFTER UPDATE
    ON `order`
    FOR EACH ROW
    INSERT INTO order_history (order_id, user_id, total_amount, order_status_id, shipping_address_id, created_by,
                               created_dt, modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.order_id, NEW.user_id, NEW.total_amount, NEW.order_status_id, NEW.shipping_address_id, NEW.created_by,
            NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

-- order_item
DROP TRIGGER IF EXISTS tr_order_item_after_insert//
CREATE TRIGGER tr_order_item_after_insert
    AFTER INSERT
    ON order_item
    FOR EACH ROW
    INSERT INTO order_item_history (order_item_id, order_id, product_id, product_sku_id, quantity, price, created_by,
                                    created_dt, modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.order_item_id, NEW.order_id, NEW.product_id, NEW.product_sku_id, NEW.quantity, NEW.price,
            NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_order_item_after_update//
CREATE TRIGGER tr_order_item_after_update
    AFTER UPDATE
    ON order_item
    FOR EACH ROW
    INSERT INTO order_item_history (order_item_id, order_id, product_id, product_sku_id, quantity, price, created_by,
                                    created_dt, modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.order_item_id, NEW.order_id, NEW.product_id, NEW.product_sku_id, NEW.quantity, NEW.price,
            NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

-- cart
DROP TRIGGER IF EXISTS tr_cart_after_insert//
CREATE TRIGGER tr_cart_after_insert
    AFTER INSERT
    ON cart
    FOR EACH ROW
    INSERT INTO cart_history (cart_id, user_id, total, created_by, created_dt, modified_by, modified_dt, deleted_dt,
                              action_description)
    VALUES (NEW.cart_id, NEW.user_id, NEW.total, NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt,
            NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_cart_after_update//
CREATE TRIGGER tr_cart_after_update
    AFTER UPDATE
    ON cart
    FOR EACH ROW
    INSERT INTO cart_history (cart_id, user_id, total, created_by, created_dt, modified_by, modified_dt, deleted_dt,
                              action_description)
    VALUES (NEW.cart_id, NEW.user_id, NEW.total, NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt,
            NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

-- cart_item
DROP TRIGGER IF EXISTS tr_cart_item_after_insert//
CREATE TRIGGER tr_cart_item_after_insert
    AFTER INSERT
    ON cart_item
    FOR EACH ROW
    INSERT INTO cart_item_history (cart_item_id, cart_id, product_id, product_sku_id, quantity, created_by, created_dt,
                                   modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.cart_item_id, NEW.cart_id, NEW.product_id, NEW.product_sku_id, NEW.quantity, NEW.created_by,
            NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_cart_item_after_update//
CREATE TRIGGER tr_cart_item_after_update
    AFTER UPDATE
    ON cart_item
    FOR EACH ROW
    INSERT INTO cart_item_history (cart_item_id, cart_id, product_id, product_sku_id, quantity, created_by, created_dt,
                                   modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.cart_item_id, NEW.cart_id, NEW.product_id, NEW.product_sku_id, NEW.quantity, NEW.created_by,
            NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

-- wishlist
DROP TRIGGER IF EXISTS tr_wishlist_after_insert//
CREATE TRIGGER tr_wishlist_after_insert
    AFTER INSERT
    ON wishlist
    FOR EACH ROW
    INSERT INTO wishlist_history (wishlist_id, user_id, name, created_by, created_dt, modified_by, modified_dt,
                                  deleted_dt, action_description)
    VALUES (NEW.wishlist_id, NEW.user_id, NEW.name, NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt,
            NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_wishlist_after_update//
CREATE TRIGGER tr_wishlist_after_update
    AFTER UPDATE
    ON wishlist
    FOR EACH ROW
    INSERT INTO wishlist_history (wishlist_id, user_id, name, created_by, created_dt, modified_by, modified_dt,
                                  deleted_dt, action_description)
    VALUES (NEW.wishlist_id, NEW.user_id, NEW.name, NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt,
            NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

-- wishlist_item
DROP TRIGGER IF EXISTS tr_wishlist_item_after_insert//
CREATE TRIGGER tr_wishlist_item_after_insert
    AFTER INSERT
    ON wishlist_item
    FOR EACH ROW
    INSERT INTO wishlist_item_history (wishlist_item_id, wishlist_id, product_id, created_by, created_dt, modified_by,
                                       modified_dt, deleted_dt, action_description)
    VALUES (NEW.wishlist_item_id, NEW.wishlist_id, NEW.product_id, NEW.created_by, NEW.created_dt, NEW.modified_by,
            NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_wishlist_item_after_update//
CREATE TRIGGER tr_wishlist_item_after_update
    AFTER UPDATE
    ON wishlist_item
    FOR EACH ROW
    INSERT INTO wishlist_item_history (wishlist_item_id, wishlist_id, product_id, created_by, created_dt, modified_by,
                                       modified_dt, deleted_dt, action_description)
    VALUES (NEW.wishlist_item_id, NEW.wishlist_id, NEW.product_id, NEW.created_by, NEW.created_dt, NEW.modified_by,
            NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

-- payment_method
DROP TRIGGER IF EXISTS tr_payment_method_after_insert//
CREATE TRIGGER tr_payment_method_after_insert
    AFTER INSERT
    ON payment_method
    FOR EACH ROW
    INSERT INTO payment_method_history (payment_method_id, name, code, is_active, created_by, created_dt, modified_by,
                                        modified_dt, deleted_dt, action_description)
    VALUES (NEW.payment_method_id, NEW.name, NEW.code, NEW.is_active, NEW.created_by, NEW.created_dt, NEW.modified_by,
            NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_payment_method_after_update//
CREATE TRIGGER tr_payment_method_after_update
    AFTER UPDATE
    ON payment_method
    FOR EACH ROW
    INSERT INTO payment_method_history (payment_method_id, name, code, is_active, created_by, created_dt, modified_by,
                                        modified_dt, deleted_dt, action_description)
    VALUES (NEW.payment_method_id, NEW.name, NEW.code, NEW.is_active, NEW.created_by, NEW.created_dt, NEW.modified_by,
            NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

-- payment
DROP TRIGGER IF EXISTS tr_payment_after_insert//
CREATE TRIGGER tr_payment_after_insert
    AFTER INSERT
    ON payment
    FOR EACH ROW
    INSERT INTO payment_history (payment_id, order_id, payment_method_id, amount, payment_status_id, external_id,
                                 created_by, created_dt, modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.payment_id, NEW.order_id, NEW.payment_method_id, NEW.amount, NEW.payment_status_id, NEW.external_id,
            NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_payment_after_update//
CREATE TRIGGER tr_payment_after_update
    AFTER UPDATE
    ON payment
    FOR EACH ROW
    INSERT INTO payment_history (payment_id, order_id, payment_method_id, amount, payment_status_id, external_id,
                                 created_by, created_dt, modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.payment_id, NEW.order_id, NEW.payment_method_id, NEW.amount, NEW.payment_status_id, NEW.external_id,
            NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

-- coupon
DROP TRIGGER IF EXISTS tr_coupon_after_insert//
CREATE TRIGGER tr_coupon_after_insert
    AFTER INSERT
    ON coupon
    FOR EACH ROW
    INSERT INTO coupon_history (coupon_id, code, coupon_discount_type_id, discount_amount, discount_percent, valid_from,
                                valid_to, max_uses, used_count, min_order_amount, created_by, created_dt, modified_by,
                                modified_dt, deleted_dt, action_description)
    VALUES (NEW.coupon_id, NEW.code, NEW.coupon_discount_type_id, NEW.discount_amount, NEW.discount_percent,
            NEW.valid_from, NEW.valid_to, NEW.max_uses, NEW.used_count, NEW.min_order_amount, NEW.created_by,
            NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_coupon_after_update//
CREATE TRIGGER tr_coupon_after_update
    AFTER UPDATE
    ON coupon
    FOR EACH ROW
    INSERT INTO coupon_history (coupon_id, code, coupon_discount_type_id, discount_amount, discount_percent, valid_from,
                                valid_to, max_uses, used_count, min_order_amount, created_by, created_dt, modified_by,
                                modified_dt, deleted_dt, action_description)
    VALUES (NEW.coupon_id, NEW.code, NEW.coupon_discount_type_id, NEW.discount_amount, NEW.discount_percent,
            NEW.valid_from, NEW.valid_to, NEW.max_uses, NEW.used_count, NEW.min_order_amount, NEW.created_by,
            NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

-- coupon_redemption
DROP TRIGGER IF EXISTS tr_coupon_redemption_after_insert//
CREATE TRIGGER tr_coupon_redemption_after_insert
    AFTER INSERT
    ON coupon_redemption
    FOR EACH ROW
    INSERT INTO coupon_redemption_history (coupon_redemption_id, coupon_id, order_id, user_id, discount_applied,
                                           created_by, created_dt, modified_by, modified_dt, deleted_dt,
                                           action_description)
    VALUES (NEW.coupon_redemption_id, NEW.coupon_id, NEW.order_id, NEW.user_id, NEW.discount_applied, NEW.created_by,
            NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_coupon_redemption_after_update//
CREATE TRIGGER tr_coupon_redemption_after_update
    AFTER UPDATE
    ON coupon_redemption
    FOR EACH ROW
    INSERT INTO coupon_redemption_history (coupon_redemption_id, coupon_id, order_id, user_id, discount_applied,
                                           created_by, created_dt, modified_by, modified_dt, deleted_dt,
                                           action_description)
    VALUES (NEW.coupon_redemption_id, NEW.coupon_id, NEW.order_id, NEW.user_id, NEW.discount_applied, NEW.created_by,
            NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

-- warehouse
DROP TRIGGER IF EXISTS tr_warehouse_after_insert//
CREATE TRIGGER tr_warehouse_after_insert
    AFTER INSERT
    ON warehouse
    FOR EACH ROW
    INSERT INTO warehouse_history (warehouse_id, name, location, address, created_by, created_dt, modified_by,
                                   modified_dt, deleted_dt, action_description)
    VALUES (NEW.warehouse_id, NEW.name, NEW.location, NEW.address, NEW.created_by, NEW.created_dt, NEW.modified_by,
            NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_warehouse_after_update//
CREATE TRIGGER tr_warehouse_after_update
    AFTER UPDATE
    ON warehouse
    FOR EACH ROW
    INSERT INTO warehouse_history (warehouse_id, name, location, address, created_by, created_dt, modified_by,
                                   modified_dt, deleted_dt, action_description)
    VALUES (NEW.warehouse_id, NEW.name, NEW.location, NEW.address, NEW.created_by, NEW.created_dt, NEW.modified_by,
            NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

-- inventory
DROP TRIGGER IF EXISTS tr_inventory_after_insert//
CREATE TRIGGER tr_inventory_after_insert
    AFTER INSERT
    ON inventory
    FOR EACH ROW
    INSERT INTO inventory_history (inventory_id, product_sku_id, warehouse_id, quantity, created_by, created_dt,
                                   modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.inventory_id, NEW.product_sku_id, NEW.warehouse_id, NEW.quantity, NEW.created_by, NEW.created_dt,
            NEW.modified_by, NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_inventory_after_update//
CREATE TRIGGER tr_inventory_after_update
    AFTER UPDATE
    ON inventory
    FOR EACH ROW
    INSERT INTO inventory_history (inventory_id, product_sku_id, warehouse_id, quantity, created_by, created_dt,
                                   modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.inventory_id, NEW.product_sku_id, NEW.warehouse_id, NEW.quantity, NEW.created_by, NEW.created_dt,
            NEW.modified_by, NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

-- product_unit
DROP TRIGGER IF EXISTS tr_product_unit_after_insert//
CREATE TRIGGER tr_product_unit_after_insert
    AFTER INSERT
    ON product_unit
    FOR EACH ROW
    INSERT INTO product_unit_history (product_unit_id, product_sku_id, warehouse_id, serial_number, manufacture_date,
                                      article, imei, batch_number, tracking_info, order_item_id, order_shipment_item_id,
                                      created_by, created_dt, modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.product_unit_id, NEW.product_sku_id, NEW.warehouse_id, NEW.serial_number, NEW.manufacture_date,
            NEW.article, NEW.imei, NEW.batch_number, NEW.tracking_info, NEW.order_item_id, NEW.order_shipment_item_id,
            NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_product_unit_after_update//
CREATE TRIGGER tr_product_unit_after_update
    AFTER UPDATE
    ON product_unit
    FOR EACH ROW
    INSERT INTO product_unit_history (product_unit_id, product_sku_id, warehouse_id, serial_number, manufacture_date,
                                      article, imei, batch_number, tracking_info, order_item_id, order_shipment_item_id,
                                      created_by, created_dt, modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.product_unit_id, NEW.product_sku_id, NEW.warehouse_id, NEW.serial_number, NEW.manufacture_date,
            NEW.article, NEW.imei, NEW.batch_number, NEW.tracking_info, NEW.order_item_id, NEW.order_shipment_item_id,
            NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

-- supplier
DROP TRIGGER IF EXISTS tr_supplier_after_insert//
CREATE TRIGGER tr_supplier_after_insert
    AFTER INSERT
    ON supplier
    FOR EACH ROW
    INSERT INTO supplier_history (supplier_id, name, contact_info, email, phone, created_by, created_dt, modified_by,
                                  modified_dt, deleted_dt, action_description)
    VALUES (NEW.supplier_id, NEW.name, NEW.contact_info, NEW.email, NEW.phone, NEW.created_by, NEW.created_dt,
            NEW.modified_by, NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_supplier_after_update//
CREATE TRIGGER tr_supplier_after_update
    AFTER UPDATE
    ON supplier
    FOR EACH ROW
    INSERT INTO supplier_history (supplier_id, name, contact_info, email, phone, created_by, created_dt, modified_by,
                                  modified_dt, deleted_dt, action_description)
    VALUES (NEW.supplier_id, NEW.name, NEW.contact_info, NEW.email, NEW.phone, NEW.created_by, NEW.created_dt,
            NEW.modified_by, NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

-- supplier_product
DROP TRIGGER IF EXISTS tr_supplier_product_after_insert//
CREATE TRIGGER tr_supplier_product_after_insert
    AFTER INSERT
    ON supplier_product
    FOR EACH ROW
    INSERT INTO supplier_product_history (supplier_id, product_id, supplier_sku, cost_price, created_by, created_dt,
                                          modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.supplier_id, NEW.product_id, NEW.supplier_sku, NEW.cost_price, NEW.created_by, NEW.created_dt,
            NEW.modified_by, NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_supplier_product_after_update//
CREATE TRIGGER tr_supplier_product_after_update
    AFTER UPDATE
    ON supplier_product
    FOR EACH ROW
    INSERT INTO supplier_product_history (supplier_id, product_id, supplier_sku, cost_price, created_by, created_dt,
                                          modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.supplier_id, NEW.product_id, NEW.supplier_sku, NEW.cost_price, NEW.created_by, NEW.created_dt,
            NEW.modified_by, NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

-- delivery_method
DROP TRIGGER IF EXISTS tr_delivery_method_after_insert//
CREATE TRIGGER tr_delivery_method_after_insert
    AFTER INSERT
    ON delivery_method
    FOR EACH ROW
    INSERT INTO delivery_method_history (delivery_method_id, name, code, description, is_active, created_by, created_dt,
                                         modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.delivery_method_id, NEW.name, NEW.code, NEW.description, NEW.is_active, NEW.created_by, NEW.created_dt,
            NEW.modified_by, NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_delivery_method_after_update//
CREATE TRIGGER tr_delivery_method_after_update
    AFTER UPDATE
    ON delivery_method
    FOR EACH ROW
    INSERT INTO delivery_method_history (delivery_method_id, name, code, description, is_active, created_by, created_dt,
                                         modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.delivery_method_id, NEW.name, NEW.code, NEW.description, NEW.is_active, NEW.created_by, NEW.created_dt,
            NEW.modified_by, NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

-- order_shipment
DROP TRIGGER IF EXISTS tr_order_shipment_after_insert//
CREATE TRIGGER tr_order_shipment_after_insert
    AFTER INSERT
    ON order_shipment
    FOR EACH ROW
    INSERT INTO order_shipment_history (order_shipment_id, order_id, warehouse_id, delivery_method_id, tracking_number,
                                        shipped_date, delivered_date, shipment_status_id, created_by, created_dt,
                                        modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.order_shipment_id, NEW.order_id, NEW.warehouse_id, NEW.delivery_method_id, NEW.tracking_number,
            NEW.shipped_date, NEW.delivered_date, NEW.shipment_status_id, NEW.created_by, NEW.created_dt,
            NEW.modified_by, NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_order_shipment_after_update//
CREATE TRIGGER tr_order_shipment_after_update
    AFTER UPDATE
    ON order_shipment
    FOR EACH ROW
    INSERT INTO order_shipment_history (order_shipment_id, order_id, warehouse_id, delivery_method_id, tracking_number,
                                        shipped_date, delivered_date, shipment_status_id, created_by, created_dt,
                                        modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.order_shipment_id, NEW.order_id, NEW.warehouse_id, NEW.delivery_method_id, NEW.tracking_number,
            NEW.shipped_date, NEW.delivered_date, NEW.shipment_status_id, NEW.created_by, NEW.created_dt,
            NEW.modified_by, NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

-- order_shipment_item
DROP TRIGGER IF EXISTS tr_order_shipment_item_after_insert//
CREATE TRIGGER tr_order_shipment_item_after_insert
    AFTER INSERT
    ON order_shipment_item
    FOR EACH ROW
    INSERT INTO order_shipment_item_history (order_shipment_item_id, order_shipment_id, product_id, quantity,
                                             created_by, created_dt, modified_by, modified_dt, deleted_dt,
                                             action_description)
    VALUES (NEW.order_shipment_item_id, NEW.order_shipment_id, NEW.product_id, NEW.quantity, NEW.created_by,
            NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_order_shipment_item_after_update//
CREATE TRIGGER tr_order_shipment_item_after_update
    AFTER UPDATE
    ON order_shipment_item
    FOR EACH ROW
    INSERT INTO order_shipment_item_history (order_shipment_item_id, order_shipment_id, product_id, quantity,
                                             created_by, created_dt, modified_by, modified_dt, deleted_dt,
                                             action_description)
    VALUES (NEW.order_shipment_item_id, NEW.order_shipment_id, NEW.product_id, NEW.quantity, NEW.created_by,
            NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

-- purchase_order
DROP TRIGGER IF EXISTS tr_purchase_order_after_insert//
CREATE TRIGGER tr_purchase_order_after_insert
    AFTER INSERT
    ON purchase_order
    FOR EACH ROW
    INSERT INTO purchase_order_history (purchase_order_id, supplier_id, warehouse_id, delivery_method_id,
                                        purchase_order_status_id, order_date, expected_delivery_date, notes, created_by,
                                        created_dt, modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.purchase_order_id, NEW.supplier_id, NEW.warehouse_id, NEW.delivery_method_id,
            NEW.purchase_order_status_id, NEW.order_date, NEW.expected_delivery_date, NEW.notes, NEW.created_by,
            NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_purchase_order_after_update//
CREATE TRIGGER tr_purchase_order_after_update
    AFTER UPDATE
    ON purchase_order
    FOR EACH ROW
    INSERT INTO purchase_order_history (purchase_order_id, supplier_id, warehouse_id, delivery_method_id,
                                        purchase_order_status_id, order_date, expected_delivery_date, notes, created_by,
                                        created_dt, modified_by, modified_dt, deleted_dt, action_description)
    VALUES (NEW.purchase_order_id, NEW.supplier_id, NEW.warehouse_id, NEW.delivery_method_id,
            NEW.purchase_order_status_id, NEW.order_date, NEW.expected_delivery_date, NEW.notes, NEW.created_by,
            NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

-- purchase_order_item
DROP TRIGGER IF EXISTS tr_purchase_order_item_after_insert//
CREATE TRIGGER tr_purchase_order_item_after_insert
    AFTER INSERT
    ON purchase_order_item
    FOR EACH ROW
    INSERT INTO purchase_order_item_history (purchase_order_item_id, purchase_order_id, product_sku_id, quantity,
                                             unit_cost, created_by, created_dt, modified_by, modified_dt, deleted_dt,
                                             action_description)
    VALUES (NEW.purchase_order_item_id, NEW.purchase_order_id, NEW.product_sku_id, NEW.quantity, NEW.unit_cost,
            NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_purchase_order_item_after_update//
CREATE TRIGGER tr_purchase_order_item_after_update
    AFTER UPDATE
    ON purchase_order_item
    FOR EACH ROW
    INSERT INTO purchase_order_item_history (purchase_order_item_id, purchase_order_id, product_sku_id, quantity,
                                             unit_cost, created_by, created_dt, modified_by, modified_dt, deleted_dt,
                                             action_description)
    VALUES (NEW.purchase_order_item_id, NEW.purchase_order_id, NEW.product_sku_id, NEW.quantity, NEW.unit_cost,
            NEW.created_by, NEW.created_dt, NEW.modified_by, NEW.modified_dt, NEW.deleted_dt,
            COALESCE(@current_action_desc, 'System Unknown Action'))//

-- review
DROP TRIGGER IF EXISTS tr_review_after_insert//
CREATE TRIGGER tr_review_after_insert
    AFTER INSERT
    ON review
    FOR EACH ROW
    INSERT INTO review_history (review_id, user_id, product_id, rating, comment, created_by, created_dt, modified_by,
                                modified_dt, deleted_dt, action_description)
    VALUES (NEW.review_id, NEW.user_id, NEW.product_id, NEW.rating, NEW.comment, NEW.created_by, NEW.created_dt,
            NEW.modified_by, NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_review_after_update//
CREATE TRIGGER tr_review_after_update
    AFTER UPDATE
    ON review
    FOR EACH ROW
    INSERT INTO review_history (review_id, user_id, product_id, rating, comment, created_by, created_dt, modified_by,
                                modified_dt, deleted_dt, action_description)
    VALUES (NEW.review_id, NEW.user_id, NEW.product_id, NEW.rating, NEW.comment, NEW.created_by, NEW.created_dt,
            NEW.modified_by, NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

-- rating
DROP TRIGGER IF EXISTS tr_rating_after_insert//
CREATE TRIGGER tr_rating_after_insert
    AFTER INSERT
    ON rating
    FOR EACH ROW
    INSERT INTO rating_history (rating_id, product_id, user_id, value, created_by, created_dt, modified_by, modified_dt,
                                deleted_dt, action_description)
    VALUES (NEW.rating_id, NEW.product_id, NEW.user_id, NEW.value, NEW.created_by, NEW.created_dt, NEW.modified_by,
            NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DROP TRIGGER IF EXISTS tr_rating_after_update//
CREATE TRIGGER tr_rating_after_update
    AFTER UPDATE
    ON rating
    FOR EACH ROW
    INSERT INTO rating_history (rating_id, product_id, user_id, value, created_by, created_dt, modified_by, modified_dt,
                                deleted_dt, action_description)
    VALUES (NEW.rating_id, NEW.product_id, NEW.user_id, NEW.value, NEW.created_by, NEW.created_dt, NEW.modified_by,
            NEW.modified_dt, NEW.deleted_dt, COALESCE(@current_action_desc, 'System Unknown Action'))//

DELIMITER ;
