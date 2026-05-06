CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    stock INT
);

CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id),
    quantity INT
);

-- Viết TRIGGER BEFORE INSERT để kiểm tra tồn kho
create or replace function check_stock()
returns trigger
language plpgsql
as $$
declare current_stock int;
begin
    -- lay ton kho hien tai cua san pham
    select stock into current_stock from products where product_id = new.product_id;
    if current_stock < new.quantity then
        raise exception 'Khong du ton kho cho san pham %, con % san pham ton kho', new.product_id, current_stock;
    else
        -- cap nhat lai ton kho sau khi ban
        update products set stock = stock - new.quantity where product_id = new.product_id;
    end if;
    return new;
end;
$$;

-- Tạo TRIGGER để kiểm tra tồn kho trước khi thêm đơn hàng
create trigger trg_check_stock
before insert on sales
for each row
execute function check_stock();

-- Thử thêm các đơn hàng vượt quá tồn kho và quan sát Trigger hoạt động
insert into products (name, stock) values ('Tivi', 10);
insert into sales (product_id, quantity) values (1, 11); -- Lỗi: Không đủ tồn kho
insert into sales (product_id, quantity) values (1, 4); -- Thành công
select * from products;
select * from sales;