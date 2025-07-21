
USE master;
GO

-- Drop and recreate the 'OrderPractise' database
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE OrderPractise SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE OrderPractise;
END;
GO

-- Create the 'OrderPractise' database
CREATE DATABASE OrderPractise;
GO

USE OrderPractise;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
