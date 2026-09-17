Create database ecommerce_db;
USE ecommerce_db;


-- =========================================================
-- 1. DATA OVERVIEW
-- =========================================================

SELECT COUNT(*) AS total_customers
FROM customers;

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT COUNT(*) AS total_products
FROM products;

SELECT COUNT(*) AS total_order_items
FROM order_items;

SELECT COUNT(*) AS total_payments
FROM payments;

SELECT COUNT(*) AS total_returns
FROM returns;


-- =========================================================
-- 2. ORDER STATUS ANALYSIS
-- =========================================================

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- =========================================================
-- 3. PAYMENT STATUS ANALYSIS
-- =========================================================

SELECT
    payment_status,
    COUNT(*) AS total_payments,
    ROUND(SUM(payment_amount), 2) AS total_amount
FROM payments
GROUP BY payment_status
ORDER BY total_payments DESC;


-- =========================================================
-- 4. TOTAL DELIVERED SALES REVENUE
-- =========================================================

SELECT
    ROUND(
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ),
        2
    ) AS delivered_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';


-- =========================================================
-- 5. TOTAL UNITS SOLD IN DELIVERED ORDERS
-- =========================================================

SELECT
    SUM(oi.quantity) AS total_units_sold
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';


-- =========================================================
-- 6. AVERAGE ORDER VALUE
-- =========================================================

SELECT
    ROUND(
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        )
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';


-- =========================================================
-- 7. TOTAL DISCOUNT GIVEN ON DELIVERED ORDERS
-- =========================================================

SELECT
    ROUND(
        SUM(
            oi.quantity *
            oi.unit_price *
            oi.discount / 100
        ),
        2
    ) AS total_discount
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';


-- =========================================================
-- 8. MONTHLY REVENUE
-- =========================================================

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    ROUND(
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ),
        2
    ) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;


-- =========================================================
-- 9. MONTHLY ORDERS
-- =========================================================

SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(*) AS total_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;


-- =========================================================
-- 10. MONTHLY UNITS SOLD
-- =========================================================

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(oi.quantity) AS units_sold
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;


-- =========================================================
-- 11. TOP 10 PRODUCTS BY REVENUE
-- =========================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,
    ROUND(
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ),
        2
    ) AS revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY revenue DESC
LIMIT 10;


-- =========================================================
-- 12. TOP 10 PRODUCTS BY UNITS SOLD
-- =========================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY units_sold DESC
LIMIT 10;


-- =========================================================
-- 13. PRODUCT RATINGS
-- =========================================================

SELECT
    product_id,
    product_name,
    category,
    rating
FROM products
ORDER BY rating DESC
LIMIT 10;


-- =========================================================
-- 14. LOW STOCK PRODUCTS
-- =========================================================

SELECT
    product_id,
    product_name,
    category,
    stock_quantity
FROM products
WHERE stock_quantity < 20
ORDER BY stock_quantity ASC;


-- =========================================================
-- 15. REVENUE BY CATEGORY
-- =========================================================

SELECT
    p.category,
    ROUND(
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ),
        2
    ) AS revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.category
ORDER BY revenue DESC;


-- =========================================================
-- 16. UNITS SOLD BY CATEGORY
-- =========================================================

SELECT
    p.category,
    SUM(oi.quantity) AS units_sold
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.category
ORDER BY units_sold DESC;


-- =========================================================
-- 17. REVENUE BY SUB-CATEGORY
-- =========================================================

SELECT
    p.sub_category,
    ROUND(
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ),
        2
    ) AS revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.sub_category
ORDER BY revenue DESC;


-- =========================================================
-- 18. CUSTOMER SEGMENT SIZE
-- =========================================================

SELECT
    customer_segment,
    COUNT(*) AS total_customers
FROM customers
GROUP BY customer_segment
ORDER BY total_customers DESC;


-- =========================================================
-- 19. CUSTOMER REVENUE
-- =========================================================

SELECT
    c.customer_id,
    c.customer_name,
    ROUND(
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ),
        2
    ) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_spent DESC;


-- =========================================================
-- 20. TOP 10 CUSTOMERS
-- =========================================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ),
        2
    ) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_spent DESC
LIMIT 10;


-- =========================================================
-- 21. REVENUE BY CUSTOMER SEGMENT
-- =========================================================

SELECT
    c.customer_segment,
    ROUND(
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ),
        2
    ) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_segment
ORDER BY revenue DESC;


-- =========================================================
-- 22. REVENUE BY CITY
-- =========================================================

SELECT
    c.city,
    ROUND(
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ),
        2
    ) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.city
ORDER BY revenue DESC
LIMIT 10;


-- =========================================================
-- 23. REVENUE BY STATE
-- =========================================================

SELECT
    c.state,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ),
        2
    ) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.state
ORDER BY revenue DESC;


-- =========================================================
-- 24. ACQUISITION CHANNEL
-- =========================================================

SELECT
    acquisition_channel,
    COUNT(*) AS customers
FROM customers
GROUP BY acquisition_channel
ORDER BY customers DESC;


-- =========================================================
-- 25. REVENUE BY ACQUISITION CHANNEL
-- =========================================================

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ),
        2
    ) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.acquisition_channel
ORDER BY revenue DESC;


-- =========================================================
-- 26. PAYMENT METHOD - PAID PAYMENTS ONLY
-- =========================================================

SELECT
    o.payment_method,
    COUNT(*) AS paid_payments,
    ROUND(
        SUM(p.payment_amount),
        2
    ) AS paid_amount
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id
WHERE p.payment_status = 'paid'
GROUP BY o.payment_method
ORDER BY paid_amount DESC;


-- =========================================================
-- 27. PAYMENT STATUS SUMMARY
-- =========================================================

SELECT
    payment_status,
    COUNT(*) AS payments,
    ROUND(
        SUM(payment_amount),
        2
    ) AS amount
FROM payments
GROUP BY payment_status
ORDER BY amount DESC;


-- =========================================================
-- 28. TOTAL SUCCESSFUL PAYMENT AMOUNT
-- =========================================================

SELECT
    ROUND(
        SUM(payment_amount),
        2
    ) AS successful_payment_amount
FROM payments
WHERE payment_status = 'paid';


-- =========================================================
-- 29. TOTAL REFUND AMOUNT
-- =========================================================

SELECT
    ROUND(
        SUM(refund_amount),
        2
    ) AS total_refund
FROM returns;


-- =========================================================
-- 30. RETURN REASONS
-- =========================================================

SELECT
    return_reason,
    COUNT(*) AS return_records,
    SUM(return_quantity) AS returned_units,
    ROUND(
        SUM(refund_amount),
        2
    ) AS refund_amount
FROM returns
GROUP BY return_reason
ORDER BY returned_units DESC;


-- =========================================================
-- 31. TOP RETURNED PRODUCTS
-- =========================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(r.return_quantity) AS returned_units,
    ROUND(
        SUM(r.refund_amount),
        2
    ) AS refund_amount
FROM returns r
JOIN products p
    ON r.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY returned_units DESC
LIMIT 10;


-- =========================================================
-- 32. RETURN RATE
-- Returned units / units sold in delivered orders
-- =========================================================

SELECT
    (
        SELECT SUM(return_quantity)
        FROM returns
    ) AS returned_units,

    (
        SELECT SUM(oi.quantity)
        FROM orders o
        JOIN order_items oi
            ON o.order_id = oi.order_id
        WHERE o.order_status = 'delivered'
    ) AS delivered_units,

    ROUND(
        (
            SELECT SUM(return_quantity)
            FROM returns
        )
        /
        NULLIF(
            (
                SELECT SUM(oi.quantity)
                FROM orders o
                JOIN order_items oi
                    ON o.order_id = oi.order_id
                WHERE o.order_status = 'delivered'
            ),
            0
        ) * 100,
        2
    ) AS return_rate_percentage;


-- =========================================================
-- 33. AVERAGE DELIVERY DAYS
-- =========================================================

SELECT
    ROUND(
        AVG(
            DATEDIFF(delivery_date, order_date)
        ),
        2
    ) AS average_delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND delivery_date IS NOT NULL;


-- =========================================================
-- 34. ORDERS TAKING MORE THAN 7 DAYS
-- =========================================================

SELECT
    order_id,
    order_date,
    delivery_date,
    DATEDIFF(
        delivery_date,
        order_date
    ) AS delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND delivery_date IS NOT NULL
  AND DATEDIFF(
        delivery_date,
        order_date
      ) > 7
ORDER BY delivery_days DESC;


-- =========================================================
-- 35. ESTIMATED GROSS PROFIT
-- =========================================================

SELECT
    ROUND(
        SUM(
            oi.quantity *
            (
                oi.unit_price *
                (1 - oi.discount / 100)
                - p.cost_price
            )
        ),
        2
    ) AS estimated_gross_profit
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';


-- =========================================================
-- 36. GROSS PROFIT BY CATEGORY
-- =========================================================

SELECT
    p.category,
    ROUND(
        SUM(
            oi.quantity *
            (
                oi.unit_price *
                (1 - oi.discount / 100)
                - p.cost_price
            )
        ),
        2
    ) AS estimated_gross_profit
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.category
ORDER BY estimated_gross_profit DESC;


-- =========================================================
-- 37. PROFIT MARGIN BY CATEGORY
-- =========================================================

SELECT
    p.category,

    ROUND(
        SUM(
            oi.quantity *
            (
                oi.unit_price *
                (1 - oi.discount / 100)
                - p.cost_price
            )
        ),
        2
    ) AS gross_profit,

    ROUND(
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ),
        2
    ) AS revenue,

    ROUND(
        SUM(
            oi.quantity *
            (
                oi.unit_price *
                (1 - oi.discount / 100)
                - p.cost_price
            )
        )
        /
        NULLIF(
            SUM(
                oi.quantity *
                oi.unit_price *
                (1 - oi.discount / 100)
            ),
            0
        ) * 100,
        2
    ) AS profit_margin_percentage

FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.category
ORDER BY profit_margin_percentage DESC;


-- =========================================================
-- 38. TOP CUSTOMERS WITH RANK
-- CTE + DENSE_RANK
-- =========================================================

WITH customer_sales AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        c.customer_id,
        c.customer_name
)
SELECT
    customer_id,
    customer_name,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS customer_rank
FROM customer_sales
ORDER BY customer_rank
LIMIT 20;


-- =========================================================
-- 39. TOP PRODUCTS WITH RANK
-- =========================================================

WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
)
SELECT
    product_id,
    product_name,
    category,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS product_rank
FROM product_sales
ORDER BY product_rank
LIMIT 20;


-- =========================================================
-- 40. CATEGORY RANKING
-- =========================================================

WITH category_sales AS (
    SELECT
        p.category,
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY p.category
)
SELECT
    category,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS category_rank
FROM category_sales
ORDER BY category_rank;


-- =========================================================
-- 41. MONTHLY REVENUE + RUNNING TOTAL
-- =========================================================

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(
            o.order_date,
            '%Y-%m'
        ) AS month,

        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ) AS revenue

    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY DATE_FORMAT(
        o.order_date,
        '%Y-%m'
    )
)

SELECT
    month,
    ROUND(revenue, 2) AS revenue,

    ROUND(
        SUM(revenue) OVER (
            ORDER BY month
        ),
        2
    ) AS running_revenue

FROM monthly_sales
ORDER BY month;


-- =========================================================
-- 42. MONTH-OVER-MONTH REVENUE GROWTH
-- =========================================================

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(
            o.order_date,
            '%Y-%m'
        ) AS month,

        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ) AS revenue

    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY DATE_FORMAT(
        o.order_date,
        '%Y-%m'
    )
),

monthly_comparison AS (
    SELECT
        month,
        revenue,

        LAG(revenue) OVER (
            ORDER BY month
        ) AS previous_revenue

    FROM monthly_sales
)

SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        previous_revenue,
        2
    ) AS previous_month_revenue,

    ROUND(
        (
            revenue - previous_revenue
        )
        /
        NULLIF(
            previous_revenue,
            0
        ) * 100,
        2
    ) AS mom_growth_percentage

FROM monthly_comparison
ORDER BY month;


-- =========================================================
-- 43. TOP 3 PRODUCTS WITHIN EACH CATEGORY
-- =========================================================

WITH product_sales AS (
    SELECT
        p.category,
        p.product_id,
        p.product_name,

        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ) AS revenue

    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        p.category,
        p.product_id,
        p.product_name
),

ranked_products AS (
    SELECT
        category,
        product_id,
        product_name,
        revenue,

        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS product_rank

    FROM product_sales
)

SELECT
    category,
    product_id,
    product_name,
    ROUND(revenue, 2) AS revenue,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY
    category,
    product_rank;


-- =========================================================
-- 44. CATEGORY CONTRIBUTION TO TOTAL REVENUE
-- =========================================================

WITH category_sales AS (
    SELECT
        p.category,

        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ) AS revenue

    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY p.category
)

SELECT
    category,
    ROUND(revenue, 2) AS revenue,

    ROUND(
        revenue
        /
        SUM(revenue) OVER () * 100,
        2
    ) AS revenue_share_percentage

FROM category_sales
ORDER BY revenue DESC;


-- =========================================================
-- 45. CUSTOMER SPENDING RANK
-- =========================================================

WITH customer_sales AS (
    SELECT
        c.customer_id,
        c.customer_name,

        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ) AS revenue

    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        c.customer_id,
        c.customer_name
)

SELECT
    customer_id,
    customer_name,
    ROUND(revenue, 2) AS revenue,

    ROW_NUMBER() OVER (
        ORDER BY revenue DESC
    ) AS row_number_rank,

    RANK() OVER (
        ORDER BY revenue DESC
    ) AS rank_number,

    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS dense_rank_number

FROM customer_sales
ORDER BY revenue DESC
LIMIT 20;


-- =========================================================
-- 46. DAILY SALES + 7 DAY MOVING AVERAGE
-- =========================================================

WITH daily_sales AS (
    SELECT
        o.order_date,

        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ) AS revenue

    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY o.order_date
)

SELECT
    order_date,
    ROUND(revenue, 2) AS daily_revenue,

    ROUND(
        AVG(revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING
            AND CURRENT ROW
        ),
        2
    ) AS moving_7_day_average

FROM daily_sales
ORDER BY order_date;


-- =========================================================
-- 47. REVENUE PER CUSTOMER BY ACQUISITION CHANNEL
-- =========================================================

WITH channel_sales AS (
    SELECT
        c.acquisition_channel,

        COUNT(
            DISTINCT c.customer_id
        ) AS customers,

        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount / 100)
        ) AS revenue

    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY c.acquisition_channel
)

SELECT
    acquisition_channel,
    customers,
    ROUND(revenue, 2) AS revenue,

    ROUND(
        revenue
        /
        NULLIF(customers, 0),
        2
    ) AS revenue_per_customer

FROM channel_sales
ORDER BY revenue DESC;


-- =========================================================
-- 48. REPEAT CUSTOMERS
-- =========================================================

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY customer_id
)

SELECT
    COUNT(*) AS repeat_customers
FROM customer_orders
WHERE total_orders > 1;


-- =========================================================
-- 49. ONE-TIME CUSTOMERS
-- =========================================================

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY customer_id
)

SELECT
    COUNT(*) AS one_time_customers
FROM customer_orders
WHERE total_orders = 1;


-- =========================================================
-- 50. FINAL PORTFOLIO KPI SUMMARY
-- =========================================================

SELECT

    -- Customers
    (
        SELECT COUNT(*)
        FROM customers
    ) AS total_customers,

    -- Delivered Orders
    (
        SELECT COUNT(*)
        FROM orders
        WHERE order_status = 'delivered'
    ) AS delivered_orders,

    -- Products
    (
        SELECT COUNT(*)
        FROM products
    ) AS total_products,

    -- Delivered Units
    (
        SELECT SUM(oi.quantity)
        FROM orders o
        JOIN order_items oi
            ON o.order_id = oi.order_id
        WHERE o.order_status = 'delivered'
    ) AS delivered_units_sold,

    -- Delivered Revenue
    ROUND(
        (
            SELECT SUM(
                oi.quantity *
                oi.unit_price *
                (1 - oi.discount / 100)
            )
            FROM orders o
            JOIN order_items oi
                ON o.order_id = oi.order_id
            WHERE o.order_status = 'delivered'
        ),
        2
    ) AS delivered_revenue,

    -- AOV
    ROUND(
        (
            SELECT SUM(
                oi.quantity *
                oi.unit_price *
                (1 - oi.discount / 100)
            )
            FROM orders o
            JOIN order_items oi
                ON o.order_id = oi.order_id
            WHERE o.order_status = 'delivered'
        )
        /
        NULLIF(
            (
                SELECT COUNT(DISTINCT order_id)
                FROM orders
                WHERE order_status = 'delivered'
            ),
            0
        ),
        2
    ) AS average_order_value,

    -- Return Rate
    ROUND(
        (
            SELECT SUM(return_quantity)
            FROM returns
        )
        /
        NULLIF(
            (
                SELECT SUM(oi.quantity)
                FROM orders o
                JOIN order_items oi
                    ON o.order_id = oi.order_id
                WHERE o.order_status = 'delivered'
            ),
            0
        ) * 100,
        2
    ) AS return_rate_percentage,

    -- Refund
    ROUND(
        (
            SELECT SUM(refund_amount)
            FROM returns
        ),
        2
    ) AS total_refund,

    -- Paid Amount
    ROUND(
        (
            SELECT SUM(payment_amount)
            FROM payments
            WHERE payment_status = 'paid'
        ),
        2
    ) AS successful_payment_amount,

    -- Estimated Gross Profit
    ROUND(
        (
            SELECT SUM(
                oi.quantity *
                (
                    oi.unit_price *
                    (1 - oi.discount / 100)
                    - p.cost_price
                )
            )
            FROM order_items oi
            JOIN products p
                ON oi.product_id = p.product_id
            JOIN orders o
                ON oi.order_id = o.order_id
            WHERE o.order_status = 'delivered'
        ),
        2
    ) AS estimated_gross_profit;