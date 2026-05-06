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

-- Tạo hàm tg_log_customer_action để ghi log vào customer_log
create or replace function log_new_customer() 
returns trigger 
as $$
begin
    insert into customer_log (customer_name, action_time)
    values (new.name, current_timestamp);
    return new;
end;
$$ language plpgsql;

-- Tạo TRIGGER để tự động ghi log khi INSERT vào customers
create trigger trg_log_customer
after insert on customer
for each row
execute function log_new_customer();

-- Thêm vài bản ghi vào customers và kiểm tra customer_log
insert into customer (name, email) values ('Quoc Hung', 'quochung@gmail.com');
insert into customer (name, email) values ('Quoc Hung 2', 'quochung2@gmail.com');
select * from customer_log;