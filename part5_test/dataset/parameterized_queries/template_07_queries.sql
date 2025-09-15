-- Template 7: 产品价格排名
-- Parameterized Template: SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > ? AND price > ?;

-- Variation 1
-- Parameters: {'stock': 40, 'min_price': 199}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 40 AND price > 199;

-- Variation 2
-- Parameters: {'stock': 44, 'min_price': 183}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 44 AND price > 183;

-- Variation 3
-- Parameters: {'stock': 46, 'min_price': 215}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 46 AND price > 215;

-- Variation 4
-- Parameters: {'stock': 20, 'min_price': 28}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 20 AND price > 28;

-- Variation 5
-- Parameters: {'stock': 27, 'min_price': 296}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 27 AND price > 296;

-- Variation 6
-- Parameters: {'stock': 21, 'min_price': 69}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 21 AND price > 69;

-- Variation 7
-- Parameters: {'stock': 49, 'min_price': 122}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 49 AND price > 122;

-- Variation 8
-- Parameters: {'stock': 27, 'min_price': 253}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 27 AND price > 253;

-- Variation 9
-- Parameters: {'stock': 48, 'min_price': 71}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 48 AND price > 71;

-- Variation 10
-- Parameters: {'stock': 32, 'min_price': 37}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 32 AND price > 37;

-- Variation 11
-- Parameters: {'stock': 11, 'min_price': 204}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 11 AND price > 204;

-- Variation 12
-- Parameters: {'stock': 22, 'min_price': 196}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 22 AND price > 196;

-- Variation 13
-- Parameters: {'stock': 38, 'min_price': 78}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 38 AND price > 78;

-- Variation 14
-- Parameters: {'stock': 28, 'min_price': 143}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 28 AND price > 143;

-- Variation 15
-- Parameters: {'stock': 29, 'min_price': 238}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 29 AND price > 238;

-- Variation 16
-- Parameters: {'stock': 46, 'min_price': 146}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 46 AND price > 146;

-- Variation 17
-- Parameters: {'stock': 11, 'min_price': 213}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 11 AND price > 213;

-- Variation 18
-- Parameters: {'stock': 45, 'min_price': 155}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 45 AND price > 155;

-- Variation 19
-- Parameters: {'stock': 45, 'min_price': 243}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 45 AND price > 243;

-- Variation 20
-- Parameters: {'stock': 27, 'min_price': 277}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 27 AND price > 277;

-- Variation 21
-- Parameters: {'stock': 15, 'min_price': 212}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 15 AND price > 212;

-- Variation 22
-- Parameters: {'stock': 45, 'min_price': 158}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 45 AND price > 158;

-- Variation 23
-- Parameters: {'stock': 10, 'min_price': 14}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 10 AND price > 14;

-- Variation 24
-- Parameters: {'stock': 35, 'min_price': 46}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 35 AND price > 46;

-- Variation 25
-- Parameters: {'stock': 48, 'min_price': 252}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 48 AND price > 252;

-- Variation 26
-- Parameters: {'stock': 15, 'min_price': 176}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 15 AND price > 176;

-- Variation 27
-- Parameters: {'stock': 8, 'min_price': 183}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 8 AND price > 183;

-- Variation 28
-- Parameters: {'stock': 36, 'min_price': 138}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 36 AND price > 138;

-- Variation 29
-- Parameters: {'stock': 21, 'min_price': 240}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 21 AND price > 240;

-- Variation 30
-- Parameters: {'stock': 36, 'min_price': 278}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 36 AND price > 278;

-- Variation 31
-- Parameters: {'stock': 46, 'min_price': 26}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 46 AND price > 26;

-- Variation 32
-- Parameters: {'stock': 44, 'min_price': 198}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 44 AND price > 198;

-- Variation 33
-- Parameters: {'stock': 40, 'min_price': 101}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 40 AND price > 101;

-- Variation 34
-- Parameters: {'stock': 40, 'min_price': 190}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 40 AND price > 190;

-- Variation 35
-- Parameters: {'stock': 24, 'min_price': 275}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 24 AND price > 275;

-- Variation 36
-- Parameters: {'stock': 24, 'min_price': 129}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 24 AND price > 129;

-- Variation 37
-- Parameters: {'stock': 26, 'min_price': 50}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 26 AND price > 50;

-- Variation 38
-- Parameters: {'stock': 43, 'min_price': 211}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 43 AND price > 211;

-- Variation 39
-- Parameters: {'stock': 49, 'min_price': 266}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 49 AND price > 266;

-- Variation 40
-- Parameters: {'stock': 10, 'min_price': 175}
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > 10 AND price > 175;

