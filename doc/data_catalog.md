# Data architecture in gold layer.

### 📘 `dim_customer` — Customer Dimension Table

Contains descriptive information about each customer.

| Column Name       | Data Type  | Description                                                                     |
| ----------------- | ---------- | ------------------------------------------------------------------------------- |
| `customer_key`    | `bigint`   | Surrogate key for the customer. |
| `customer_id`     | `int`      | Source system ID of the customer (e.g., from a CRM or ERP).                     |
| `customer_number` | `nvarchar` | Unique business/customer number (external identifier).                          |
| `first_name`      | `nvarchar` | Customer’s first name.                                                          |
| `last_name`       | `nvarchar` | Customer’s last name.                                                           |
| `country`         | `nvarchar` | Country of residence .                                              |
| `gender`          | `nvarchar` | Customer’s gender (e.g., 'Male', 'Female').                                     |
| `marital_status`  | `nvarchar` | Marital status (e.g., 'Single', 'Married').                                     |
| `birthdate`       | `date`     | Customer’s date of birth.                                                       |
| `create_date`     | `date`     | Date the customer record was created in the system.                             |

---

### 📘 `dim_product` — Product Dimension Table

Describes product-related information.

| Column Name      | Data Type  | Description                                                           |
| ---------------- | ---------- | --------------------------------------------------------------------- |
| `product_key`    | `bigint`   | Surrogate key for the product (used for joins in the data warehouse). |
| `product_id`     | `int`      | Original product ID from the source system.                           |
| `product_number` | `nvarchar` | Unique product code/number (used in the business).                    |
| `product_name`   | `nvarchar` | Name of the product.                                                  |
| `category_key`   | `nvarchar` | ID for the product’s category.                                        |
| `category`       | `nvarchar` | Name of the product category (e.g., 'Clothing').                   |
| `subcategory`    | `nvarchar` | Name of the product subcategory (e.g., 'Socks').                                      |
| `maintenance`    | `nvarchar` | Indicates if the product requires maintenance ('Yes' / 'No').         |
| `cost`           | `int`      | Cost to produce or purchase the product (used in margin analysis).    |
| `product_line`   | `nvarchar` | Brand or product line (e.g., 'Road').                           |
| `start_date`     | `date`     | Date the product became available with this cost.                                    |

---

### 📘 `fact_sales` — Sales Fact Table

Stores transactional sales data, linking customers and products.

| Column Name    | Data Type  | Description                                        |
| -------------- | ---------- | -------------------------------------------------- |
| `sls_ord_num`  | `nvarchar` | Sales order number (transaction ID).               |
| `product_key`  | `bigint`   | Foreign key to `dim_product`.                      |
| `customer_key` | `bigint`   | Foreign key to `dim_customer`.                     |
| `sls_order_dt` | `date`     | Date the order was placed.                         |
| `sls_ship_dt`  | `date`     | Date the product was shipped.                      |
| `sls_due_dt`   | `date`     | Expected delivery date.                            |
| `sls_sales`    | `int`      | Revenue for this transaction. Equals to sls_quantity * sls_price  |
| `sls_quantity` | `int`      | Number of units sold.                              |
| `sls_price`    | `int`      | Price per unit at the time of sale.                |
