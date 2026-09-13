----<======== package spec =======>-----
create or replace package pkg_feemanagement
as
--Add fee
procedure sp_add_fee(
p_student_id fees.student_id%type,
p_total_amount fees.total_amount%type,
p_paid_amount fees.paid_amount%type,
p_due_date fees.due_date%type,
p_status fees.status%type,
p_user_id number);
--Update fee
procedure sp_update_fee(
p_student_id fees.student_id%type,
p_total_amount fees.total_amount%type,
p_paid_amount fees.paid_amount%type,
p_due_date fees.due_date%type,
p_status fees.status%type,
p_user_id number);

--Deactivate fee
procedure sp_deactivate_fee(
p_student_id fees.student_id%type,
p_user_id number);

--Get fee details
function sf_get_fee(
p_student_id fees.student_id%type)
return varchar2;

end pkg_feemanagement;
/
----<===== package body ======>---
create or replace package body pkg_feemanagement
as

--Add fee
procedure sp_add_fee(
p_student_id fees.student_id%type,
p_total_amount fees.total_amount%type,
p_paid_amount fees.paid_amount%type,
p_due_date fees.due_date%type,
p_status fees.status%type,
p_user_id number)
as
v_error_message varchar2(3500);
v_error_backtrace varchar2(3500);
v_count number;
begin

--Validate student
if p_student_id is null then
raise_application_error(-20001,'Student ID cannot be null');
end if;

--Validate total amount
if p_total_amount is null or p_total_amount<=0 then
raise_application_error(-20002,'Total amount must be greater than zero');
end if;

--Validate paid amount
if p_paid_amount is null or p_paid_amount<0 then
raise_application_error(-20003,'Paid amount cannot be null or negative');
end if;

--Paid amount cannot exceed total amount
if p_paid_amount>p_total_amount then
raise_application_error(-20004,'Paid amount cannot exceed total amount');
end if;

--Check student
select count(*) into v_count
from students
where student_id=p_student_id;

if v_count=0 then
raise_application_error(-20005,'Student does not exist');
end if;

--Check duplicate fee
select count(*) into v_count
from fees
where student_id=p_student_id;

if v_count>0 then
raise_application_error(-20006,'Fee record already exists for this student');
end if;

--Validate status
if upper(p_status) not in('ACTIVE','PENDING','PAID') then
raise_application_error(-20007,'Invalid fee status');
end if;

--Insert fee
insert into fees(student_id,total_amount,paid_amount,due_date,status,created_date)
values(p_student_id,p_total_amount,p_paid_amount,p_due_date,upper(p_status),sysdate);

commit;

exception
when others then
v_error_message:=sqlerrm;
v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);

--Log error
insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
values(sq_error_id.nextval,p_user_id,'sp_add_fee',v_error_message,v_error_backtrace);

commit;
raise_application_error(-20128,v_error_message||' '||v_error_backtrace);
end sp_add_fee;


--Update fee
procedure sp_update_fee(
p_student_id fees.student_id%type,
p_total_amount fees.total_amount%type,
p_paid_amount fees.paid_amount%type,
p_due_date fees.due_date%type,
p_status fees.status%type,
p_user_id number)
as
v_error_message varchar2(3500);
v_error_backtrace varchar2(3500);
v_count number;
begin

--Check fee
select count(*) into v_count
from fees
where student_id=p_student_id;

if v_count=0 then
raise_application_error(-20008,'Fee record does not exist');
end if;

--Validate total amount
if p_total_amount is null or p_total_amount<=0 then
raise_application_error(-20009,'Total amount must be greater than zero');
end if;

--Validate paid amount
if p_paid_amount is null or p_paid_amount<0 then
raise_application_error(-20010,'Paid amount cannot be null or negative');
end if;

--Paid amount cannot exceed total
if p_paid_amount>p_total_amount then
raise_application_error(-20011,'Paid amount cannot exceed total amount');
end if;

--Validate status
if upper(p_status) not in('ACTIVE','PENDING','PAID') then
raise_application_error(-20012,'Invalid fee status');
end if;

--Update fee
update fees
set total_amount=p_total_amount,
paid_amount=p_paid_amount,
due_date=p_due_date,
status=upper(p_status)
where student_id=p_student_id;

commit;

exception
when others then
v_error_message:=sqlerrm;
v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);

--Log error
insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
values(sq_error_id.nextval,p_user_id,'sp_update_fee',v_error_message,v_error_backtrace);

commit;
raise_application_error(-20129,v_error_message||' '||v_error_backtrace);
end sp_update_fee;


--Deactivate fee
procedure sp_deactivate_fee(
p_student_id fees.student_id%type,
p_user_id number)
as
v_error_message varchar2(3500);
v_error_backtrace varchar2(3500);
v_count number;
begin

--Check fee
select count(*) into v_count
from fees
where student_id=p_student_id;

if v_count=0 then
raise_application_error(-20013,'Fee record does not exist');
end if;

--Deactivate fee
update fees
set status='INACTIVE'
where student_id=p_student_id;

commit;

exception
when others then
v_error_message:=sqlerrm;
v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);

--Log error
insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
values(sq_error_id.nextval,p_user_id,'sp_deactivate_fee',v_error_message,v_error_backtrace);

commit;
raise_application_error(-20130,v_error_message||' '||v_error_backtrace);
end sp_deactivate_fee;


--Get fee
function sf_get_fee(
p_student_id fees.student_id%type)
return varchar2
as
v_result varchar2(4000);
begin

--Get fee details
select 'Total='||total_amount||
',Paid='||paid_amount||
',Due='||(total_amount-paid_amount)||
',Due Date='||to_char(due_date,'DD-MM-YYYY')||
',Status='||status
into v_result
from fees
where student_id=p_student_id;

return v_result;

exception
when no_data_found then
raise_application_error(-20014,'Fee record does not exist');

when others then
raise_application_error(-20131,sqlerrm||' '||substr(dbms_utility.format_error_backtrace,-11));
end sf_get_fee;

end pkg_feemanagement;
/