-- CREATE TABLES RELATED TO THE SHIPMENT INFORMATION

-- SHIP COMPANY
CREATE TABLE ship.ship_company (
    id        SERIAL PRIMARY KEY,
    name      VARCHAR(100) UNIQUE NOT NULL,
    nit       VARCHAR(20)  UNIQUE NULL,
    address   VARCHAR(100) NOT NULL,
    phone     VARCHAR(20)  NULL,
    email     VARCHAR(100) NULL,
    created_at TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);

-- SHIP ORDERS
CREATE TABLE ship.shipment_orders (
    id              VARCHAR(25)  PRIMARY KEY,
    ship_company_id INT          NOT NULL,
    order_id        VARCHAR(25)  NOT NULL,
    tracking_code   VARCHAR(100) UNIQUE NULL,
    status          VARCHAR(20)  NOT NULL DEFAULT 'pending',
    shipped_at      TIMESTAMP    NULL,
    delivered_at    TIMESTAMP    NULL,
    created_at      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
    
);

-- RELATIONSHIPS

ALTER TABLE ship.shipment_orders
ADD CONSTRAINT fk_shipment_company
FOREIGN KEY (ship_company_id) REFERENCES ship.ship_company(id);

ALTER TABLE ship.shipment_orders
ADD CONSTRAINT fk_order_shipments
FOREIGN KEY (order_id) REFERENCES pay.orders(id);

-- CONSTRAINTS
ALTER TABLE ship.shipment_orders
ADD CONSTRAINT chk_shipment_status CHECK (
        status IN ('pending', 'in_transit', 'delivered')
    )