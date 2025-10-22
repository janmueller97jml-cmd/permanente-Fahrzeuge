-- SQL migration to add vehicle position and state columns to owned_vehicles table
-- This assumes the owned_vehicles table already exists (standard ESX/QBCore setup)

-- For MySQL 8.0+
ALTER TABLE `owned_vehicles` 
ADD COLUMN IF NOT EXISTS `parking_position` LONGTEXT DEFAULT NULL COMMENT 'JSON: Vehicle position (x,y,z,heading)',
ADD COLUMN IF NOT EXISTS `parking_damage` LONGTEXT DEFAULT NULL COMMENT 'JSON: Vehicle damage state',
ADD COLUMN IF NOT EXISTS `last_parked` TIMESTAMP NULL DEFAULT NULL COMMENT 'Last time vehicle was parked';

-- Index for faster queries
CREATE INDEX IF NOT EXISTS `idx_owned_vehicles_plate` ON `owned_vehicles` (`plate`);

-- Alternative for MySQL 5.7 and older (if above fails, use this instead):
-- ALTER TABLE `owned_vehicles` ADD COLUMN `parking_position` LONGTEXT DEFAULT NULL COMMENT 'JSON: Vehicle position (x,y,z,heading)';
-- ALTER TABLE `owned_vehicles` ADD COLUMN `parking_damage` LONGTEXT DEFAULT NULL COMMENT 'JSON: Vehicle damage state';
-- ALTER TABLE `owned_vehicles` ADD COLUMN `last_parked` TIMESTAMP NULL DEFAULT NULL COMMENT 'Last time vehicle was parked';
-- CREATE INDEX `idx_owned_vehicles_plate` ON `owned_vehicles` (`plate`);
