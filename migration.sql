create table events (
  id serial primary key,
  name varchar(255) not null,
  payload text,
  key varchar(255),
  processed_at timestamp
);
