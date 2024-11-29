LOAD DATA
INFILE 'final.csv'
INTO TABLE new_products
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(id, product_id, product_name, amount, dates, category)
