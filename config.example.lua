-- Example Configuration Files

-- ============================================
-- Standard Configuration (Recommended)
-- ============================================
Config = {}
Config.SaveInterval = 300000  -- 5 minutes
Config.Debug = false
Config.OwnedVehiclesTable = 'owned_vehicles'


-- ============================================
-- High-Traffic Server Configuration
-- Less frequent saves to reduce database load
-- ============================================
-- Config = {}
-- Config.SaveInterval = 600000  -- 10 minutes
-- Config.Debug = false
-- Config.OwnedVehiclesTable = 'owned_vehicles'


-- ============================================
-- Development/Testing Configuration
-- Frequent saves and debug logging enabled
-- ============================================
-- Config = {}
-- Config.SaveInterval = 60000  -- 1 minute (for testing)
-- Config.Debug = true
-- Config.OwnedVehiclesTable = 'owned_vehicles'


-- ============================================
-- Custom Table Name Configuration
-- For servers using different database schema
-- ============================================
-- Config = {}
-- Config.SaveInterval = 300000  -- 5 minutes
-- Config.Debug = false
-- Config.OwnedVehiclesTable = 'player_vehicles'  -- Custom table name


-- ============================================
-- Configuration Notes:
-- ============================================

-- SaveInterval:
-- - Minimum recommended: 60000 (1 minute) - only for testing
-- - Maximum recommended: 900000 (15 minutes)
-- - Default: 300000 (5 minutes)
-- - Lower values = more database writes, more up-to-date positions
-- - Higher values = fewer database writes, positions may be slightly outdated

-- Debug:
-- - true: Enables detailed logging to help troubleshoot issues
-- - false: Only shows critical information
-- - Always set to false in production for better performance

-- OwnedVehiclesTable:
-- - Must match your database table name
-- - Standard ESX: 'owned_vehicles'
-- - Standard QBCore: 'player_vehicles'
-- - Make sure the table has the required columns after migration
