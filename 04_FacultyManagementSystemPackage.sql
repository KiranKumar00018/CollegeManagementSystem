---======= package specification =======---

create or replace package PKG_FACULTYMANAGEMENT
is
   procedure sp_add_faculty(p_faculty_name faculty.faculty_name%type,
                            p_date_of_birth faculty.date_of_birth%type,
                            p_gender faculty.gender%type,
                            p_email faculty.email%type,
                            p_phone faculty.phone%type,
                            p_department_id faculty.department_id%type,
                            p_subject_id faculty.subject_id%type,
                            p_designation faculty.designation%type,
                            p_joining_date faculty.joining_date%type,
                            p_status faculty.status%type,
                            p_user_id number);

   procedure sp_update_faculty(p_faculty_id faculty.faculty_id%type,
                               p_faculty_name faculty.faculty_name%type,
                               p_date_of_birth faculty.date_of_birth%type,
                               p_gender faculty.gender%type,
                               p_email faculty.email%type,
                               p_phone faculty.phone%type,
                               p_department_id faculty.department_id%type,
                               p_subject_id faculty.subject_id%type,
                               p_designation faculty.designation%type,
                               p_joining_date faculty.joining_date%type,
                               p_status faculty.status%type,
                               p_user_id number);

   procedure sp_deactivate_faculty(p_faculty_id faculty.faculty_id%type,p_user_id number);

   function sf_get_faculty(p_faculty_id faculty.faculty_id%type,p_user_id number) return faculty%rowtype;
end PKG_FACULTYMANAGEMENT;
/

---===================================================================================---
---======= package body =======---

create or replace package body PKG_FACULTYMANAGEMENT
is

   --- update faculty procedure ---

   procedure sp_update_faculty(p_faculty_id faculty.faculty_id%type,
                               p_faculty_name faculty.faculty_name%type,
                               p_date_of_birth faculty.date_of_birth%type,
                               p_gender faculty.gender%type,
                               p_email faculty.email%type,
                               p_phone faculty.phone%type,
                               p_department_id faculty.department_id%type,
                               p_subject_id faculty.subject_id%type,
                               p_designation faculty.designation%type,
                               p_joining_date faculty.joining_date%type,
                               p_status faculty.status%type,
                               p_user_id number)
   is
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
   begin
      if p_faculty_id is null or p_user_id is null then
         raise_application_error(-20001,'you should enter faculty id as well as user id');
      else
         update faculty f set f.faculty_name=nvl(p_faculty_name,f.faculty_name),
                              f.date_of_birth=nvl(p_date_of_birth,f.date_of_birth),
                              f.gender=nvl(p_gender,f.gender),
                              f.email=nvl(p_email,f.email),
                              f.phone=nvl(p_phone,f.phone),
                              f.department_id=nvl(p_department_id,f.department_id),
                              f.subject_id=nvl(p_subject_id,f.subject_id),
                              f.designation=nvl(p_designation,f.designation),
                              f.joining_date=nvl(p_joining_date,f.joining_date),
                              f.status=nvl(p_status,f.status)
         where f.faculty_id=p_faculty_id;

         if sql%rowcount=0 then
            raise_application_error(-20002,'faculty not found');
         else
            commit;
            dbms_output.put_line(sql%rowcount||' rows updated');
            dbms_output.put_line('update successfully completed');
         end if;
      end if;
   exception
      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);
         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sp_update_faculty',v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-20066,v_error_message||' '||v_error_backtrace);
   end sp_update_faculty;

   --- add faculty procedure ---

   procedure sp_add_faculty(p_faculty_name faculty.faculty_name%type,
                            p_date_of_birth faculty.date_of_birth%type,
                            p_gender faculty.gender%type,
                            p_email faculty.email%type,
                            p_phone faculty.phone%type,
                            p_department_id faculty.department_id%type,
                            p_subject_id faculty.subject_id%type,
                            p_designation faculty.designation%type,
                            p_joining_date faculty.joining_date%type,
                            p_status faculty.status%type,
                            p_user_id number)
   is
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
   begin
      if p_user_id is null then
         raise_application_error(-20001,'you should enter user id');
      else
         insert into faculty(faculty_id,faculty_name,date_of_birth,gender,email,phone,department_id,subject_id,designation,joining_date,status)
         values(sq_faculty_id.nextval,p_faculty_name,p_date_of_birth,p_gender,p_email,p_phone,p_department_id,p_subject_id,p_designation,p_joining_date,p_status);
         commit;
         dbms_output.put_line(sql%rowcount||' rows added');
         dbms_output.put_line('adding successfully completed');
      end if;
   exception
      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);
         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sp_add_faculty',v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-20067,v_error_message||' '||v_error_backtrace);
   end sp_add_faculty;

   --- deactivate faculty procedure ---

   procedure sp_deactivate_faculty(p_faculty_id faculty.faculty_id%type,p_user_id number)
   is
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
   begin
      if p_faculty_id is null or p_user_id is null then
         raise_application_error(-20001,'you should enter faculty id as well as user id');
      else
         update faculty
         set status='INACTIVE'
         where faculty_id=p_faculty_id;

         if sql%rowcount=0 then
            raise_application_error(-20002,'faculty not found');
         else
            commit;
            dbms_output.put_line(sql%rowcount||' rows deactivated');
            dbms_output.put_line('deactivated successfully completed');
         end if;
      end if;
   exception
      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);
         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sp_deactivate_faculty',v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-20068,v_error_message||' '||v_error_backtrace);
   end sp_deactivate_faculty;

   --- get faculty details function ---

   function sf_get_faculty(p_faculty_id faculty.faculty_id%type,p_user_id number) return faculty%rowtype
   is
      v_faculty_details faculty%rowtype;
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
   begin
      if p_user_id is null or p_faculty_id is null then
         raise_application_error(-20001,'you should enter faculty id as well as user id');
      else
         select *
         into v_faculty_details
         from faculty
         where faculty_id=p_faculty_id;
      end if;
      return v_faculty_details;
   exception
      when no_data_found then
         raise_application_error(-20002,'faculty not found');
      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);
         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sf_get_faculty',v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-20069,v_error_message||' '||v_error_backtrace);
   end sf_get_faculty;

end PKG_FACULTYMANAGEMENT;
/
