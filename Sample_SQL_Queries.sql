-- ========================================
-- WAREHOUSE MANAGEMENT SYSTEM
-- Sample SQL Queries for Data Analysis
-- ========================================

-- ========================================
-- SECTION 1: DATA CLEANING QUERIES
-- ========================================

-- 1.1 Find duplicate SKUs in inventory
SELECT 
    SKU,
    COUNT(*) as DuplicateCount,
    STRING_AGG(CAST(Product_Name AS VARCHAR(MAX)), ', ') as ProductNames
FROM Inventory
GROUP BY SKU
HAVING COUNT(*) > 1
ORDER BY DuplicateCount DESC;

-- 1.2 Identify negative stock quantities
SELECT 
    SKU,
    Product_Name,
    Quantity_On_Hand,
    Warehouse,
    Location,
    Last_Stock_Check
FROM Inventory
WHERE Quantity_On_Hand < 0
ORDER BY Quantity_On_Hand ASC;

-- 1.3 Find orders with missing or null prices
SELECT 
    Order_ID,
    Order_Date,
    Customer_Name,
    SKU,
    Quantity_Ordered,
    Unit_Price,
    Total_Value
FROM Orders
WHERE Unit_Price IS NULL OR Total_Value IS NULL;

-- 1.4 Identify orphaned orders (SKUs not in inventory)
SELECT 
    o.Order_ID,
    o.SKU,
    o.Product_Name,
    o.Order_Date,
    o.Customer_Name
FROM Orders o
LEFT JOIN Inventory i ON o.SKU = i.SKU
WHERE i.SKU IS NULL;

-- 1.5 Find delivery dates before order dates
SELECT 
    Order_ID,
    Order_Date,
    Delivery_Date,
    Customer_Name,
    DATEDIFF(day, TRY_CAST(Delivery_Date AS DATE), TRY_CAST(Order_Date AS DATE)) as DateDiscrepancy
FROM Orders
WHERE TRY_CAST(Delivery_Date AS DATE) < TRY_CAST(Order_Date AS DATE);

-- 1.6 Standardize warehouse names
SELECT DISTINCT
    Warehouse,
    COUNT(*) as RecordCount,
    CASE 
        WHEN UPPER(TRIM(Warehouse)) = 'LONDON DC' THEN 'London DC'
        WHEN UPPER(TRIM(Warehouse)) = 'LONDON' THEN 'London DC'
        WHEN UPPER(TRIM(Warehouse)) = 'LDN' THEN 'London DC'
        WHEN UPPER(TRIM(Warehouse)) LIKE '%MANCHESTER%' THEN 'Manchester DC'
        WHEN UPPER(TRIM(Warehouse)) LIKE '%BIRMINGHAM%' THEN 'Birmingham DC'
        ELSE Warehouse
    END as StandardizedWarehouse
FROM Inventory
GROUP BY Warehouse
ORDER BY RecordCount DESC;

-- 1.7 Check for overloaded vehicles
SELECT 
    Vehicle_ID,
    Vehicle_Type,
    Capacity_KG,
    Current_Load_KG,
    (Current_Load_KG - Capacity_KG) as ExcessLoad,
    ROUND((Current_Load_KG * 100.0 / Capacity_KG), 2) as LoadPercentage
FROM Transport
WHERE Current_Load_KG > Capacity_KG
ORDER BY ExcessLoad DESC;

-- ========================================
-- SECTION 2: INVENTORY ANALYSIS
-- ========================================

-- 2.1 Items below reorder point (need restocking)
SELECT 
    SKU,
    Product_Name,
    Category,
    Quantity_On_Hand,
    Reorder_Point,
    Reorder_Quantity,
    (Reorder_Point - Quantity_On_Hand) as UnitsNeeded,
    Supplier_ID,
    Lead_Time_Days
FROM Inventory
WHERE Quantity_On_Hand < Reorder_Point
    AND Quantity_On_Hand >= 0  -- Exclude data errors
ORDER BY UnitsNeeded DESC;

-- 2.2 Stock value by category
SELECT 
    Category,
    COUNT(*) as ItemCount,
    SUM(Quantity_On_Hand) as TotalUnits,
    AVG(Unit_Cost_GBP) as AvgUnitCost,
    SUM(Quantity_On_Hand * ISNULL(Unit_Cost_GBP, 0)) as TotalValue
FROM Inventory
WHERE Quantity_On_Hand >= 0
GROUP BY Category
ORDER BY TotalValue DESC;

-- 2.3 ABC Analysis (classify inventory by value)
WITH InventoryValue AS (
    SELECT 
        SKU,
        Product_Name,
        Category,
        Quantity_On_Hand,
        Unit_Cost_GBP,
        (Quantity_On_Hand * ISNULL(Unit_Cost_GBP, 0)) as TotalValue
    FROM Inventory
    WHERE Quantity_On_Hand >= 0
),
RankedInventory AS (
    SELECT 
        *,
        SUM(TotalValue) OVER () as GrandTotal,
        SUM(TotalValue) OVER (ORDER BY TotalValue DESC) as RunningTotal
    FROM InventoryValue
)
SELECT 
    SKU,
    Product_Name,
    Category,
    TotalValue,
    ROUND((RunningTotal * 100.0 / GrandTotal), 2) as CumulativePercentage,
    CASE 
        WHEN (RunningTotal * 100.0 / GrandTotal) <= 80 THEN 'A'
        WHEN (RunningTotal * 100.0 / GrandTotal) <= 95 THEN 'B'
        ELSE 'C'
    END as ABC_Classification
FROM RankedInventory
ORDER BY TotalValue DESC;

-- 2.4 Stock-out items (zero quantity)
SELECT 
    SKU,
    Product_Name,
    Category,
    Warehouse,
    Last_Stock_Check,
    Supplier_ID,
    Lead_Time_Days
FROM Inventory
WHERE Quantity_On_Hand = 0
ORDER BY Category, Product_Name;

-- 2.5 Stock ageing analysis (days since last check)
SELECT 
    Warehouse,
    COUNT(*) as TotalItems,
    AVG(DATEDIFF(day, TRY_CAST(Last_Stock_Check AS DATE), GETDATE())) as AvgDaysSinceCheck,
    SUM(CASE WHEN DATEDIFF(day, TRY_CAST(Last_Stock_Check AS DATE), GETDATE()) > 30 THEN 1 ELSE 0 END) as ItemsOver30Days,
    SUM(CASE WHEN DATEDIFF(day, TRY_CAST(Last_Stock_Check AS DATE), GETDATE()) > 60 THEN 1 ELSE 0 END) as ItemsOver60Days
FROM Inventory
WHERE Last_Stock_Check IS NOT NULL AND Last_Stock_Check != ''
GROUP BY Warehouse;

-- 2.6 Warehouse capacity analysis
SELECT 
    Warehouse,
    COUNT(*) as SKU_Count,
    SUM(Quantity_On_Hand) as TotalUnits,
    COUNT(DISTINCT Location) as UniqueLocations,
    AVG(Quantity_On_Hand) as AvgQtyPerSKU
FROM Inventory
WHERE Warehouse IS NOT NULL AND Warehouse != ''
    AND Quantity_On_Hand >= 0
GROUP BY Warehouse
ORDER BY TotalUnits DESC;

-- ========================================
-- SECTION 3: ORDER ANALYSIS
-- ========================================

-- 3.1 Order statistics by status
SELECT 
    UPPER(TRIM(Order_Status)) as Status,
    COUNT(*) as OrderCount,
    SUM(Quantity_Ordered) as TotalUnits,
    AVG(Total_Value) as AvgOrderValue,
    SUM(Total_Value) as TotalValue
FROM Orders
WHERE Order_Status IS NOT NULL AND Order_Status != ''
GROUP BY UPPER(TRIM(Order_Status))
ORDER BY OrderCount DESC;

-- 3.2 Top customers by order value
SELECT 
    Customer_ID,
    Customer_Name,
    COUNT(*) as OrderCount,
    SUM(Quantity_Ordered) as TotalUnits,
    SUM(Total_Value) as TotalSpend,
    AVG(Total_Value) as AvgOrderValue
FROM Orders
WHERE Customer_Name IS NOT NULL AND Customer_Name != ''
    AND Total_Value IS NOT NULL
GROUP BY Customer_ID, Customer_Name
ORDER BY TotalSpend DESC;

-- 3.3 Order cycle time (order to delivery)
SELECT 
    Order_ID,
    Customer_Name,
    Order_Date,
    Delivery_Date,
    DATEDIFF(day, TRY_CAST(Order_Date AS DATE), TRY_CAST(Delivery_Date AS DATE)) as CycleTimeDays
FROM Orders
WHERE Order_Date IS NOT NULL 
    AND Delivery_Date IS NOT NULL
    AND TRY_CAST(Delivery_Date AS DATE) >= TRY_CAST(Order_Date AS DATE)
ORDER BY CycleTimeDays DESC;

-- 3.4 Average order cycle time by priority
SELECT 
    UPPER(TRIM(Priority)) as Priority,
    COUNT(*) as OrderCount,
    AVG(DATEDIFF(day, TRY_CAST(Order_Date AS DATE), TRY_CAST(Delivery_Date AS DATE))) as AvgCycleTimeDays,
    MIN(DATEDIFF(day, TRY_CAST(Order_Date AS DATE), TRY_CAST(Delivery_Date AS DATE))) as MinCycleTimeDays,
    MAX(DATEDIFF(day, TRY_CAST(Order_Date AS DATE), TRY_CAST(Delivery_Date AS DATE))) as MaxCycleTimeDays
FROM Orders
WHERE Order_Date IS NOT NULL 
    AND Delivery_Date IS NOT NULL
    AND TRY_CAST(Delivery_Date AS DATE) >= TRY_CAST(Order_Date AS DATE)
    AND Priority IS NOT NULL AND Priority != ''
GROUP BY UPPER(TRIM(Priority));

-- 3.5 Most frequently ordered products
SELECT 
    o.SKU,
    i.Product_Name,
    i.Category,
    COUNT(*) as OrderCount,
    SUM(o.Quantity_Ordered) as TotalQuantity,
    AVG(o.Unit_Price) as AvgPrice,
    SUM(o.Total_Value) as TotalRevenue
FROM Orders o
LEFT JOIN Inventory i ON o.SKU = i.SKU
GROUP BY o.SKU, i.Product_Name, i.Category
ORDER BY TotalQuantity DESC;

-- 3.6 Orders with calculation discrepancies
SELECT 
    Order_ID,
    SKU,
    Quantity_Ordered,
    Unit_Price,
    Total_Value,
    (Quantity_Ordered * Unit_Price) as CalculatedTotal,
    ABS(Total_Value - (Quantity_Ordered * Unit_Price)) as Discrepancy
FROM Orders
WHERE Unit_Price IS NOT NULL 
    AND Total_Value IS NOT NULL
    AND ABS(Total_Value - (Quantity_Ordered * Unit_Price)) > 0.01
ORDER BY Discrepancy DESC;

-- ========================================
-- SECTION 4: TRANSPORT ANALYSIS
-- ========================================

-- 4.1 Vehicle utilisation summary
SELECT 
    Vehicle_Type,
    COUNT(*) as VehicleCount,
    AVG(Capacity_KG) as AvgCapacity,
    AVG(Current_Load_KG) as AvgLoad,
    AVG((Current_Load_KG * 100.0 / NULLIF(Capacity_KG, 0))) as AvgUtilisation,
    SUM(CASE WHEN Current_Load_KG > Capacity_KG THEN 1 ELSE 0 END) as OverloadedCount
FROM Transport
GROUP BY Vehicle_Type
ORDER BY AvgUtilisation DESC;

-- 4.2 Driver performance metrics
SELECT 
    Driver_ID,
    Driver_Name,
    COUNT(*) as TripCount,
    AVG(Distance_KM) as AvgDistance,
    SUM(Distance_KM) as TotalDistance,
    AVG(Fuel_Consumption_L) as AvgFuelConsumption,
    AVG(Fuel_Consumption_L / NULLIF(Distance_KM, 0)) as FuelEfficiency_L_per_KM,
    AVG(Delivery_Count) as AvgDeliveriesPerTrip
FROM Transport
WHERE Driver_Name IS NOT NULL AND Driver_Name != ''
GROUP BY Driver_ID, Driver_Name
ORDER BY TotalDistance DESC;

-- 4.3 On-time delivery performance
SELECT 
    Vehicle_Type,
    COUNT(*) as TotalTrips,
    SUM(CASE 
        WHEN TRY_CAST(Actual_Arrival AS DATETIME) <= TRY_CAST(Expected_Arrival AS DATETIME) 
        THEN 1 ELSE 0 
    END) as OnTimeTrips,
    ROUND(
        SUM(CASE 
            WHEN TRY_CAST(Actual_Arrival AS DATETIME) <= TRY_CAST(Expected_Arrival AS DATETIME) 
            THEN 1.0 ELSE 0 
        END) * 100.0 / COUNT(*),
        2
    ) as OnTimePercentage,
    AVG(
        DATEDIFF(
            minute, 
            TRY_CAST(Expected_Arrival AS DATETIME), 
            TRY_CAST(Actual_Arrival AS DATETIME)
        )
    ) as AvgDelayMinutes
FROM Transport
WHERE Actual_Arrival IS NOT NULL AND Actual_Arrival != ''
    AND Expected_Arrival IS NOT NULL AND Expected_Arrival != ''
GROUP BY Vehicle_Type;

-- 4.4 Route efficiency analysis
SELECT 
    Route_ID,
    COUNT(*) as TripCount,
    AVG(Distance_KM) as AvgDistance,
    AVG(Delivery_Count) as AvgDeliveries,
    AVG(Distance_KM / NULLIF(Delivery_Count, 0)) as KM_per_Delivery,
    AVG(Fuel_Consumption_L) as AvgFuelConsumption
FROM Transport
GROUP BY Route_ID
HAVING COUNT(*) > 1
ORDER BY KM_per_Delivery ASC;

-- 4.5 Vehicle status summary
SELECT 
    UPPER(TRIM(Status)) as Status,
    COUNT(*) as VehicleCount,
    AVG(Current_Load_KG) as AvgLoad,
    AVG(Distance_KM) as AvgDistance,
    SUM(Distance_KM) as TotalDistance
FROM Transport
WHERE Status IS NOT NULL AND Status != ''
GROUP BY UPPER(TRIM(Status))
ORDER BY VehicleCount DESC;

-- ========================================
-- SECTION 5: SUPPLIER ANALYSIS
-- ========================================

-- 5.1 Supplier performance scorecard
SELECT 
    Supplier_ID,
    Supplier_Name,
    Total_Orders_YTD,
    [On_Time_Delivery_%] as OnTimeDeliveryPct,
    [Quality_Score_%] as QualityScorePct,
    Lead_Time_Days,
    Total_Spend_GBP,
    ROUND(Total_Spend_GBP / NULLIF(Total_Orders_YTD, 0), 2) as AvgOrderValue,
    CASE 
        WHEN UPPER(TRIM(Active_Status)) IN ('ACTIVE') THEN 'Active'
        WHEN UPPER(TRIM(Active_Status)) IN ('INACTIVE') THEN 'Inactive'
        ELSE Active_Status
    END as Status
FROM Suppliers
ORDER BY Total_Spend_GBP DESC;

-- 5.2 Top suppliers by spend
SELECT TOP 10
    Supplier_ID,
    Supplier_Name,
    Total_Spend_GBP,
    Total_Orders_YTD,
    [On_Time_Delivery_%],
    [Quality_Score_%],
    Payment_Terms
FROM Suppliers
WHERE Active_Status IS NOT NULL
ORDER BY Total_Spend_GBP DESC;

-- 5.3 Suppliers needing attention (poor performance)
SELECT 
    Supplier_ID,
    Supplier_Name,
    [On_Time_Delivery_%] as OnTimeDeliveryPct,
    [Quality_Score_%] as QualityScorePct,
    Lead_Time_Days,
    Total_Orders_YTD,
    Total_Spend_GBP
FROM Suppliers
WHERE ([On_Time_Delivery_%] < 85 OR [Quality_Score_%] < 85)
    AND UPPER(TRIM(Active_Status)) = 'ACTIVE'
ORDER BY [On_Time_Delivery_%] ASC;

-- 5.4 Supplier concentration risk
WITH SupplierSpend AS (
    SELECT 
        Supplier_ID,
        Supplier_Name,
        Total_Spend_GBP,
        SUM(Total_Spend_GBP) OVER () as TotalSpend
    FROM Suppliers
)
SELECT 
    Supplier_ID,
    Supplier_Name,
    Total_Spend_GBP,
    ROUND((Total_Spend_GBP * 100.0 / TotalSpend), 2) as SpendPercentage,
    SUM(ROUND((Total_Spend_GBP * 100.0 / TotalSpend), 2)) 
        OVER (ORDER BY Total_Spend_GBP DESC) as CumulativePercentage
FROM SupplierSpend
ORDER BY Total_Spend_GBP DESC;

-- 5.5 Supplier reliability index
SELECT 
    Supplier_ID,
    Supplier_Name,
    ROUND(
        ([On_Time_Delivery_%] * 0.4 + 
         [Quality_Score_%] * 0.4 + 
         (100 - (Lead_Time_Days * 2)) * 0.2),
        2
    ) as ReliabilityScore,
    [On_Time_Delivery_%],
    [Quality_Score_%],
    Lead_Time_Days,
    Total_Orders_YTD
FROM Suppliers
WHERE Active_Status IS NOT NULL
ORDER BY ReliabilityScore DESC;

-- ========================================
-- SECTION 6: CROSS-FUNCTIONAL ANALYSIS
-- ========================================

-- 6.1 Inventory turnover by supplier
SELECT 
    i.Supplier_ID,
    s.Supplier_Name,
    COUNT(DISTINCT i.SKU) as SKU_Count,
    SUM(i.Quantity_On_Hand) as CurrentStock,
    COUNT(o.Order_ID) as OrderCount,
    SUM(o.Quantity_Ordered) as TotalSold,
    ROUND(
        SUM(o.Quantity_Ordered) * 1.0 / NULLIF(SUM(i.Quantity_On_Hand), 0),
        2
    ) as TurnoverRatio
FROM Inventory i
LEFT JOIN Orders o ON i.SKU = o.SKU
LEFT JOIN Suppliers s ON i.Supplier_ID = s.Supplier_ID
GROUP BY i.Supplier_ID, s.Supplier_Name
ORDER BY TurnoverRatio DESC;

-- 6.2 Order fulfillment efficiency by warehouse
SELECT 
    i.Warehouse,
    COUNT(DISTINCT o.Order_ID) as TotalOrders,
    AVG(DATEDIFF(day, TRY_CAST(o.Order_Date AS DATE), TRY_CAST(o.Delivery_Date AS DATE))) as AvgFulfillmentDays,
    SUM(CASE WHEN UPPER(TRIM(o.Order_Status)) LIKE '%COMPLETE%' THEN 1 ELSE 0 END) as CompletedOrders,
    SUM(CASE WHEN UPPER(TRIM(o.Order_Status)) = 'CANCELLED' THEN 1 ELSE 0 END) as CancelledOrders
FROM Orders o
INNER JOIN Inventory i ON o.SKU = i.SKU
WHERE i.Warehouse IS NOT NULL AND i.Warehouse != ''
GROUP BY i.Warehouse
ORDER BY AvgFulfillmentDays ASC;

-- 6.3 Product category performance
SELECT 
    i.Category,
    COUNT(DISTINCT i.SKU) as SKU_Count,
    SUM(i.Quantity_On_Hand) as CurrentStock,
    COUNT(o.Order_ID) as OrderCount,
    SUM(o.Quantity_Ordered) as TotalSold,
    SUM(o.Total_Value) as TotalRevenue,
    AVG(i.Unit_Cost_GBP) as AvgUnitCost,
    AVG(o.Unit_Price) as AvgSellingPrice
FROM Inventory i
LEFT JOIN Orders o ON i.SKU = o.SKU
GROUP BY i.Category
ORDER BY TotalRevenue DESC;

-- ========================================
-- SECTION 7: DATA QUALITY METRICS
-- ========================================

-- 7.1 Data completeness by table
SELECT 
    'Inventory' as TableName,
    COUNT(*) as TotalRecords,
    SUM(CASE WHEN Unit_Cost_GBP IS NULL THEN 1 ELSE 0 END) as Missing_UnitCost,
    SUM(CASE WHEN Last_Stock_Check = '' OR Last_Stock_Check IS NULL THEN 1 ELSE 0 END) as Missing_LastCheck,
    SUM(CASE WHEN Location = '' OR Location IS NULL THEN 1 ELSE 0 END) as Missing_Location,
    SUM(CASE WHEN Warehouse = '' OR Warehouse IS NULL THEN 1 ELSE 0 END) as Missing_Warehouse
FROM Inventory

UNION ALL

SELECT 
    'Orders' as TableName,
    COUNT(*) as TotalRecords,
    SUM(CASE WHEN Unit_Price IS NULL THEN 1 ELSE 0 END) as Missing_UnitPrice,
    SUM(CASE WHEN Total_Value IS NULL THEN 1 ELSE 0 END) as Missing_TotalValue,
    SUM(CASE WHEN Customer_Name = '' OR Customer_Name IS NULL THEN 1 ELSE 0 END) as Missing_CustomerName,
    SUM(CASE WHEN Delivery_Date = '' OR Delivery_Date IS NULL THEN 1 ELSE 0 END) as Missing_DeliveryDate
FROM Orders

UNION ALL

SELECT 
    'Transport' as TableName,
    COUNT(*) as TotalRecords,
    SUM(CASE WHEN Driver_Name = '' OR Driver_Name IS NULL THEN 1 ELSE 0 END) as Missing_DriverName,
    SUM(CASE WHEN Actual_Arrival = '' OR Actual_Arrival IS NULL THEN 1 ELSE 0 END) as Missing_ActualArrival,
    NULL as Missing_Field3,
    NULL as Missing_Field4
FROM Transport;

-- 7.2 Data quality issues summary
SELECT 
    'Duplicate SKUs' as IssueType,
    COUNT(*) as IssueCount
FROM (
    SELECT SKU
    FROM Inventory
    GROUP BY SKU
    HAVING COUNT(*) > 1
) duplicates

UNION ALL

SELECT 
    'Negative Stock' as IssueType,
    COUNT(*) as IssueCount
FROM Inventory
WHERE Quantity_On_Hand < 0

UNION ALL

SELECT 
    'Orphaned Orders' as IssueType,
    COUNT(*) as IssueCount
FROM Orders o
LEFT JOIN Inventory i ON o.SKU = i.SKU
WHERE i.SKU IS NULL

UNION ALL

SELECT 
    'Invalid Delivery Dates' as IssueType,
    COUNT(*) as IssueCount
FROM Orders
WHERE TRY_CAST(Delivery_Date AS DATE) < TRY_CAST(Order_Date AS DATE)

UNION ALL

SELECT 
    'Overloaded Vehicles' as IssueType,
    COUNT(*) as IssueCount
FROM Transport
WHERE Current_Load_KG > Capacity_KG;

-- ========================================
-- END OF SQL QUERIES
-- ========================================

/*
NOTES:
- These queries are designed for SQL Server syntax
- Adjust date parsing functions (TRY_CAST, GETDATE) for other databases
- Some queries use STRING_AGG which requires SQL Server 2017+
- Test queries on small datasets before running on full data
- Consider adding indexes on frequently queried columns
- Always validate results against business logic
*/
