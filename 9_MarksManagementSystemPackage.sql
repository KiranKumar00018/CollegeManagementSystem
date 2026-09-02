---======= package specification ========---

create or replace package pkg_marksmanagement
is
   procedure sp_add_marks(p_student_id marks.student_id%type,
                          p_subject_id marks.subject_id%type,
                          p_marks marks.marks%type,
                          p_user_id number);

   procedure sp_update_marks(p_mark_id marks.mark_id%type,
                             p_student_id marks.student_id%type,
                             p_subject_id marks.subject_id%type,
                             p_marks marks.marks%type,
                             p_user_id number);

   procedure sp_deactivate_marks(p_mark_id marks.mark_id%type,
                                 p_user_id number);

   function sf_get_marks(p_mark_id marks.mark_id%type,
                         p_user_id number)
   return marks%rowtype;
end pkg_marksmanagement;
/
---================================================================================---
------===== package body ======------

create or replace package body pkg_marksmanagement
is

   ---======= adding marks ========---

   procedure sp_add_marks(p_student_id marks.student_id%type,
                          p_subject_id marks.subject_id%type,
                          p_marks marks.marks%type,
                          p_user_id number)
   is
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
      v_count number;
   begin
      if p_user_id is null then
         raise_application_error(-20001,'you should enter user id');
      elsif p_student_id is null then
         raise_application_error(-20002,'you should enter student id');
      elsif p_subject_id is null then
         raise_application_error(-20003,'you should enter subject id');
      elsif p_marks is null then
         raise_application_error(-20004,'you should enter marks');
      elsif p_marks<0 or p_marks>100 then
         raise_application_error(-20005,'marks should be between 0 and 100');
      else

         --- check student exists ---

         select count(*)
         into v_count
         from students
         where student_id=p_student_id;

         if v_count=0 then
            raise_application_error(-20006,'student not found');
         end if;

         --- check subject exists ---

         select count(*)
         into v_count
         from subjects
         where subject_id=p_subject_id;

         if v_count=0 then
            raise_application_error(-20007,'subject not found');
         end if;

         --- check duplicate marks ---

         select count(*)
         into v_count
         from marks
         where student_id=p_student_id
         and subject_id=p_subject_id;

         if v_count>0 then
            raise_application_error(-20008,'marks already exists for this student and subject');
         end if;

         --- insert marks ---

         insert into marks(mark_id,student_id,subject_id,marks)
         values(sq_mark_id.nextval,p_student_id,p_subject_id,p_marks);

         commit;
         dbms_output.put_line(sql%rowcount||' rows added');
         dbms_output.put_line('marks successfully completed');

      end if;

   exception
      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);
         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sp_add_marks',
                v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-20120,v_error_message||' '||v_error_backtrace);
   end sp_add_marks;


   ---======= updating marks ========---

   procedure sp_update_marks(p_mark_id marks.mark_id%type,
                             p_student_id marks.student_id%type,
                             p_subject_id marks.subject_id%type,
                             p_marks marks.marks%type,
                             p_user_id number)
   is
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
      v_count number;
   begin
      if p_mark_id is null or p_user_id is null then
         raise_application_error(-20009,'you should enter mark id as well as user id');
      else

         --- check mark exists ---

         select count(*)
         into v_count
         from marks
         where mark_id=p_mark_id;

         if v_count=0 then
            raise_application_error(-20010,'mark not found');
         end if;

         --- check student if supplied ---

         if p_student_id is not null then
            select count(*)
            into v_count
            from students
            where student_id=p_student_id;

            if v_count=0 then
               raise_application_error(-20006,'student not found');
            end if;
         end if;

         --- check subject if supplied ---

         if p_subject_id is not null then
            select count(*)
            into v_count
            from subjects
            where subject_id=p_subject_id;

            if v_count=0 then
               raise_application_error(-20007,'subject not found');
            end if;
         end if;

         --- check marks range ---

         if p_marks is not null and (p_marks<0 or p_marks>100) then
            raise_application_error(-20005,'marks should be between 0 and 100');
         end if;

         --- update marks ---

         update marks m
         set m.student_id=nvl(p_student_id,m.student_id),
             m.subject_id=nvl(p_subject_id,m.subject_id),
             m.marks=nvl(p_marks,m.marks)
         where m.mark_id=p_mark_id;

         if sql%rowcount=0 then
            raise_application_error(-20010,'mark not found');
         else
            commit;
            dbms_output.put_line(sql%rowcount||' rows updated');
            dbms_output.put_line('marks update successfully completed');
         end if;

      end if;

   exception
      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);
         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sp_update_marks',
                v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-20121,v_error_message||' '||v_error_backtrace);
   end sp_update_marks;


   ---======= deactivating marks ========---

   procedure sp_deactivate_marks(p_mark_id marks.mark_id%type,
                                 p_user_id number)
   is
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
   begin
      if p_mark_id is null or p_user_id is null then
         raise_application_error(-20011,'you should enter mark id as well as user id');
      else
         delete from marks
         where mark_id=p_mark_id;

         if sql%rowcount=0 then
            raise_application_error(-20010,'mark not found');
         else
            commit;
            dbms_output.put_line(sql%rowcount||' rows deleted');
            dbms_output.put_line('marks deleted successfully');
         end if;
      end if;

   exception
      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);
         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sp_deactivate_marks',
                v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-20122,v_error_message||' '||v_error_backtrace);
   end sp_deactivate_marks;


   ---======= getting marks details ========---

   function sf_get_marks(p_mark_id marks.mark_id%type,
                         p_user_id number)
   return marks%rowtype
   is
      v_marks_details marks%rowtype;
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
   begin
      if p_mark_id is null or p_user_id is null then
         raise_application_error(-20012,'you should enter mark id as well as user id');
      else
         select *
         into v_marks_details
         from marks
         where mark_id=p_mark_id;
      end if;

      return v_marks_details;

   exception
      when no_data_found then
         v_error_message:='mark not found';
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);
         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sf_get_marks',
                v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-20013,v_error_message);

      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);
         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sf_get_marks',
                v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-20123,v_error_message||' '||v_error_backtrace);
   end sf_get_marks;

end pkg_marksmanagement;
/