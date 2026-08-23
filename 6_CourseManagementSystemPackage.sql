---======= package specification ====---
create or replace package pkg_coursemanagement
is
   procedure sp_add_course(p_course_name courses.course_name%type,
                           p_department_id courses.department_id%type,
                           p_status courses.status%type,
                           p_user_id number);

   procedure sp_update_course(p_course_id courses.course_id%type,
                              p_course_name courses.course_name%type,
                              p_department_id courses.department_id%type,
                              p_status courses.status%type,
                              p_user_id number);

   procedure sp_deactivate_course(p_course_id courses.course_id%type,p_user_id number);

   function sf_get_course(p_course_id courses.course_id%type,p_user_id number) return courses%rowtype;
end pkg_coursemanagement;
/
---===================================================================================
------===== package body ====------
create or replace package body pkg_coursemanagement
is
--- adding course procedure ---
procedure sp_add_course(p_course_name courses.course_name%type,
                        p_department_id courses.department_id%type,
                        p_status courses.status%type,
                        p_user_id number)
is
   v_error_message varchar2(3500);
   v_error_backtrace varchar2(3500);
begin
   if p_user_id is null then
      raise_application_error(-20001,'you should enter user id');
   elsif p_course_name is null or p_department_id is null then
      raise_application_error(-20002,'you should enter course name and department id');
   else
      insert into courses(course_id,course_name,department_id,status)
      values(sq_course_id.nextval,p_course_name,p_department_id,p_status);
      commit;
      dbms_output.put_line(sql%rowcount||' rows added');
      dbms_output.put_line('adding successfully completed');
   end if;
exception
   when others then
      v_error_message:=sqlerrm;
      v_error_backtrace:=dbms_utility.format_error_backtrace;
      insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
      values(sq_error_id.nextval,p_user_id,'sp_add_course',v_error_message,v_error_backtrace);
      commit;
      raise_application_error(-200077,v_error_message||' '||v_error_backtrace);
end sp_add_course;

--- updating course procedure ---
procedure sp_update_course(p_course_id courses.course_id%type,
                           p_course_name courses.course_name%type,
                           p_department_id courses.department_id%type,
                           p_status courses.status%type,
                           p_user_id number)
is
   v_error_message varchar2(3500);
   v_error_backtrace varchar2(3500);
begin
   if p_course_id is null or p_user_id is null then
      raise_application_error(-20003,'you should enter course id as well as user id');
   else
      update courses c
      set c.course_name=nvl(p_course_name,c.course_name),
          c.department_id=nvl(p_department_id,c.department_id),
          c.status=nvl(p_status,c.status)
      where c.course_id=p_course_id;

      if sql%rowcount=0 then
         raise_application_error(-20004,'course not found');
      else
         commit;
         dbms_output.put_line(sql%rowcount||' rows updated');
         dbms_output.put_line('update successfully completed');
      end if;
   end if;
exception
   when others then
      v_error_message:=sqlerrm;
      v_error_backtrace:=dbms_utility.format_error_backtrace;
      insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
      values(sq_error_id.nextval,p_user_id,'sp_update_course',v_error_message,v_error_backtrace);
      commit;
      raise_application_error(-200077,v_error_message||' '||v_error_backtrace);
end sp_update_course;

--- deactivating course procedure ---
procedure sp_deactivate_course(p_course_id courses.course_id%type,p_user_id number)
is
   v_error_message varchar2(3500);
   v_error_backtrace varchar2(3500);
begin
   if p_course_id is null or p_user_id is null then
      raise_application_error(-20005,'you should enter course id as well as user id');
   else
      update courses
      set status='inactive'
      where course_id=p_course_id;

      if sql%rowcount=0 then
         raise_application_error(-20004,'course not found');
      else
         commit;
         dbms_output.put_line(sql%rowcount||' rows deactivated');
         dbms_output.put_line('deactivated successfully completed');
      end if;
   end if;
exception
   when others then
      v_error_message:=sqlerrm;
      v_error_backtrace:=dbms_utility.format_error_backtrace;
      insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
      values(sq_error_id.nextval,p_user_id,'sp_deactivate_course',v_error_message,v_error_backtrace);
      commit;
      raise_application_error(-200077,v_error_message||' '||v_error_backtrace);
end sp_deactivate_course;

--- getting course details with function ---
function sf_get_course(p_course_id courses.course_id%type,p_user_id number) return courses%rowtype
is
   v_course_details courses%rowtype;
   v_error_message varchar2(3500);
   v_error_backtrace varchar2(3500);
begin
   if p_course_id is null or p_user_id is null then
      raise_application_error(-20006,'you should enter course id as well as user id');
   else
      select *
      into v_course_details
      from courses
      where course_id=p_course_id;
   end if;

   return v_course_details;
exception
   when no_data_found then
      v_error_message:='course not found';
      v_error_backtrace:=dbms_utility.format_error_backtrace;
      insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
      values(sq_error_id.nextval,p_user_id,'sf_get_course',v_error_message,v_error_backtrace);
      commit;
      raise_application_error(-20007,v_error_message);
   when others then
      v_error_message:=sqlerrm;
      v_error_backtrace:=dbms_utility.format_error_backtrace;
      insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
      values(sq_error_id.nextval,p_user_id,'sf_get_course',v_error_message,v_error_backtrace);
      commit;
      raise_application_error(-200077,v_error_message||' '||v_error_backtrace);
end sf_get_course;
end pkg_coursemanagement;
/
