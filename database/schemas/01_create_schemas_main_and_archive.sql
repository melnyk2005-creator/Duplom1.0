
-- Main schema: operational database (e.g. ecommerce or your app name)
CREATE DATABASE IF NOT EXISTS ecommerce
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci
  COMMENT 'Main operational schema';

-- Archive schema: same structure used to store rows moved from main where deleted_dt is set and older than 1 year
CREATE DATABASE IF NOT EXISTS ecommerce_archive
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci
  COMMENT 'Archive schema for soft-deleted data older than 1 year';
