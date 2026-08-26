
---======= package specification ====---
create or replace package pkg_subjectmanagement
is
   procedure sp_add_subject(p_subject_name subjects.subject_name%type,
                            p_course_id subjects.course_id%type,
                            p_status subjects.status%type,
                            p_user_id number);

   procedure sp_update_subject(p_subject_id subjects.subject_id%type,
                               p_subject_name subjects.subject_name%type,
                               p_course_id subjects.course_id%type,
                               p_status subjects.status%type,
                               p_user_id number);

   procedure sp_deactivate_subject(p_subject_id subjects.subject_id%type,
                                   p_user_id number);

   function sf_get_subject(p_subject_id subjects.subject_id%type,
                           p_user_id number) return subjects%rowtype;
end pkg_subjectmanagement;
/

---================================================================================---
------===== package body ====------

create or replace package body pkg_subjectmanagement
is
   --- adding subject procedure ---
   
   procedure sp_add_subject(p_subject_name subjects.subject_name%type,
                            p_course_id subjects.course_id%type,
                            p_status subjects.status%type,
                            p_user_id number)
   is
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
   begin
      if p_user_id is null then
         raise_application_error(-20001,'you should enter user id');
      elsif p_subject_name is null then
         raise_application_error(-20002,'you should enter subject name');
      else
         insert into subjects(subject_id,subject_name,course_id,status,created_date)
         values(sq_subject_id.nextval,p_subject_name,p_course_id,p_status,sysdate);
         commit;
         dbms_output.put_line(sql%rowcount||' rows added');
         dbms_output.put_line('adding successfully completed');
      end if;
   exception
      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);
         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sp_add_subject',v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-20104,v_error_message||' '||v_error_backtrace);
   end sp_add_subject;

   --- updating subject procedure ---
   
   procedure sp_update_subject(p_subject_id subjects.subject_id%type,
                               p_subject_name subjects.subject_name%type,
                               p_course_id subjects.course_id%type,
                               p_status subjects.status%type,
                               p_user_id number)
   is
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
   begin
      if p_subject_id is null or p_user_id is null then
         raise_application_error(-20003,'you should enter subject id as well as user id');
      else
         update subjects s
         set s.subject_name=nvl(p_subject_name,s.subject_name),
             s.course_id=nvl(p_course_id,s.course_id),
             s.status=nvl(p_status,s.status)
         where s.subject_id=p_subject_id;

         if sql%rowcount=0 then
            raise_application_error(-20004,'subject not found');
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
         values(sq_error_id.nextval,p_user_id,'sp_update_subject',v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-20105,v_error_message||' '||v_error_backtrace);
   end sp_update_subject;

   --- deactivating subject procedure ---
   
   procedure sp_deactivate_subject(p_subject_id subjects.subject_id%type,
                                   p_user_id number)
   is
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
   begin
      if p_subject_id is null or p_user_id is null then
         raise_application_error(-20005,'you should enter subject id as well as user id');
      else
         update subjects
         set status='INACTIVE'
         where subject_id=p_subject_id;

         if sql%rowcount=0 then
            raise_application_error(-20004,'subject not found');
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
         values(sq_error_id.nextval,p_user_id,'sp_deactivate_subject',v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-20106,v_error_message||' '||v_error_backtrace);
   end sp_deactivate_subject;

   --- getting subject details with function ---
   
   function sf_get_subject(p_subject_id subjects.subject_id%type,
                           p_user_id number) return subjects%rowtype
   is
      v_subject_details subjects%rowtype;
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
   begin
      if p_subject_id is null or p_user_id is null then
         raise_application_error(-20004,'you should enter subject id as well as user id');
      else
         select *
         into v_subject_details
         from subjects
         where subject_id=p_subject_id;
      end if;

      return v_subject_details;

   exception
      when no_data_found then
         v_error_message:='subject not found';
         v_error_backtrace:=dbms_utility.format_error_backtrace;
         raise_application_error(-20999,v_error_message);
      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);
         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sf_get_subject',v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-20108,v_error_message||' '||v_error_backtrace);
   end sf_get_subject;
end pkg_subjectmanagement;
/

