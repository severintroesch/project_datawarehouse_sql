USE zVQqkOrZWw;

DROP TABLE IF EXISTS facts;

DROP TABLE IF EXISTS customer;
CREATE TABLE customer
(
id							integer				NOT NULL,
company						varchar(50)			NOT NULL,
last_name					varchar(50)			NOT NULL,
first_name					varchar(50)			NOT NULL,
job_title					varchar(50)			NOT NULL,
business_phone				varchar(20)			NOT NULL,
address						varchar(250)		NOT NULL,
city						varchar(50)			NOT NULL,
state_province				char(2)				NOT NULL,
country_region				varchar(14)			NOT NULL,

CONSTRAINT PK_customer PRIMARY KEY (id)
);


DROP TABLE IF EXISTS date;
CREATE TABLE date
(
id							integer				NOT NULL,
order_date					DATETIME			NOT NULL,
year						integer				NOT NULL,
month						integer				NOT NULL,
cw							integer				NOT NULL,
weekday						integer				NOT NULL,

CONSTRAINT PK_date PRIMARY KEY (id)
);


DROP TABLE IF EXISTS destination;
CREATE TABLE destination
(
id							integer				NOT NULL,
ship_country_region			varchar(14)			NOT NULL,
ship_state_province			char(2)				NOT NULL,
ship_city					varchar(50)			NOT NULL,

CONSTRAINT PK_destination PRIMARY KEY (id)
);


DROP TABLE IF EXISTS employee;
CREATE TABLE employee
(
id							integer				NOT NULL,
company						varchar(50)			NOT NULL,
last_name					varchar(50)			NOT NULL,
first_name					varchar(50)			NOT NULL,
email_address				varchar(50)			NOT NULL,
job_title					varchar(50)			NOT NULL,
business_phone				varchar(20)			NOT NULL,
address						varchar(250)		NOT NULL,
city						varchar(50)			NOT NULL,
state_province				char(2)				NOT NULL,
country_region				varchar(14)			NOT NULL,

CONSTRAINT PK_employee PRIMARY KEY (id)
);


DROP TABLE IF EXISTS product;
CREATE TABLE product
(
id							integer				NOT NULL,
product_code				varchar(50)			NOT NULL,
product_name				varchar(100)		NOT NULL,
category					varchar(50)			NOT NULL,
standard_cost				varchar(50)			NOT NULL,
list_price					varchar(50)			NOT NULL,

CONSTRAINT PK_product PRIMARY KEY (id)
);

DROP TABLE IF EXISTS facts;
CREATE TABLE facts
(
customer_id					integer				NOT NULL,
date_id						integer				NOT NULL,
destination_id				integer				NOT NULL,
employee_id					integer				NOT NULL,
product_id					integer				NOT NULL,
quantity					integer				NOT NULL,
Umsatz_vor_Discount			decimal(20,2)		NOT NULL,
Umsatz_nach_Discount		decimal(20,2)		NOT NULL,
Gewinn_vor_Discount			decimal(20,2)		NOT NULL,
Gewinn_nach_Discount		decimal(20,2)		NOT NULL,

UNIQUE (customer_id, date_id, destination_id, employee_id, product_id),
CONSTRAINT FK_product FOREIGN KEY(product_id) REFERENCES product(id),
CONSTRAINT FK_customer FOREIGN KEY(customer_id) REFERENCES customer(id),
CONSTRAINT FK_date FOREIGN KEY(date_id) REFERENCES date(id),
CONSTRAINT FK_destination FOREIGN KEY(destination_id) REFERENCES destination(id),
CONSTRAINT FK_employee FOREIGN KEY(employee_id) REFERENCES employee(id)
);

SELECT * FROM customer


