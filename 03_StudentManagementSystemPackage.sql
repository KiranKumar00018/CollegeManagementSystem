           ---======= package specification ====-------

CREATE or REPLACE PACKAGE pkg_studentmanagement
is
   procedure sp_update_student(p_student_id students.student_id%type, 
                               p_date_of_birth students.date_of_birth%type,
                               p_gender students.gender%type,
                               p_email students.email%type,
                               p_phone students.phone%type,
                               p_department_id students.department_id%type,
                               p_status students.status%type,
                               p_faculty_id Students.faculty_id%type,
                               p_student_name students.student_name%type,
                               p_user_id number);
                               
   procedure sp_add_student(p_student_name students.student_name%type,
                            p_date_of_birth students.date_of_birth%type,
                            p_gender students.gender%type,
                            p_email students.email%type,
                            p_phone students.phone%type,
                            p_department_id students.department_id%type,
                            p_status students.status%type,
                            p_faculty_id Students.faculty_id%type,
                            p_user_id number);
                            
   procedure sp_deactivate_student(p_student_id students.student_id%type,p_user_id number);
   
   function sf_get_student(p_student_id students.student_id%type,p_user_id number) return students%rowtype;
end pkg_studentmanagement;
/

---================================================================================---
              ------===== package body ====------
              
create or replace package  body pkg_studentmanagement 
is
              --- update student procedure ---
    procedure sp_update_student(p_student_id students.student_id%type, 
                               p_date_of_birth students.date_of_birth%type,
                               p_gender students.gender%type,
                               p_email students.email%type,
                               p_phone students.phone%type,
                               p_department_id students.department_id%type,
                               p_status students.status%type,
                               p_faculty_id Students.faculty_id%type,
                               p_student_name students.student_name%type,
                               p_user_id number)
        is  
        v_error_message varchar2(3500);
        v_error_backtrace varchar2(3500);
        begin
          if p_student_id  is null or p_user_id is null then
              raise_application_error(-20001,'you should enter student id as well as user id');
         else 
               update students s set s.student_name=nvl(p_student_name,s.student_name),
                                     s.date_of_birth=nvl(p_date_of_birth,s.date_of_birth),
                                     s.gender=nvl(p_gender,s.gender),
                                     s.email=nvl(p_email,s.email),
                                     s.phone=nvl(p_phone,s.phone),
                                    s.department_id = nvl(p_department_id, s.department_id),
                                    s.status=nvl(p_status,s.status),
                                    s.faculty_id=nvl(p_faculty_id,s.faculty_id)
                where s.student_id=p_student_id;
                   if sql%rowcount = 0 then
                           raise_application_error(-20002, 'student not found');
                    else
                      commit;
                       DBMS_OUTPUT.PUT_LINE(sql%rowcount||' rows updated');
                        DBMS_OUTPUT.PUT_LINE('update successfully completed');
                    end if;  
         end if;
         exception
             when others then
                 v_error_message :=sqlerrm;
                  v_error_backtrace :=substr(dbms_utility.format_error_backtrace,-11);
                  insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
        	 values(sq_error_id.nextval,p_user_id,'sp_update_student',v_error_message,v_error_backtrace);
         commit;
         	raise_application_error(-20077,v_error_message||' '||v_error_backtrace);
        end sp_update_student; 
        
          --- adding student procedure ---
          
          procedure sp_add_student(p_student_name students.student_name%type,
                            p_date_of_birth students.date_of_birth%type,
                            p_gender students.gender%type,
                            p_email students.email%type,
                            p_phone students.phone%type,
                            p_department_id students.department_id%type,
                            p_status students.status%type,
                            p_faculty_id Students.faculty_id%type,
                            p_user_id number)
             is
              ex exception;
              pragma exception_init(ex,-1400);
              v_error_message varchar2(3500);
                 v_error_backtrace varchar2(3500);
             begin 
                 if p_user_id is null then
               raise_application_error(-20001,'you should enter user id');
              else
                 insert into students( student_id,student_name,date_of_birth,gender,email,phone,department_id,faculty_id,status) 
		values (sq_student_id.nextval,p_student_name,p_date_of_birth,p_gender,p_email,p_phone,p_department_id,p_faculty_id,p_status);
                    commit;
                 DBMS_OUTPUT.PUT_LINE(sql%rowcount||' rows added');
                        DBMS_OUTPUT.PUT_LINE('adding successfully completed');
               end if;
              exception 
                when ex then 
               raise_application_error(-20010,'you cannot give null to student_name or gender or status');
             when others then
                v_error_message :=sqlerrm;
                   v_error_backtrace:=substr(dbms_utility.format_error_backtrace,-11);
 		 insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line)
        	 values(sq_error_id.nextval,p_user_id,' sp_add_student',v_error_message,v_error_backtrace);
         commit;
         	raise_application_error(-20077,v_error_message||' '||v_error_backtrace);

             end sp_add_student;
             
             --- deactivate student procedure ---
        procedure sp_deactivate_student(p_student_id students.student_id%type,p_user_id number)
         is
                v_error_message varchar2(3500);
                 v_error_backtrace varchar2(3500);
         begin
             if p_user_id is null or p_student_id is null then
               raise_application_error(-20038,'you should enter student id as well as user id');
              else
             update students set status='inactive' where student_id=p_student_id;
                 if sql%rowcount = 0 then
                           raise_application_error(-20002, 'student not found');
                    else
                      commit;
                       DBMS_OUTPUT.PUT_LINE(sql%rowcount||' rows deactivated');
                        DBMS_OUTPUT.PUT_LINE('deactivated successfully completed');
                    end if; 
                end if;
                    exception
                 when others then
                v_error_message:=sqlerrm;
                 v_error_backtrace :=substr(dbms_utility.format_error_backtrace,-11);
                insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line) 
		values(sq_error_id.nextval,p_user_id,'sp_deactivate_student',v_error_message, v_error_backtrace);
               commit;
                raise_application_error(-20005,v_error_message||' '||v_error_backtrace);
         end sp_deactivate_student;
         
         ----- getting student details with function ----

           function sf_get_student(p_student_id students.student_id%type,p_user_id number) return students%rowtype
           is
           v_student_details students%rowtype;
           v_error_message varchar2(3500);
             v_error_backtrace varchar2(3500);
           begin
           if p_user_id is null or p_student_id is null then
               raise_application_error(-20001,'you should enter student id as well as user id');
              else
                 select * into v_student_details
                 from students where student_id=p_student_id;
              end if;
                  return v_student_details;
                   exception
                    when no_data_found then
                      raise_application_error(-20002,'Student not found');
                 when others then  
                 v_error_message:=sqlerrm;
                 v_error_backtrace :=substr(dbms_utility.format_error_backtrace,-11);
                insert into error_log(error_id,user_id,procedure_name,error_message,error_code_line) 								        values(sq_error_id.nextval,p_user_id,'sf_get_student',v_error_message,v_error_backtrace);
               commit;
                raise_application_error(-20006,v_error_message||' '||v_error_backtrace);
           end sf_get_student;
             
 end pkg_studentmanagement;
/
