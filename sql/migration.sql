-- SQL migration to add vehicle position and state columns to owned_vehicles table
-- This assumes the owned_vehicles table already exists (standard ESX/QBCore setup)

ALTER TABLE `owned_vehicles` 
ADD COLUMN IF NOT EXISTS `parking_position` LONGTEXT DEFAULT NULL COMMENT 'JSON: Vehicle position (x,y,z,heading)',
ADD COLUMN IF NOT EXISTS `parking_damage` LONGTEXT DEFAULT NULL COMMENT 'JSON: Vehicle damage state',
ADD COLUMN IF NOT EXISTS `last_parked` TIMESTAMP NULL DEFAULT NULL COMMENT 'Last time vehicle was parked';

-- Index for faster queries
CREATE INDEX IF NOT EXISTS `idx_owned_vehicles_plate` ON `owned_vehicles` (`plate`);
