CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id),
    quantity INT,
    total_amount NUMERIC
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255),
    price NUMERIC
);
-- Viết TRIGGER BEFORE INSERT để tự động tính total_amount
create or replace function total_amount()
returns trigger 
language plpgsql
as $$
begin
    new.total_amount := new.quantity * (select price from products where product_id = new.product_id);
    return new;
end;
$$;
-- Tạo trigger để gọi hàm calculate_total_amount trước khi chèn dữ liệu vào bảng orders
create trigger trg_total_amount
before insert on orders
for each row
exeute function total_amount();

-- Thêm dữ liệu vào bảng products
insert into products (product_name, price) values ('Product A', 10.00);
insert into products (product_name, price) values ('Product B', 20.00);
-- Thêm dữ liệu vào bảng orders
insert into orders (product_id, quantity) values (1, 2); -- total_amount sẽ tự động tính là 20.00
insert into orders (product_id, quantity) values (2, 3); -- total_amount sẽ tự động tính là 60.00
-- Kiểm tra dữ liệu trong bảng orders
select * from orders;