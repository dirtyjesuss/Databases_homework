create table Level (
    Level_code serial primary key not null,
    Manager char(1) check ( Manager = 'Y' ),
    Operator char(1) check ( Manager = 'Y' ),
    Engineer char(1) check ( Manager = 'Y' )
);

insert into Level(Manager, Operator, Engineer)
    values (null, 'Y', null),
           (null, null, 'Y'),
           (null, 'Y', 'Y'),
           ('Y', null, null),
           ('Y', 'Y', null),
           ('Y', 'Y', 'Y');

create table Staff (
    Staff_code char(3) primary key not null,
    First_name varchar(15) not null,
    Last_name varchar(15) not null,
    Level_code int references Level(Level_code) not null
);

create table Shift_type (
    Shift_type varchar(10) primary key not null,
    Start_time time not null,
    End_time time not null
);

insert into Shift_type values ('Early', '08:00', '14:00'), ('Late', '14:00', '20:00');

create table Shift (
    Shift_date date primary key not null ,
    Shift_type varchar(10) references Shift_type(Shift_type) not null ,
    Manager char(3) references Staff(Staff_code) not null ,
    Operator char(3) references Staff(Staff_code) not null ,
    Engineer1 char(3) references Staff(Staff_code) not null ,
    Engineer2 char(3) references Staff(Staff_code)
);

create table Customer (
    Company_ref int primary key not null ,
    Company_name varchar(20) not null ,
    Address varchar(50) not null ,
    Telephone char(11) not null
);

create table Caller (
    Caller_id serial primary key not null ,
    Company_ref int references Customer(Company_ref) ,
    First_name varchar(20) not null ,
    Last_name varchar(20) not null
);

create table Issue (
    Call_date date not null ,
    Call_ref int primary key not null ,
    Caller_id int references Caller(Caller_id) not null ,
    Detail text not null,
    Taken_by char(3) references Staff(Staff_code) not null ,
    Assigned_to char(3) references Staff(Staff_code) not null ,
    Status varchar(10) not null
);

create table Fired_staff (
    Staff_code char(3) primary key not null,
    First_name varchar(15) not null,
    Last_name varchar(15) not null,
    Level_code int references Level(Level_code) not null
);

/* triggers */

create or replace function save_in_fired()
    returns trigger
    language plpgsql
    as
$$
begin
    insert into Fired_staff (Staff_code, First_name, Last_name, Level_code)
    values (old.Staff_code, old.First_name, old.Last_name, old.Level_code);
    return old;
end;
$$;

create trigger fire
    before delete on Staff for each row
    execute procedure save_in_fired();

/* views */

create view company_caller as
    select cm.Company_name, cl.First_name, cl.Last_name
    from Caller cl join Customer cm on cl.Company_ref = cm.Company_ref;

insert into Customer(company_ref, company_name, address, telephone)
values (100, 'Haunt Services', 'Dartford', '01001722832'),
       (101, 'Genus Ltd.', 'Guildford', '01004256920');

insert into Caller(company_ref, first_name, last_name)
values (100, 'Ava', 'Clarke'),
       (101, 'Bab', 'Usdsuidsd'),
       (100, 'Bdodio', 'Nifosfi'),
       (100, 'Coposp', 'Eodfpdo'),
       (101, 'Oooo', 'Aaaaa');

select * from company_caller;

create view caller_staff as
    select c.First_name as caller_fn, c.Last_name as caller_ln,
           s.First_name as staff_fn, s.Last_name as staff_ln
    from Caller c join Issue i on c.Caller_id = i.Caller_id
    join Staff s on i.Taken_by = s.Staff_code;

insert into Issue(Call_date, Call_ref, Caller_id, Detail, Taken_by, Assigned_to, Status)
values (current_date, 1237, 1, 'Bla bla bla?', 'AB2', 'AB2', 'Closed');

select * from caller_staff;

/* procedures */

create or replace procedure get_callers(company_name varchar(20), inout result refcursor) as
    $$
    begin
        open result for
        select First_name, Last_name
        from company_caller cc
        where cc.Company_name = get_callers.company_name;
    end;
    $$
language plpgsql;

begin;
call get_callers('Haunt Services', 'result');
fetch all in "result";
commit;
