             ---========> Student table <========----

CREATE TABLE students (
    student_id      NUMBER,
    student_name    VARCHAR2(90),
    date_of_birth   DATE,
    gender          VARCHAR2(2),
    email           VARCHAR2(90),
    phone           VARCHAR2(10),
    department_id   NUMBER,
    status          VARCHAR2(30),
    faculty_id      number,
    created_date    DATE
);

-- Primary Key
ALTER TABLE students ADD CONSTRAINT pk_student_id PRIMARY KEY (student_id);

-- Required fields
ALTER TABLE students MODIFY student_name VARCHAR2(90) NOT NULL;

ALTER TABLE students MODIFY gender VARCHAR2(2) NOT NULL;

ALTER TABLE students MODIFY status VARCHAR2(30) NOT NULL;

-- Gender validation
ALTER TABLE students ADD CONSTRAINT chk_gender CHECK (UPPER(gender) IN ('F', 'M'));

-- Phone validation
ALTER TABLE students ADD CONSTRAINT chk_phone CHECK (LENGTH(phone) = 10);

---  foreign key ----
ALTER TABLE students ADD CONSTRAINT fk_department_id FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE students ADD CONSTRAINT fk_faculty_id FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id);


-- Status validation ---
ALTER TABLE students ADD CONSTRAINT ck_status CHECK (UPPER(status) IN ('ACTIVE', 'INACTIVE'));

-- Default creation date ---
ALTER TABLE students MODIFY created_date DEFAULT SYSDATE;

----=======================================================-----
        ---=======> faculty table <======--

  create table faculty(
    faculty_id  number primary key,
    faculty_name varchar2(100) not null,
    date_of_birth date,
    gender varchar2(10) not null,
    email varchar2(100) unique,
    phone varchar2(15) unique,
    department_id number not null,
    subject_id number not null,
    designation  varchar2(50) not null,
    joining_date date not null,
    status varchar2(10) default 'ACTIVE' not null
);
    ---- foreign keys ---
    alter table faculty add constraint fk_faculty_department foreign key (department_id) references departments(department_id);
    alter table faculty add constraint fk_faculty_subject foreign key(subject_id) references subjects(subject_id);
 ----- chek ----
  alter table faculty add constraint  chk_faculty_gender check (upper(gender) in ('M','F','O'));
   alter table faculty add constraint  chk_faculty_status check (upper(status) in ('ACTIVE','INACTIVE'));
             
 ---=======================================================================================
                             ---========> Courses table <========----

create table courses(
COURSE_ID number,
COURSE_NAME varchar2(56),
COURSE_CODE varchar2(56),
DEPARTMENT_ID number,
STATUS VARCHAR2(34),
CREATED_DATE date
);

----- primary key ------------
  alter table courses add constraint pk_COURSE_ID primary key(COURSE_ID);
----- not null ------------
    alter table courses modify COURSE_NAME not null;
---- foreign key -------
  alter table courses add constraint fk_course_DEPARTMENT_ID foreign key(DEPARTMENT_ID) references departments(DEPARTMENT_ID);
---- defualt Sysdate -----
 alter table courses modify CREATED_DATE date default(sysdate);
 --- unique ------
 alter table courses add constraint uq_COURSE_CODE unique(COURSE_CODE);
 ---- check -----
  alter table courses add constraint ck_course_status check(upper(status)in('ACTIVE','INACTIVE'));

 ---=======================================================================================
                           ---========> Departments table <========----

CREATE TABLE departments (
    department_id    NUMBER,
    department_name  VARCHAR2(90),
    department_code  VARCHAR2(30),
    status           VARCHAR2(90),
    creation_date    DATE
);

-- Primary Key
ALTER TABLE departments ADD CONSTRAINT pk_department_id PRIMARY KEY (department_id);

-- Status validation
ALTER TABLE departments ADD CONSTRAINT chk_department_status CHECK (UPPER(status) IN ('ACTIVE', 'INACTIVE'));

-- Default creation date
ALTER TABLE departments MODIFY creation_date DEFAULT SYSDATE;

 ---=======================================================================================
                        ---========> Enrollments table <========----

create table enrollments(
ENROLLMENT_ID number,
STUDENT_ID number,
COURSE_ID number,
ENROLLMENT_DATE date,
STATUS varchar2(15)
);

---- primary key ------
alter table ENROLLMENTS add constraint pk_ENROLLMENT_ID primary key(ENROLLMENT_ID);
---- foreign keys -----
alter table ENROLLMENTS add constraint fk_ENROLLMENTS_STUDENT_ID foreign key(STUDENT_ID) references students(STUDENT_ID);
alter table ENROLLMENTS add constraint fk_ENROLLMENTS_COURSE_ID foreign key(COURSE_ID) references COURSES(COURSE_ID);
--- defualt ----
alter table ENROLLMENTS modify ENROLLMENT_DATE default(sysdate);
---- check ------
alter table ENROLLMENTS add constraint ck_ENROLLMENTS_STATUS check(upper(status)in('ACTIVE','INACTIVE'));
----- REQUIREMENT ==> The same student cannot enroll in the same course twice.-----
alter table ENROLLMENTS add constraint UQ_STUDENT_ID_COURSE_ID UNIQUE(STUDENT_ID,COURSE_ID);

 ---=======================================================================================
                                ---========> Subjects table <========----

create table subjects(
subject_id number,
subject_name varchar(90),
course_id number,
status varchar(14),
created_date date
);

--- primary key ---
alter table subjects add constraint pk_subject_id primary key(subject_id);
--- not null -----
alter table subjects modify subject_name not null;
---- foreign key --------
alter table subjects add constraint fk_subjects_course_id foreign key(course_id) references courses(course_id);
--- check ------
alter table subjects add constraint ck_subjects_status check(upper(status)in('ACTIVE','INACTIVE'));
--- Defualt ---
alter table subjects modify created_date default(sysdate);

 ---=======================================================================================
                                  ---========> Attendance table <========----

create table attendance(
    student_id  Number,
    subject_id Number,
    attendance_date  date,
    status  varchar2(10)
);

--- foreign key ----
  alter table attendance add constraint fk_attendance_student_id foreign key(student_id) references students(student_id);
    alter table attendance add constraint fk_attendance_subject_id foreign key(subject_id) references subjects(subject_id);
 --- default ---
 alter table attendance modify attendance_date default(sysdate);
 ---- req ==> A student can have only one attendance record for a particular subject on a particular date ---
   alter table attendance add constraint uq_student_id_subject_id_attendance_date unique(student_id,subject_id,attendance_date);
---- req ==> status can have only one value either p (pressent) or a (absent) ----
    alter table attendance add constraint ck_attendance_status check(upper(status) in ('P','A'));

 ---=======================================================================================
                                    ---========> Marks table <========----

create table marks(
mark_id number,
student_Id number,
subject_id number,
marks number
);

--- primary key ------
alter table marks add constraint  pk_mark_id primary key(mark_id);
--- foreign key --------
alter table marks add constraint  fk_marks_student_id foreign key(student_Id) references students(student_Id);
alter table marks add constraint  fk_marks_subject_id foreign key(subject_id) references subjects(subject_id);
-- req ==> A student should have only one marks record for a particular subject ----
alter table marks add constraint uq_student_Id_subject_id unique(student_Id,subject_id);
-- req2 ==> marks should be greater then or equal to 0 and less then or equal to 100 ----
alter table marks add constraint ck_marks check(marks between 0 and 100);

---=======================================================================================
                                        ---========> Fees table <========----

Create table fees (
    student_id   number,
    total_amount number,
    paid_amount number,
    due_date date,
    status varchar2(10),
    created_date date
);

--- forign key ------
 alter table fees Add Constraint fk_fees_student_id foreign key (student_id) references students(student_id);
-- not null ------
alter table fees modify total_amount not null;
alter table fees modify paid_amount not null;
alter table fees modify status not null;
--- req ==> total_amount is always grater then 0 and paid amount greater or equal to 0
alter table fees Add Constraint ck_total_amount check(total_amount>0);
alter table fees Add Constraint ck_paid_amount check(paid_amount>=0);
--- req ==> status should have two values either paid or pending
alter table fees Add Constraint ck_fees_status check(upper(status) in('PAID','PENDING'));
---- default -----
alter table fees modify created_date DEFAULT(SYSDATE);
alter table fees modify due_date DEFAULT(SYSDATE+30);
-- Paid amount cannot exceed total fee ----
alter table fees add constraint ck_fees_paid_total check (paid_amount <= total_amount);

 ---=======================================================================================
                                       ---========> Users table <========----

create table users_mode(
user_id number,
username varchar2(41),
user_password varchar2(35),
Student_Id number,
user_role varchar2(20),
status varchar2(49),
created_date date
);

--- primary key ----
alter table users_mode add constraint pk_user_id primary key(user_id);
--- not null ---
alter table users_mode modify username not null;
alter table users_mode modify user_password not null;
alter table users_mode modify user_role not null;
alter table users_mode modify status not null;
---- unique key ---
alter table users_mode add constraint uq_username unique(username);
---- foreign key -----------
alter table users_mode add constraint fk_users_mode_Student_Id foreign key(Student_Id) references Students(Student_Id);
--- check() -------
alter table users_mode add constraint ck_user_role check(upper(user_role) in('FACULTY','STUDENT'));
alter table users_mode add constraint ck_users_mode_status check(upper(status)in('ACTIVE','INACTIVE'));
---- defaualt ------
alter table users_mode modify created_date default(sysdate);

 ---=======================================================================================
                                 ---========> Audit_log table <========----

create table audit_log(
    audit_id     number,
    user_id      number,
    action_type  varchar2(10),
    table_name   varchar2(50),
    record_id    number,
    action_date  date
);

--- primary key ---
alter table audit_log add constraint pk_audit_id primary key(audit_id);

--- foreign key ---
alter table audit_log add Constraint fk_audit_log_user_id foreign key(user_id) references users_mode(user_id);

--- not null ---
alter Table audit_log modify user_id not null;

alter table audit_log modify action_type not null;

alter table audit_log modify table_name not null;

alter table audit_log modify record_id not null;

--- check ---
alter table audit_log add constraint ck_audit_action_type check(upper(action_type) in ('INSERT','UPDATE','DELETE'));

--- default ---
alter table audit_log modify action_date default(sysdate);

---=======================================================================================
                                          ---========> Error_log table <========----

create table error_log(
    error_id       number,
    user_id        number,
    procedure_name varchar2(100),
    error_code     number,
    error_message  varchar2(4000),
    error_date     date
);

----- primary key ------
alter table error_log add constraint pk_error_id primary key(error_id);

---- foreign key ----
alter table error_log add constraint fk_error_log_user_id foreign key(user_id) references users_mode(user_id);

------ not null ------
alter table error_log modify procedure_name not null;

alter table error_log  modify error_code not null;

alter table error_log modify error_message not null;

------ default date ------
alter table error_log modify error_date default sysdate;

