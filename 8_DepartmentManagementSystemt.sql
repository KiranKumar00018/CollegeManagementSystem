---======= package specification ========---

create or replace package pkg_departmentmanagement
is
   procedure sp_add_department(p_department_name departments.department_name%type,
                                p_department_code departments.department_code%type,
                                p_status departments.status%type,
                                p_creation_date departments.creation_date%type,
                                p_user_id number);

   procedure sp_update_department(p_department_id departments.department_id%type,
                                  p_department_name departments.department_name%type,
                                  p_department_code departments.department_code%type,
                                  p_status departments.status%type,
                                  p_creation_date departments.creation_date%type,
                                  p_user_id number);

   procedure sp_deactivate_department(p_department_id departments.department_id%type,
                                       p_user_id number);

   function sf_get_department(p_department_id departments.department_id%type,
                               p_user_id number)
   return departments%rowtype;
end pkg_departmentmanagement;
/

---================================================================================---
------===== package body ======------

create or replace package body pkg_departmentmanagement
is

   ---======= adding department ========---

   procedure sp_add_department(p_department_name departments.department_name%type,
                               p_department_code departments.department_code%type,
                               p_status departments.status%type,
                               p_creation_date departments.creation_date%type,
                               p_user_id number)
   is
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
      v_count number;
   begin
      if p_user_id is null then
         raise_application_error(-20001,'you should enter user id');
      elsif p_department_name is null then
         raise_application_error(-20002,'you should enter department name');
      elsif p_department_code is null then
         raise_application_error(-20003,'you should enter department code');
      elsif p_status is null then
         raise_application_error(-20004,'you should enter status');
      else

         --- check department name already exists ---

         select count(*)
         into v_count
         from departments
         where upper(department_name)=upper(p_department_name);

         if v_count>0 then
            raise_application_error(-20005,'department name already exists');
         end if;

         --- check department code already exists ---

         select count(*)
         into v_count
         from departments
         where upper(department_code)=upper(p_department_code);

         if v_count>0 then
            raise_application_error(-20006,'department code already exists');
         end if;

         --- insert department ---

         insert into departments(department_id,department_name,department_code,status,creation_date)
         values(sq_department_id.nextval,p_department_name,p_department_code,
                p_status,nvl(p_creation_date,sysdate));

         commit;
         dbms_output.put_line(sql%rowcount||' rows added');
         dbms_output.put_line('department successfully completed');

      end if;

   exception
      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);

         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sp_add_department',
                v_error_message,v_error_backtrace);

         commit;
         raise_application_error(-20118,v_error_message||' '||v_error_backtrace);

   end sp_add_department;


   ---======= updating department ========---

   procedure sp_update_department(p_department_id departments.department_id%type,
                                  p_department_name departments.department_name%type,
                                  p_department_code departments.department_code%type,
                                  p_status departments.status%type,
                                  p_creation_date departments.creation_date%type,
                                  p_user_id number)
   is
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
      v_count number;
   begin
      if p_department_id is null or p_user_id is null then
         raise_application_error(-20007,'you should enter department id as well as user id');
      else

         --- check department exists ---

         select count(*)
         into v_count
         from departments
         where department_id=p_department_id;

         if v_count=0 then
            raise_application_error(-20008,'department not found');
         end if;

         --- check department name if supplied ---

         if p_department_name is not null then

            select count(*)
            into v_count
            from departments
            where upper(department_name)=upper(p_department_name)
            and department_id<>p_department_id;

            if v_count>0 then
               raise_application_error(-20009,'department name already exists');
            end if;

         end if;

         --- check department code if supplied ---

         if p_department_code is not null then

            select count(*)
            into v_count
            from departments
            where upper(department_code)=upper(p_department_code)
            and department_id<>p_department_id;

            if v_count>0 then
               raise_application_error(-20117,'department code already exists');
            end if;

         end if;

         --- update department ---

         update departments d
         set d.department_name=nvl(p_department_name,d.department_name),
             d.department_code=nvl(p_department_code,d.department_code),
             d.status=nvl(p_status,d.status),
             d.creation_date=nvl(p_creation_date,d.creation_date)
         where d.department_id=p_department_id;

         if sql%rowcount=0 then
            raise_application_error(-20008,'department not found');
         else
            commit;
            dbms_output.put_line(sql%rowcount||' rows updated');
            dbms_output.put_line('department update successfully completed');
         end if;

      end if;

   exception
      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);

         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sp_update_department',
                v_error_message,v_error_backtrace);

         commit;
         raise_application_error(-20116,v_error_message||' '||v_error_backtrace);

   end sp_update_department;


   ---======= deactivating department ========---

   procedure sp_deactivate_department(p_department_id departments.department_id%type,
                                       p_user_id number)
   is
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
   begin
      if p_department_id is null or p_user_id is null then
         raise_application_error(-20011,'you should enter department id as well as user id');
      else

         update departments
         set status='inactive'
         where department_id=p_department_id;

         if sql%rowcount=0 then
            raise_application_error(-20008,'department not found');
         else
            commit;
            dbms_output.put_line(sql%rowcount||' rows deactivated');
            dbms_output.put_line('department deactivation successfully completed');
         end if;

      end if;

   exception
      when others then
         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);

         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sp_deactivate_department',
                v_error_message,v_error_backtrace);

         commit;
         raise_application_error(-20115,v_error_message||' '||v_error_backtrace);

   end sp_deactivate_department;


   ---======= getting department details ========---

   function sf_get_department(p_department_id departments.department_id%type,
                              p_user_id number)
   return departments%rowtype
   is
      v_department_details departments%rowtype;
      v_error_message varchar2(3500);
      v_error_backtrace varchar2(3500);
   begin
      if p_department_id is null or p_user_id is null then
         raise_application_error(-20012,'you should enter department id as well as user id');
      else

         select *
         into v_department_details
         from departments
         where department_id=p_department_id;

      end if;

      return v_department_details;

   exception
      when no_data_found then

         v_error_message:='department not found';
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);

         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sf_get_department',
                v_error_message,v_error_backtrace);

         commit;
         raise_application_error(-20013,v_error_message);

      when others then

         v_error_message:=sqlerrm;
         v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);

         insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
         values(sq_error_id.nextval,p_user_id,'sf_get_department',
                v_error_message,v_error_backtrace);

         commit;
         raise_application_error(-200114,v_error_message||' '||v_error_backtrace);

   end sf_get_department;

end pkg_departmentmanagement;
/