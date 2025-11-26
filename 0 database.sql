/*
    Sunrise Stationery T-SQL implementation (simplified schema naming)
    - Creates core tables with business rule constraints
    - Inserts sample data
    - Provides helper procedure for confirming orders with stock validation
    - Supplies example report queries
*/

-- Recreate database
DROP DATABASE IF EXISTS Stationery
GO
CREATE DATABASE Stationery
GO
USE Stationery
GO