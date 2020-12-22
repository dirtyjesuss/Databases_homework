create type gender as enum ('M', 'F');


create table posts
(
    id serial not null primary key,
    name                   varchar(30) not null,
    allowance_for_10_years real,
    allowance_for_20_years real,
    allowance_for_30_years real,
    allowance_for_hazard   real
);

create table departments
(
    id              serial      not null primary key,
    name            varchar(30) not null,
    code            integer     not null,
    employees_count integer check (employees_count >= 0),
    header_id       integer
);

create table employees
(
    id            serial      not null primary key,
    firstname     varchar(20) not null,
    lastname      varchar(20) not null,
    patronymic    varchar(20) not null,
    gender        gender      not null,
    birthdate     date        not null,
    age           integer default age(birthdate),
    department_id integer references departments(id),
    experience    integer check (experience >= 0),
    hazard        boolean,
    post_id       integer references posts(id)
);

alter table departments
    add constraint departments_header_id_fkey
        foreign key (header_id) references employees;

create function age(birthdate date) returns integer
    immutable
    language plpgsql
as
$$
begin
    return extract(year from current_date) - extract(year from birthdate);
end
$$;


