---======= package specification ========---

create or replace package pkg_enrollmentmanagement
is
   procedure sp_add_enrollment(
      p_student_id enrollments.student_id%type,
      p_course_id enrollments.course_id%type,
      p_enrollment_date enrollments.enrollment_date%type,
      p_status enrollments.status%type,
      p_user_id number);

   procedure sp_update_enrollment(
      p_enrollment_id enrollments.enrollment_id%type,
      p_student_id enrollments.student_id%type,
      p_course_id enrollments.course_id%type,
      p_enrollment_date enrollments.enrollment_date%type,
      p_status enrollments.status%type,
      p_user_id number);

   procedure sp_deactivate_enrollment(
      p_enrollment_id enrollments.enrollment_id%type,
      p_user_id number);

   function sf_get_enrollment(
      p_enrollment_id enrollments.enrollment_id%type,
      p_user_id number)
      return enrollments%rowtype;

end pkg_enrollmentmanagement;
/

 ---======= package body ========---

create or replace package body pkg_enrollmentmanagement
is
   ---=======>>>> adding enrollment <<<<========---
   procedure sp_add_enrollment(
      p_student_id enrollments.student_id%type,
      p_course_id enrollments.course_id%type,
      p_enrollment_date enrollments.enrollment_date%type,
      p_status enrollments.status%type,
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
      elsif p_course_id is null then
         raise_application_error(-20003,'you should enter course id');
      else
         --- check student exists ---
         select count(*)
         into v_count
         from students
         where student_id=p_student_id;

         if v_count=0 then
            raise_application_error(-20004,'student not found');
         end if;

         --- check course exists ---
         select count(*)
         into v_count
         from courses
         where course_id=p_course_id;

         if v_count=0 then
            raise_application_error(-20005,'course not found');
         end if;

         --- check duplicate enrollment ---
         select count(*)
         into v_count
         from enrollments
         where student_id=p_student_id
         and course_id=p_course_id;

         if v_count>0 then
            raise_application_error(-20006,'student is already enrolled in this course');
         end if;

         --- insert enrollment ---
         insert into enrollments(enrollment_id,student_id,course_id,enrollment_date,status)
         values(sq_enrollment_id.nextval,p_student_id,p_course_id,
                nvl(p_enrollment_date,sysdate),nvl(p_status,'active'));

         dbms_output.put_line(sql%rowcount||' rows added');
         dbms_output.put_line('enrollment successfully completed');
      end if;
   exception
      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);
         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sp_add_enrollment',
                v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-200100,v_error_message||' '||v_error_backtrace);
   end sp_add_enrollment;

   ---=======>>> updating enrollment <<<========---
   procedure sp_update_enrollment(
      p_enrollment_id enrollments.enrollment_id%type,
      p_student_id enrollments.student_id%type,
      p_course_id enrollments.course_id%type,
      p_enrollment_date enrollments.enrollment_date%type,
      p_status enrollments.status%type,
      p_user_id number)
   is
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
      v_count number;
   begin
      if p_enrollment_id is null or p_user_id is null then
         raise_application_error(-20007,'you should enter enrollment id as well as user id');
      else
         --- check enrollment exists ---
         select count(*)
         into v_count
         from enrollments
         where enrollment_id=p_enrollment_id;

         if v_count=0 then
            raise_application_error(-20008,'enrollment not found');
         end if;

         --- check student if supplied ---
         if p_student_id is not null then
            select count(*)
            into v_count
            from students
            where student_id=p_student_id;

            if v_count=0 then
               raise_application_error(-20009,'student not found');
            end if;
         end if;

         --- check course if supplied ---
         if p_course_id is not null then
            select count(*)
            into v_count
            from courses
            where course_id=p_course_id;

            if v_count=0 then
               raise_application_error(-20010,'course not found');
            end if;
         end if;

         --- update enrollment ---
         update enrollments e
         set e.student_id=nvl(p_student_id,e.student_id),
             e.course_id=nvl(p_course_id,e.course_id),
             e.enrollment_date=nvl(p_enrollment_date,e.enrollment_date),
             e.status=nvl(p_status,e.status)
         where e.enrollment_id=p_enrollment_id;

         if sql%rowcount=0 then
            raise_application_error(-20008,'enrollment not found');
         else
            dbms_output.put_line(sql%rowcount||' rows updated');
            dbms_output.put_line('enrollment update successfully completed');
         end if;
      end if;
   exception
      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);
         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sp_update_enrollment',
                v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-200101,v_error_message||' '||v_error_backtrace);
   end sp_update_enrollment;

   ---======= deactivating enrollment ========---
   procedure sp_deactivate_enrollment(
      p_enrollment_id enrollments.enrollment_id%type,
      p_user_id number)
   is
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
   begin
      if p_enrollment_id is null or p_user_id is null then
         raise_application_error(-20011,'you should enter enrollment id as well as user id');
      else
         update enrollments
         set status='inactive'
         where enrollment_id=p_enrollment_id;

         if sql%rowcount=0 then
            raise_application_error(-20008,'enrollment not found');
         else
            dbms_output.put_line(sql%rowcount||' rows deactivated');
            dbms_output.put_line('enrollment deactivation successfully completed');
         end if;
      end if;
   exception
      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);
         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sp_deactivate_enrollment',
                v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-200102,v_error_message||' '||v_error_backtrace);
   end sp_deactivate_enrollment;

   ---======= getting enrollment details ========---
   function sf_get_enrollment(
      p_enrollment_id enrollments.enrollment_id%type,
      p_user_id number)
      return enrollments%rowtype
   is
      v_enrollment_details enrollments%rowtype;
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
   begin
      if p_enrollment_id is null or p_user_id is null then
         raise_application_error(-20012,'you should enter enrollment id as well as user id');
      else
         select *
         into v_enrollment_details
         from enrollments
         where enrollment_id=p_enrollment_id;
      end if;

      return v_enrollment_details;
   exception
      when no_data_found then
         v_error_message:='enrollment not found';
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-8);
         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sf_get_enrollment',
                v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-20013,v_error_message);

      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);
         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sf_get_enrollment',
                v_error_message,v_error_backtrace);
         commit;
         raise_application_error(-200103,v_error_message||' '||v_error_backtrace);
   end sf_get_enrollment;
end pkg_enrollmentmanagement;
/