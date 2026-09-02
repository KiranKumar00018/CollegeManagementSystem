create or replace package pkg_attendancemanagement
as
-- Adds a new attendance record
procedure sp_add_attendance(
p_student_id attendance.student_id%type,
p_subject_id attendance.subject_id%type,
p_attendance_date attendance.attendance_date%type,
p_status attendance.status%type,
p_user_id number);
-- Updates the attendance status
procedure sp_update_attendance(
p_student_id attendance.student_id%type,
p_subject_id attendance.subject_id%type,
p_attendance_date attendance.attendance_date%type,
p_status attendance.status%type,
p_user_id number);

-- Deactivates an attendance record
procedure sp_deactivate_attendance(
p_student_id attendance.student_id%type,
p_subject_id attendance.subject_id%type,
p_attendance_date attendance.attendance_date%type,
p_user_id number);
-- Returns attendance status
function sf_get_attendance(
p_student_id attendance.student_id%type,
p_subject_id attendance.subject_id%type,
p_attendance_date attendance.attendance_date%type)
return varchar2;

end pkg_attendancemanagement;
/
--======= package body ============--
create or replace package body pkg_attendancemanagement
as

--Add attendance
procedure sp_add_attendance(
p_student_id attendance.student_id%type,
p_subject_id attendance.subject_id%type,
p_attendance_date attendance.attendance_date%type,
p_status attendance.status%type,
p_user_id number)
as
v_error_message varchar2(3500);
v_error_backtrace varchar2(3500);
v_count number;
begin

--Validate student id
if p_student_id is null then
raise_application_error(-20001,'Student ID cannot be null');
end if;

--Validate subject id
if p_subject_id is null then
raise_application_error(-20002,'Subject ID cannot be null');
end if;

--Validate attendance date
if p_attendance_date is null then
raise_application_error(-20003,'Attendance date cannot be null');
end if;

--Validate status
if upper(p_status) not in('P','A') then
raise_application_error(-20004,'Status must be P or A');
end if;

--Check student
select count(*) into v_count
from students
where student_id=p_student_id;

if v_count=0 then
raise_application_error(-20005,'Student does not exist');
end if;

--Check subject
select count(*) into v_count
from subjects
where subject_id=p_subject_id;

if v_count=0 then
raise_application_error(-20006,'Subject does not exist');
end if;

--Check duplicate attendance
select count(*) into v_count
from attendance
where student_id=p_student_id
and subject_id=p_subject_id
and attendance_date=p_attendance_date;

if v_count>0 then
raise_application_error(-20007,'Attendance record already exists');
end if;

--Insert attendance
insert into attendance(student_id,subject_id,attendance_date,status)
values(p_student_id,p_subject_id,p_attendance_date,upper(p_status));

commit;

exception
when others then
v_error_message:=sqlerrm;
v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);

--Log error
insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
values(sq_error_id.nextval,p_user_id,'sp_add_attendance',v_error_message,v_error_backtrace);

commit;
raise_application_error(-20124,v_error_message||' '||v_error_backtrace);
end sp_add_attendance;


--Update attendance
procedure sp_update_attendance(
p_student_id attendance.student_id%type,
p_subject_id attendance.subject_id%type,
p_attendance_date attendance.attendance_date%type,
p_status attendance.status%type,
p_user_id number)
as
v_error_message varchar2(3500);
v_error_backtrace varchar2(3500);
v_count number;
begin

--Validate status
if upper(p_status) not in('P','A') then
raise_application_error(-20008,'Status must be P or A');
end if;

--Check attendance
select count(*) into v_count
from attendance
where student_id=p_student_id
and subject_id=p_subject_id
and attendance_date=p_attendance_date;

if v_count=0 then
raise_application_error(-20009,'Attendance record does not exist');
end if;

--Update attendance
update attendance
set status=upper(p_status)
where student_id=p_student_id
and subject_id=p_subject_id
and attendance_date=p_attendance_date;

commit;

exception
when others then
v_error_message:=sqlerrm;
v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);

--Log error
insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
values(sq_error_id.nextval,p_user_id,'sp_update_attendance',v_error_message,v_error_backtrace);

commit;
raise_application_error(-20125,v_error_message||' '||v_error_backtrace);
end sp_update_attendance;


--Deactivate attendance
procedure sp_deactivate_attendance(
p_student_id attendance.student_id%type,
p_subject_id attendance.subject_id%type,
p_attendance_date attendance.attendance_date%type,
p_user_id number)
as
v_error_message varchar2(3500);
v_error_backtrace varchar2(3500);
v_count number;
begin

--Check attendance
select count(*) into v_count
from attendance
where student_id=p_student_id
and subject_id=p_subject_id
and attendance_date=p_attendance_date;

if v_count=0 then
raise_application_error(-20010,'Attendance record does not exist');
end if;

--Set status inactive
update attendance
set status='INACTIVE'
where student_id=p_student_id
and subject_id=p_subject_id
and attendance_date=p_attendance_date;

commit;

exception
when others then
v_error_message:=sqlerrm;
v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);

--Log error
insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
values(sq_error_id.nextval,p_user_id,'sp_deactivate_attendance',v_error_message,v_error_backtrace);

commit;
raise_application_error(-20126,v_error_message||' '||v_error_backtrace);
end sp_deactivate_attendance;


--Get attendance
function sf_get_attendance(
p_student_id attendance.student_id%type,
p_subject_id attendance.subject_id%type,
p_attendance_date attendance.attendance_date%type)
return varchar2
as
v_status attendance.status%type;
begin

--Get status
select status into v_status
from attendance
where student_id=p_student_id
and subject_id=p_subject_id
and attendance_date=p_attendance_date;

return v_status;

exception
when no_data_found then
raise_application_error(-20011,'Attendance record does not exist');

when others then
raise_application_error(-20127,sqlerrm||' '||substr(dbms_utility.format_error_backtrace,-11));
end sf_get_attendance;

end pkg_attendancemanagement;
/