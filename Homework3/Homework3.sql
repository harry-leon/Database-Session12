CREATE table customer (
    customer_id serial primary key,
    name varchar(50),
    email varchar(50)
);

Create table customer_log (
    log_id serial primary key,
    customer_name varchar(50),
    action_time timestamp
);

-- Viết TRIGGER AFTER INSERT để giảm số lượng stock trong products
create or replace function update_stock()
returns TRIGGER
LANGUAGE plpgsql
as $$
begin
	update products set stock = stock - new.quantity where new.product_id = products.product_id;
	return new;
end;
$$;
-- Tạo TRIGGER để update tồn kho trước khi thêm đơn hàng
create trigger trg_update_stock
after insert on sales
for each row
execute function update_stock();
-- Thêm đơn hàng và kiểm tra products để thấy số lượng tồn kho giảm đúng
insert into products (name, stock) values ('Tivi', 10);
insert into sales (product_id, quantity) values (1, 11); -- Lỗi: Không đủ tồn kho
insert into sales (product_id, quantity) values (1, 4); -- Thành công
select * from products;
select * from sales;