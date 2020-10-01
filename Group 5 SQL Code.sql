---------------------------------------------------------------------------
--                       Department Table                                --
---------------------------------------------------------------------------
CREATE TABLE DEPARTMENT(
    DeptID      number(3)   NOT NULL PRIMARY KEY,
    DeptName    varchar(50) NOT NULL,
    DeptHead    number(10)  NOT NULL
    );
 
---------------------------------------------------------------------------
--                       ROOM Table                                      --
---------------------------------------------------------------------------              
CREATE TABLE ROOM(
    RoomNumber  number(3)   NOT NULL PRIMARY KEY,
    RoomType    varchar(30) NOT NULL,
    CHECK (RoomType in ('Lab', 'Emergency Room', 'Consult', 'Surgery', 'ICU'))
    );

---------------------------------------------------------------------------
--                       Medication Table                                --
---------------------------------------------------------------------------                 
CREATE TABLE MEDICATION(
    MedicationID    number(10)      NOT NULL PRIMARY KEY,
    MedName         varchar2(20)    NOT NULL,
    Brand           varchar2(20)    NOT NULL,
    Instructions    varchar2(255)   NOT NULL
    );
    
---------------------------------------------------------------------------
--                       Patient Table                                   --
---------------------------------------------------------------------------
CREATE TABLE PATIENT (
    SSN                       varchar2(11)    NOT NULL PRIMARY KEY,
    PatientFname              varchar2(20)    NOT NULL,
    PatientLname              varchar2(25)    NOT NULL,
    DOB                       DATE            NOT NULL,
    Address                   varchar2(60),
    Phone                     varchar2(20),
    InsuranceName             varchar2(50),
    PatientPhysician          number(10),
    Next_Of_Kin_First_Name    varchar2(20)    NOT NULL,
    Next_Of_Kin_Last_Name     varchar2(25)    NOT NULL,
    PatientEmail              varchar2(50));

---------------------------------------------------------------------------
--                          Nurse Table                                  --
---------------------------------------------------------------------------
CREATE TABLE NURSE(
    NurseID         number(10)      NOT NULL PRIMARY KEY,
    SSN             varchar2(11)    UNIQUE NOT NULL ,
    NurseFname      varchar2(20)    NOT NULL,
    NurseLname      varchar2(25)    NOT NULL,
    NursePosition   varchar2(30)    NOT NULL,
    NurseDepartment number(3)       NOT NULL,
    Registered      number(1)       NOT NULL,
    NurseEmail      varchar2(50),
    CHECK (NursePosition IN ('Family','Emergency Room','Medical-Surgical','Pediatrics','Oncology','Dermatology','Aesthetic','Cardiovascular','Laboratory and delivery')),
    CHECK (Registered IN ('0', '1'))
);

---------------------------------------------------------------------------
--                          Physician Table                              --
---------------------------------------------------------------------------
CREATE TABLE PHYSICIAN(
    PhysicianID         number(10)      NOT NULL PRIMARY KEY,
    SSN                 varchar2(11)    UNIQUE NOT NULL,
    PhysicianFname      varchar2(20)    NOT NULL,
    PhysicianLname      varchar2(20)    NOT NULL,
    Partnered    	      Number(1)       NOT NULL, 
    Email               varchar2(30)    NOT NULL,
    DepartmentID        number(3)       NOT NULL,
    CHECK (Partnered IN ('0', '1'))
    );

---------------------------------------------------------------------------
--                          Referrals Table                              --
---------------------------------------------------------------------------    
CREATE TABLE REFERRALS (
    ReferralID          number(10)      NOT NULL PRIMARY KEY,
    PhysicianID	    	number(10)      NOT NULL,
    PatientID	    	   varchar2(11)    NOT NULL,                
    Reason              varchar2(40)    NOT NULL,
    ReferralTo          varchar2(30)    NOT NULL
    );
    
---------------------------------------------------------------------------
--                          Prescription Table                           --
---------------------------------------------------------------------------     
CREATE TABLE PRESCRIPTION(
    PrescriptionID  number(10)      NOT NULL PRIMARY KEY,
    PhysicianID	  number(10)      NOT NULL,
    PatientID	     varchar2(11)    NOT NULL,                
    Medication      number(10)      NOT NULL,
    PrescDate       DATE	         NOT NULL,                
    AppointmentID   number(10)      NOT NULL,
    Dose            varchar2(50)    NOT NULL
    );
    
---------------------------------------------------------------------------
--                          Appointments Table                           --
---------------------------------------------------------------------------       
CREATE TABLE APPOINTMENTS(
    AppointmentID   number(10)      NOT NULL PRIMARY KEY,
    ApStart	        DATE            NOT NULL,
    ApEnd	        DATE            NOT NULL,                
    ApRoom          number(3)       NOT NULL,
    ApPatient       varchar(11)     NOT NULL,                
    PrepNurse       number(10)      NOT NULL,
    ApPhysician     number(10)      NOT NULL,
    IsAProcedure    number(1)       NOT NULL
    CHECK (IsAProcedure IN ('0', '1'))
    );

---------------------------------------------------------------------------
--                       Time Overlap Triggers                           --
---------------------------------------------------------------------------           
CREATE OR REPLACE TRIGGER Check_Physicians
  BEFORE INSERT OR UPDATE 
  ON APPOINTMENTS
  FOR EACH ROW
  DECLARE
   vCount   NUMBER;
   vCount2  NUMBER;
   vCount3  NUMBER;

   BEGIN
     SELECT COUNT(*)
      INTO vCount
     FROM APPOINTMENTS 
     WHERE ApPhysician = :NEW.ApPhysician and
           :NEW.ApStart >= ApStart    and
           :New.ApStart <= ApEnd   ;
     IF vCount > 0 THEN
        raise_application_error(-20005,'Physician Scheduling Overlap');
     END IF;
     
    SELECT COUNT(*)
      INTO vCount2
     FROM APPOINTMENTS 
     WHERE ApPhysician = :NEW.ApPhysician and
           :NEW.ApEnd >= ApStart    and
           :New.ApEnd <= ApEnd   ;
     IF vCount2 > 0 THEN
        raise_application_error(-20005,'Physician Scheduling Overlap');
     END IF;
    
    SELECT COUNT(*)
      INTO vCount3
     FROM APPOINTMENTS 
     WHERE ApPhysician = :NEW.ApPhysician and
           :NEW.ApEnd >= ApEnd    and
           :New.ApStart <= ApStart   ;
     IF vCount3 > 0 THEN
        raise_application_error(-20005,'Physician Scheduling Overlap');
     END IF;     
   END;
/
CREATE OR REPLACE TRIGGER Check_Nurses
  BEFORE INSERT OR UPDATE 
  ON APPOINTMENTS
  FOR EACH ROW
  DECLARE
   vCount   NUMBER;
   vCount2  NUMBER;
   vCount3  NUMBER;
    BEGIN
     SELECT COUNT(*)
      INTO vCount
     FROM APPOINTMENTS 
     WHERE PrepNurse = :NEW.PrepNurse and
           :NEW.ApStart >= ApStart    and
           :New.ApStart <= ApEnd   ;
     IF vCount > 0 THEN
        raise_application_error(-20005,'Nurse Scheduling Overlap');
     END IF;

    SELECT COUNT(*)
      INTO vCount2
     FROM APPOINTMENTS 
     WHERE PrepNurse = :NEW.PrepNurse and
           :NEW.ApEnd >= ApStart    and
           :New.ApEnd <= ApEnd   ;
     IF vCount2 > 0 THEN
        raise_application_error(-20005,'Nurse Scheduling Overlap');
     END IF;
    SELECT COUNT(*)
      INTO vCount3
     FROM APPOINTMENTS 
     WHERE PrepNurse = :NEW.PrepNurse and
           :NEW.ApEnd >= ApEnd    and
           :New.ApStart <= ApStart   ;
     IF vCount3 > 0 THEN
        raise_application_error(-20005,'Nurse Scheduling Overlap');
     END IF;     
   END;
/
CREATE OR REPLACE TRIGGER Check_Patients
  BEFORE INSERT OR UPDATE 
  ON APPOINTMENTS
  FOR EACH ROW
  DECLARE
   vCount   NUMBER;
   vCount2  NUMBER;
   vCount3  NUMBER;
   BEGIN
     SELECT COUNT(*)
      INTO vCount
     FROM APPOINTMENTS 
     WHERE ApPatient = :NEW.ApPatient and
           :NEW.ApStart >= ApStart    and
           :New.ApStart <= ApEnd   ;
     IF vCount > 0 THEN
        raise_application_error(-20005,'Patient Scheduling Overlap');
     END IF;
    SELECT COUNT(*)
      INTO vCount2
     FROM APPOINTMENTS 
     WHERE ApPatient = :NEW.ApPatient and
           :NEW.ApEnd >= ApStart    and
           :New.ApEnd <= ApEnd   ;
     IF vCount2 > 0 THEN
        raise_application_error(-20005,'Patient Scheduling Overlap');
     END IF;
    SELECT COUNT(*)
      INTO vCount3
     FROM APPOINTMENTS 
     WHERE ApPatient = :NEW.ApPatient and
           :NEW.ApEnd >= ApEnd    and
           :New.ApStart <= ApStart   ;
     IF vCount3 > 0 THEN
        raise_application_error(-20005,'Patient Scheduling Overlap');
     END IF;     
   END;
/
CREATE OR REPLACE TRIGGER Check_Rooms
  BEFORE INSERT OR UPDATE 
  ON APPOINTMENTS
  FOR EACH ROW
  DECLARE
   vCount   NUMBER;
   vCount2  NUMBER;
   vCount3  NUMBER;
   BEGIN
     SELECT COUNT(*)
      INTO vCount
     FROM APPOINTMENTS 
     WHERE ApRoom = :NEW.ApRoom and
           :NEW.ApStart >= ApStart    and
           :New.ApStart <= ApEnd   ;
     IF vCount > 0 THEN
        raise_application_error(-20005,'Room Scheduling Overlap');
     END IF;

    SELECT COUNT(*)
      INTO vCount2
     FROM APPOINTMENTS 
     WHERE ApRoom = :NEW.ApRoom and
           :NEW.ApEnd >= ApStart    and
           :New.ApEnd <= ApEnd   ;
     IF vCount2 > 0 THEN
        raise_application_error(-20005,'Room Scheduling Overlap');
     END IF;
    SELECT COUNT(*)
      INTO vCount3
     FROM APPOINTMENTS 
     WHERE ApRoom = :NEW.ApRoom and
           :NEW.ApEnd >= ApEnd    and
           :New.ApStart <= ApStart   ;
     IF vCount3 > 0 THEN
        raise_application_error(-20005,'Room Scheduling Overlap');
     END IF;     
   END;
/     
  
--Insert Appointments Tuples
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456777,'4-Jan-09 08:30:00','4-Jan-09 09:00:00',106,'715-01-3961',2000000001,1112233445,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456778,'4-Feb-09 08:00:00','4-Feb-09 08:45:00',107,'386-97-2781',2000000003,1112233446,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456779,'5-Mar-10 09:00:00','5-Mar-10 09:45:00',108,'451-19-1951',2000000003,1112233447,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456780,'4-Jan-11 10:00:00','4-Jan-11 10:30:00',109,'389-89-1463',2000000002,1112233448,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456781,'9-Jan-09 10:00:00','9-Jan-09 11:00:00',110,'694-64-2401',2000000001,1112233449,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456782,'12-Feb-09 11:00:00','12-Feb-09 11:45:00',201,'603-43-2266',2000000001,1112233450,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456783,'4-Apr-09 11:00:00','4-Apr-09 11:45:00',201,'541-11-5179',2000000003,1112233451,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456784,'4-Jun-09 08:30:00','4-Jun-09 09:15:00',202,'449-66-8269',2000000003,1112233452,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456785,'4-Jul-09 07:30:00','4-Jul-09 08:00:00',203,'456-25-5209',2000000004,1112233453,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456786,'4-Aug-09 08:00:00','4-Aug-09 09:00:00',204,'409-18-1177',2000000003,1112233454,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456787,'4-Sep-09 09:00:00','4-Sep-09 09:15:00',205,'554-01-4351',2000000002,1112233455,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456788,'4-Oct-09 10:30:00','4-Oct-09 10:45:00',206,'286-56-0001',2000000001,1112233456,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456789,'4-Nov-09 11:30:00','4-Nov-09 12:00:00',206,'001-55-8781',2000000002,1112233457,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456790,'4-Dec-09 12:30:00','4-Dec-09 13:00:00',206,'595-28-1975',2000000003,1112233458,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456791,'4-Dec-08 13:00:00','4-Dec-08 13:45:00',206,'391-81-6556',2000000003,1112233459,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456792,'5-Dec-09 13:00:00','5-Dec-09 13:45:00',205,'311-67-1361',2000000002,1112233460,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456793,'6-Dec-09 14:00:00','6-Dec-09 14:30:00',203,'378-01-7171',2000000001,1112233461,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456794,'7-Dec-09 15:00:00','7-Dec-09 15:45:00',205,'676-86-6257',2000000004,1112233462,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456795,'8-Dec-09 08:30:00','8-Dec-09 09:00:00',203,'243-14-3840',2000000004,1112233463,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456796,'9-Dec-09 07:30:00','9-Dec-09 08:30:00',301,'691-13-0001',2000000003,1112233464,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456797,'10-Dec-09 09:30:00','10-Dec-09 10:00:00',201,'841-61-6826',2000000005,1112233465,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456798,'11-Dec-09 09:30:00','11-Dec-09 10:30:00',108,'041-85-2941',2000000005,1112233465,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456799,'12-Dec-09 10:00:00','12-Dec-09 11:00:00',110,'463-92-1870',2000000001,1112233467,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456800,'13-Dec-09 15:00:00','13-Dec-09 15:15:00',110,'673-91-9121',2000000001,1112233468,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456801,'14-Dec-09 15:00:00','14-Dec-09 15:30:00',201,'838-81-4390',2000000005,1112233469,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456802,'16-Dec-09 13:00:00','16-Dec-09 13:45:00',106,'533-37-4939',2000000003,1112233470,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456803,'15-Dec-09 14:00:00','15-Dec-09 14:45:00',302,'183-09-5161',2000000004,1112233471,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456804,'17-Dec-09 16:00:00','17-Dec-09 16:15:00',107,'874-33-9729',2000000003,1112233472,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456805,'18-Dec-09 08:00:00','18-Dec-09 08:30:00',305,'501-09-2821',2000000004,1112233473,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (123456806,'19-Dec-09 09:00:00','19-Dec-09 09:45:00',304,'451-19-1951',2000000002,1112233474,0);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (1000000029,'10-Dec-09 10:30:00','10-Dec-09 11:00:00',306,'841-61-6826',2000000004,1112233465,1);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (1000000030,'11-Dec-09 10:45:00','11-Dec-09 11:30:00',307,'041-85-2941',2000000005,1112233465,1);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (1000000031,'12-Dec-09 11:15:00','12-Dec-09 12:00:00',309,'463-92-1870',2000000001,1112233467,1);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (1000000032,'13-Dec-09 15:30:00','13-Dec-09 16:15:00',309,'673-91-9121',2000000001,1112233468,1);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (1000000033,'14-Dec-09 15:45:00','14-Dec-09 16:30:00',310,'838-81-4390',2000000005,1112233469,1);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (1000000034,'16-Dec-09 14:00:00','16-Dec-09 14:45:00',307,'533-37-4939',2000000003,1112233470,1);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (1000000035,'15-Dec-09 15:00:00','15-Dec-09 15:45:00',306,'183-09-5161',2000000004,1112233471,1);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (1000000036,'17-Dec-09 16:30:00','17-Dec-09 16:45:00',306,'874-33-9729',2000000003,1112233472,1);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (1000000038,'18-Dec-09 09:00:00','18-Dec-09 10:30:00',308,'501-09-2821',2000000004,1112233473,1);
INSERT INTO APPOINTMENTS(AppointmentID,ApStart,ApEnd,ApRoom,ApPatient,PrepNurse,ApPhysician,IsAProcedure) Values (1000000039,'19-Dec-09 10:00:00','19-Dec-09 11:00:00',309,'451-19-1951',2000000002,1112233474,1);

--Insert Department Tuples
INSERT INTO DEPARTMENT(DeptId,DeptHead,DeptName) VALUES (100, 1112233445, 'Family Practice');
INSERT INTO DEPARTMENT(DeptId,DeptHead,DeptName) VALUES (101, 1112233448, 'Pediatrics');
INSERT INTO DEPARTMENT(DeptId,DeptHead,DeptName) VALUES (102, 1112233451, 'Allergy');
INSERT INTO DEPARTMENT(DeptId,DeptHead,DeptName) VALUES (103, 1112233454, 'Oncology');
INSERT INTO DEPARTMENT(DeptId,DeptHead,DeptName) VALUES (104, 1112233457, 'Cardiology');
INSERT INTO DEPARTMENT(DeptId,DeptHead,DeptName) VALUES (105, 1112233460, 'Dermatology');
INSERT INTO DEPARTMENT(DeptId,DeptHead,DeptName) VALUES (106, 1112233463, 'Infectious Diseases');
INSERT INTO DEPARTMENT(DeptId,DeptHead,DeptName) VALUES (107, 1112233466, 'Lab');
INSERT INTO DEPARTMENT(DeptId,DeptHead,DeptName) VALUES (108, 1112233469, 'Nutritional');
INSERT INTO DEPARTMENT(DeptId,DeptHead,DeptName) VALUES (109, 1112233472, 'Cosmetic');
INSERT INTO DEPARTMENT(DeptId,DeptHead,DeptName) VALUES (110, 1112233473, 'Aesthetic');

--Insert Medication Tuples
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Levothyroxine','250 mg take two pills a day',1000000049,'Levoxryl');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Lisonpril','300 mg take one pill a day',1000000000,'Zestril');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Atrovastatin','100 mg take one pill a day',1000000001,'Lipitor');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Metformin','1000 mg take one pill in the morning',1000000002,'Metafor');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Amlodipine','250 mg take two pills a day',1000000003,'Amoly');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Metopolol','500 mg take 3 pills a day',1000000004,'Metapol');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Omeprazole','88 mg take one pill a day',1000000005,'Prazole');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Simvastatin','10 mg take two orally a day after every meal',1000000006,'Simva');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Losartan','2 mg take before bed',1000000007,'Losatine');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Albuterol','2 mg take before bed',1000000008,'Albutral');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Gabapentin','500 mg take 3 pills a day',1000000009,'Gabacyl');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Sertaline','25 mg take after every meal',1000000010,'Sertaline');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Fluticasone','50 mg take before/after every meal',1000000011,'Tylenol');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Acetaminphen','2 mg take after every meal',1000000012,'Tylenol');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Amoxilillin','15 mg take two pills once every other day',1000000013,'Amoxigol');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Alprazolam','20 mg take once everyday other day',1000000014,'Alprazine');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Athenolol','550 mg take once in the morning orally',1000000015,'Athenol');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Montelukast','1000 mg apply to wound lightly (keep from sun)',1000000016,'Monetacol');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Trazodone','2 mg take before bed',1000000017,'Tazadine');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Pantoprazole','45 mg apply cream to wound',1000000018,'Prazole');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Escitalopram','600 mg take before bed',1000000019,'Albutral');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Pravastatin','99 mg take once after every meal',1000000020,'Gabacyl');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Bupropion','100 mg take one pill a day',1000000021,'Burpafine');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Flouxetine','500 mg take 3 pills a day',1000000022,'Tylenol');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Carvedilol','300 mg take one pill a day',1000000023,'Lipitor');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Prednisone','88 mg take one pill a day',1000000024,'Diacne');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Tamsulosin','45 mg apply cream to wound',1000000025,'Tums');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Potassium','99 mg take once after every meal',1000000026,'Burpafine');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Ibuprofen','20 mg take once everyday other day',1000000027,'Prazole');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Aspirin','1000 mg take one pill in the morning',1000000028,'Alprazine');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Warfarin','25 mg take after every meal',1000000029,'Warzine');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Clonazepam','45 mg apply cream to wound',1000000030,'Losatine');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Glipizide','75 mg take one before bed',1000000031,'Albutral');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Methyphenidate','500 mg take 3 pills a day',1000000032,'Methapine');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Duloxetine','500 mg take 3 pills a day',1000000033,'Duloxine');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Azithromycin','300 mg take one pill a day',1000000034,'Azitine');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Ranitidine','1000 mg apply to wound lightly (keep from sun)',1000000035,'Raintine');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Topiramate','300 mg take one pill a day',1000000036,'Topamine');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Naproxen','200 mg take one orally before/after meal',1000000037,'Naproxy');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Cetirizine','45 mg apply cream to wound',1000000038,'Cetrizoy');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Glimepiride','50 mg inhale once a day',1000000039,'ImmunFresh');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Estradiol','1000 mg apply to wound lightly (keep from sun)',1000000040,'Feelzine');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Lorazepam','20 mg take once everyday other day',1000000041,'Lipitor');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Oxycodone','500 mg take 3 pills a day',1000000042,'Amoxigol');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Venlafaxine','700 mg take once a day before bed',1000000043,'Venalzine');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Meloxicam','75 mg take one before bed',1000000044,'Monetacol');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Fenofibrate','2 mg take after every meal',1000000045,'Enxy');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Lovastatin','45 mg apply cream to wound',1000000046,'Lovastine');
INSERT INTO MEDICATION(MedName,Instructions,MedicationID,Brand) VALUES ('Esomeprazole','100 mg take one pill a day',1000000047,'Esome');

--Insert Room Tuples
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (001,'Lab');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (002,'Lab');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (003,'Lab');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (004,'Lab');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (005,'Lab');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (101,'Emergency Room');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (102,'Emergency Room');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (103,'Emergency Room');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (104,'Emergency Room');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (105,'Emergency Room');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (106,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (107,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (108,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (109,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (110,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (201,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (202,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (203,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (204,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (205,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (206,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (207,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (208,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (209,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (210,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (301,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (302,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (303,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (304,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (305,'Consult');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (306,'Surgery');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (307,'Surgery');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (308,'Surgery');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (309,'Surgery');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (310,'Surgery');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (401,'ICU');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (402,'ICU');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (403,'ICU');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (404,'ICU');
INSERT INTO ROOM(RoomNumber,roomtype) VALUES (405,'ICU');

--Insert Patient Tuples
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('715-01-3961','Alexis','Lopez','04-Jul-00','8836 Nut Swamp Court, Spring Valley, CA 91977','(989) 339-2961','Blue Cross',1112233445,'Angelita','Nunez','Alexis117@aol.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('386-97-2781','Narek','Hovhannesyan','28-Oct-76','308 Hill Field Street, San Jose, CA 95122','(859) 550-7029','Oxford Health Plans',1112233446,'Mickey','Mason','Narek1@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('451-19-1951','Daniel','Ortega','25-Nov-97','8425 Hill St., Los Angeles, CA 90066','(202) 882-0269','Molina Healthcare',1112233448,'Lawerence','Schroeder','Daniel729@aol.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('389-89-1463','Dorian','Portillo','05-Mar-64','91 Catherine Street, San Jose, CA 95111','(778) 017-5280','Golden Rule Insurance Company',1112233449,'Randall','Sullivan','Dorian811@icloud.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('694-64-2401','Kristen','White','16-Nov-64','41 Hillcrest Street, San Jose, CA 95127','(283) 017-7374','Blue Cross',1112233450,'Shawn','Hogan','Kristen498@mail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('603-43-2266','Jessica','Mier','22-May-05','616 Wild Rose Drive, Riverside, CA 92503','(911) 252-3211','Cigna',1112233451,'Ed','Mccarthy','Jessica211@mail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('541-11-5179','Alejandro','Avila','18-Apr-83','177 Arnold St., Victorville, CA 92392','(673) 362-7727','Blue Cross',1112233452,'Domingo','Kirby','Alejandro613@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('449-66-8269','Oscar','Mercado','11-Jan-72','7518 Armstrong Rd., Vista, CA 92083','(489) 611-7279','Molina Healthcare',1112233453,'Alfreda','Bowers','Oscar841@icloud.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('569-57-9157','Erik','Ramirez','14-Oct-89','798 N. Lees Creek St., Lancaster, CA 93535','(667) 140-5424','Oxford Health Plans',1112233454,'Helene','Frost','Erik856@icloud.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('456-25-5209','Hector','Leon','09-Jul-96','716 E. Windfall St., Huntington Park, CA 90255','(997) 789-8401','AARP',1112233455,'Cleo','Daniels','Hector127@mail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('409-18-1177','Fatima','Alba','12-Nov-93','31 N. 6th Court, North Hollywood, CA 91605','(980) 818-3411','State Farm',1112233456,'Jayne','Mcintyre','Fatima381@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('554-01-4351','Irwin','Cayo','09-Apr-81','8638 Sussex Ave., San Pedro, CA 90731','(737) 814-7956','State Farm',1112233457,'May','Shepard','Irwin96@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('286-56-0001','Brian','Duenas','20-Oct-86','7582 James St., San Diego, CA 92105','(320) 017-6401','United Health Group',1112233458,'Ariel','Webb','Brian817@aol.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('001-55-8781','Ebony','Cubias','12-Jul-97','8973 Penn Lane, Paramount, CA 90723','(885) 916-0743','Liberty Medical',1112233459,'Rhett','Woodward','Ebony961@aol.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('595-28-1975','Mandy','Ledford','09-Apr-87','7059 NW. Circle Rd., Oceanside, CA 92054','(865) 436-0571','Unitrin',1112233460,'Celeste','Davies','Mandy1@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('391-81-6556','Kristin','Meza','31-Dec-79','101 Park St., Los Angeles, CA 90022','(541) 646-4441','Golden Rule Insurance Company',1112233461,'Dante','Lloyd','Kristin889@icloud.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('311-67-1361','Quimpie','Tuada','19-Mar-75','398 Van Dyke Drive, Pomona, CA 91766','(256) 233-6049','Molina Healthcare',1112233462,'Michel','Clements','Quimpie289@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('378-01-7171','Kimberly','Astorga','26-Oct-66','28 East Country Club St., Bakersfield, CA 93307','(901) 312-9345','Fortis',1112233463,'Devin','Bautista','Kimberly981@icloud.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('676-86-6257','Warren','Green','20-Jun-96','8497 Valley Farms Ave., San Diego, CA 92114','(295) 712-9533','State Farm',1112233464,'Jocelyn','Harris','Warren609@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('243-14-3840','Anthony','Serrano','15-Jan-61','8974 St Paul Drive, National City, CA 91950','(937) 702-3609','Liberty Medical',1112233465,'Mathew','Horn','Anthony169@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('691-13-0001','John','Abadines','22-Jan-60','7661 South White Street, Huntington Beach, CA 92647','(673) 915-7019','Kaleida Health',1112233466,'Laurence','Norman','John457@mail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('841-61-6826','Christopher','Casillas','26-May-62','9971 Hickory Ave., Modesto, CA 95350','(181) 171-9791','Unitrin',1112233467,'Dan','Doyle','Christopher1@yahoo.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('041-85-2941','Tonny','Kasih','02-Feb-92','8969 Sussex Street, Montebello, CA 90640','(946) 970-6343','Golden Rule Insurance Company',1112233468,'Porter','Sanford','Tonny506@aol.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('463-92-1870','Tatiana','Rodrigez','15-Jan-03','975 High Street, Tulare, CA 93274','(673) 014-9453','State Farm',1112233469,'Dana','Dickerson','Tatiana577@aol.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('673-91-9121','Dean','Peterson','18-Nov-89','85 NE. Sycamore Ave., Palmdale, CA 93550','(401) 197-5824','Unitrin',1112233470,'Theodore','Christensen','Dean680@outlook.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('838-81-4390','Marsha','Bridges','24-Apr-81','15 West Walnut Lane, Cerritos, CA 90703','(987) 316-9385','Health Spring',1112233471,'Harold','Decker','Marsha65@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('533-37-4939','Joshua','Garcia','25-Dec-79','5 Beaver Ridge St., San Diego, CA 92117','(396) 918-8859','Aetna',1112233472,'Christine','Frazier','Joshua929@icloud.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('183-09-5161','Mark','Ortiz','16-Sep-86','9940 8th St., South Gate, CA 90280','(741) 733-9541','Cigna',1112233473,'Pansy','Buck','Mark703@yahoo.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('874-33-9729','Nolan','White','18-Sep-86','989 Surrey Ave., San Pablo, CA 94806','(465) 434-0561','Kaleida Health',1112233474,'Ethan','Campos','Nolan216@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('501-09-2821','Maylen','Lim','12-Nov-98','54 Princeton Rd., Van Nuys, CA 91405','(253) 578-3057','Blue Cross',1112233445,'Latoya','Lindsey','Maylen181@mail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('442-31-2491','Nathan','Rittenhouse','15-Nov-61','606 Manor Station Court, Carson, CA 90745','(175) 588-9713','Blue Cross',1112233446,'Jeanine','Mcconnell','Nathan687@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('163-25-0809','Jacqueline','Keller','08-Sep-65','734 Ohio Dr., Bakersfield, CA 93309','(505) 198-1831','AARP',1112233448,'Luther','Floyd','Jacqueline369@icloud.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('295-37-0317','Jensen','Gastelum','20-Aug-74','3 West Henry Smith Street, Porterville, CA 93257','(405) 310-3913','Kaleida Health',1112233447,'Avis','Gould','Jensen891@yahoo.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('661-37-2869','Joshua','Trapp','19-Jul-80','8646 Park St., Fontana, CA 92336','(589) 737-5580','Health Spring',1112233450,'Maryellen','Heath','Joshua806@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('001-73-7651','Clifton','Rawlings','31-Oct-61','22 Brandywine Drive, Alhambra, CA 91801','(205) 491-8213','Health Spring',1112233455,'Maxwell','Weber','Clifton435@yahoo.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('739-01-1213','Gabrielle','Evaristo','24-Feb-81','347 Gulf Drive, Merced, CA 95340','(529) 098-4761','Unitrin',1112233460,'Roosevelt','Henderson','Gabrielle331@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('865-82-9501','Melissa','Pallireto','07-Apr-93','437 Sherwood Rd., Hacienda Heights, CA 91745','(111) 193-9361','State Farm',1112233457,'Leanne','Peterson','Melissa988@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('457-46-9071','Veronica','Avila','02-Oct-71','891 Plumb Branch Street, North Hills, CA 91343','(849) 375-8177','Golden Rule Insurance Company',1112233467,'Janis','Jacobson','Veronica280@yahoo.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('737-27-4996','Fallon','Riggs','06-May-72','321 Parker St., La Puente, CA 91744','(946) 662-2591','Unitrin',1112233461,'Noel','Glenn','Fallon977@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('286-53-2986','Isabella','Briguglio','13-Jun-76','9354 Wall Street, South San Francisco, CA 94080','(376) 658-2456','Kaleida Health',1112233471,'Alexandria','Gentry','Isabella67@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('499-70-0585','Heidy','Ramirez','26-Jul-03','7195 Annadale Lane, Compton, CA 90221','(987) 575-9393','Oxford Health Plans',1112233460,'Rita','Hunter','Heidy945@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('001-61-5386','Paul','Alvarez','04-Feb-87','28 Indian Summer Court, Simi Valley, CA 93065','(436) 141-2279','Molina Healthcare',1112233460,'Erasmo','Vazquez','Paul498@outlook.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('631-13-3026','Jose','Figueroa','02-Jan-98','4 Morris Circle, Colton, CA 92324','(115) 432-4382','Golden Rule Insurance Company',1112233460,'Jacquelyn','Cantu','Jose493@mail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('613-61-9795','Arusyak','Hovhannesyan','11-Feb-66','9194 Buckingham St., Santee, CA 92071','(889) 640-9871','Oxford Health Plans',1112233457,'Donna','Ingram','Arusyak988@mail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('385-31-4659','Robert','Moya','09-Jul-94','8311 Cemetery St., San Jose, CA 95116','(595) 714-3994','Unitrin',1112233457,'Robbie','Murillo','Robert579@mail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('397-01-6371','Edwin','Navar','30-Sep-85','9 Paris Hill St., Corona, CA 92882','(446) 255-8045','State Farm',1112233457,'Kathryn','Duffy','Edwin800@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('610-55-7381','Humberto','Romo','22-Nov-01','384 North Saxon Avenue, Vallejo, CA 94591','(703) 371-9601','Molina Healthcare',1112233474,'Katina','Hoover','Humberto505@mail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('571-40-4826','Felipe','Valadez','29-Oct-79','213 Glen Ridge Avenue, Los Angeles, CA 90044','(199) 011-2816','Kaiser Permanente',1112233474,'Billie','Horne','Felipe247@yahoo.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('101-29-5141','Ansel','Villegas','19-Aug-02','9973 E. Williams Rd., Lake Forest, CA 92630','(692) 432-0074','Blue Cross',1112233474,'Freddy','Flowers','Ansel470@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('673-11-6672','Andrea','Barragan','03-Feb-63','475 Cedar Swamp Street, Westminster, CA 92683','(442) 017-7351','Oxford Health Plans',1112233448,'Otha','Montgomery','Andrea262@mail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('193-83-9301','Blanca','Nunez','28-Apr-86','397 Fifth Avenue, Anaheim, CA 92804','(511) 377-9621','Cigna',1112233448,'Quintin','Love','Blanca989@yahoo.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('001-01-0001','Janae','Hardy','25-Jun-63','15 Young Street, Los Angeles, CA 90037','(729) 572-7866','Oxford Health Plans',1112233448,'Hester','Odom','Janae1@outlook.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('771-73-9955','Ian','Becker','02-Jan-95','80 St Margarets St., San Jose, CA 95112','(397) 277-6897','State Farm',1112233459,'Mac','Padilla','Ian595@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('526-34-3969','Itzel','Diaz','31-Jan-67','7085 Lexington Ave., Oxnard, CA 93030','(239) 016-5509','Humana',1112233463,'Martin','Blanchard','Itzel667@yahoo.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('145-57-5402','Jessica','Henderson','12-Jan-66','7623 Lake St., Tracy, CA 95376','(551) 533-9601','Humana',1112233463,'Janelle','Collins','Jessica79@yahoo.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('683-46-6781','Jeffrey','Salazar','16-May-05','54 Hall Lane, San Francisco, CA 94122','(721) 619-5985','Kaiser Permanente',1112233463,'Victor','Dudley','Jeffrey371@icloud.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('001-37-2949','Juan','Gutierrez','07-May-96','24 Poplar Ave., Los Angeles, CA 90006','(585) 190-9976','Kaiser Permanente',1112233449,'Kendra','Blackwell','Juan990@outlook.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('757-01-9301','Hannah','Fejzic','21-Feb-98','8011 Roberts Circle, Baldwin Park, CA 91706','(595) 121-9501','Molina Healthcare',1112233449,'Antoinette','Villanueva','Hannah111@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('305-97-3017','Kylie','Harris','19-Sep-86','8998 Surrey Avenue, Fremont, CA 94536','(393) 585-0701','Fortis',1112233449,'Rey','Brown','Kylie902@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('781-89-2065','Daniel','Castaneda','19-Oct-74','349 West Oak Valley Dr., Hayward, CA 94544','(573) 080-0001','Oxford Health Plans',1112233455,'Norbert','Bright','Daniel341@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('553-49-7929','Julissa','Alvarado','27-Jul-69','8 Yukon Street, Santa Ana, CA 92704','(349) 103-8369','Cigna',1112233455,'Geraldine','Morgan','Julissa657@outlook.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('697-13-8620','Telma','Mendoza','02-Nov-77','250 Rockledge Drive,  Salinas, CA 93906','(267) 460-0001','Golden Rule Insurance Company',1112233455,'Lyndon','Chapman','Telma143@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('723-31-5149','Victoria','Cerda','10-May-67','74 E. Golf Dr., Ontario, CA 91761','(631) 925-1841','Horace Mann Educators Corporation',1112233455,'Elena','Mcdowell','Victoria117@yahoo.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('865-73-0973','Alondra','Medina','29-Oct-77','8342 West Sage Drive, Huntington Beach, CA 92646','(322) 919-6791','Horace Mann Educators Corporation',1112233473,'Wiley','Sharp','Alondra321@mail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('173-15-8289','Melissa','Herrera','29-Jul-77','83 Cemetery Rd., Sacramento, CA 95823','(625) 498-9103','Oxford Health Plans',1112233473,'Bethany','Lowery','Melissa123@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('321-97-4740','Catie','Rendon','22-Sep-75','1 Bow Ridge Dr., Los Angeles, CA 90026','(981) 665-8521','Oxford Health Plans',1112233473,'Kristopher','Gibbs','Catie451@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('785-11-4229','Joanna','Villegaz','09-Dec-68','7913 N. Front Avenue, Reseda, CA 91335','(205) 114-1713','Kaleida Health',1112233472,'Jodi','Lara','Joanna460@outlook.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('001-49-5089','Pablo','Velazquez','05-Jun-92','187 N. Glenridge Drive, Azusa, CA 91702','(711) 713-2641','Health Spring',1112233472,'Rosella','Mullen','Pablo701@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('505-05-0001','Cesar','Rey','03-Dec-81','726 Randall Mill Ave., San Bernardino, CA 92404','(946) 106-2841','Blue Cross',1112233472,'Darron','Hayden','Cesar239@icloud.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('451-97-6745','Wendy','Barboza','10-May-00','3 Grove Street, Los Angeles, CA 90003','(293) 917-8859','Molina Healthcare',1112233471,'Jean','Glenn','Wendy356@icloud.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('461-35-0001','Lexi','Romero','17-Jul-67','9461 N. Sierra St., Rosemead, CA 91770','(859) 652-4721','United Health Group',1112233471,'Queen','Herrera','Lexi841@yahoo.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('625-11-1231','Saul','Herrera','03-Feb-94','7468 Woodside Avenue, San Diego, CA 92115','(159) 142-8177','Kaiser Permanente',1112233471,'Bernice','Frey','Saul1@mail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('271-18-7793','Jackie','Gonzalez','07-Jan-89','57 Shirley St., Carmichael, CA 95608','(855) 019-6121','Molina Healthcare',1112233460,'Grover','Horton','Jackie631@icloud.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('289-33-4537','Max','Navarrete','18-Jun-85','854 Stillwater Street, Davis, CA 95616','(611) 648-2668','Unitrin',1112233460,'Alden','Fitzpatrick','Max259@aol.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('694-76-3301','Alma','Leon','24-Apr-73','24 Vine St., Los Angeles, CA 90063','(721) 295-4667','United Health Group',1112233460,'Eileen','Pittman','Alma477@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('508-81-6553','Shasha','Lazzarinetti','03-Oct-69','982 Del Monte St., Fremont, CA 94538','(989) 539-7138','Health Spring',1112233456,'Sherwood','Noble','Shasha65@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('685-67-1441','Juan','Padilla','12-May-92','121 Vernon Ave., Union City, CA 94587','(381) 215-5171','AARP',1112233456,'Ali','Ortega','Juan590@mail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('001-91-0997','Cesar','Navarro','09-Apr-85','6 Princeton Rd., Lompoc, CA 93436','(825) 266-0513','Molina Healthcare',1112233456,'Jerrell','Bowen','Cesar929@yahoo.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('361-01-8021','Ivonne','Pelayo','29-Jun-91','87 Greenview Lane, Laguna Niguel, CA 92677','(231) 314-5601','State Farm',1112233452,'Hilton','Blackburn','Ivonne469@outlook.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('373-28-6013','Hector','Del leon','13-May-71','584 Talbot Street, El Cajon, CA 92020','(400) 339-9725','Oxford Health Plans',1112233452,'Elroy','Montgomery','Hector603@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('769-13-7809','Magy','Ramirez','08-Aug-94','37 Pacific St., Hanford, CA 93230','(951) 495-8417','Horace Mann Educators Corporation',1112233452,'Lawanda','Bautista','Magy673@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('357-91-5534','Bris','Aburto','28-Mar-77','41 Arlington Ave., Chula Vista, CA 91910','(581) 710-0001','Kaleida Health',1112233450,'Lanny','Fuller','Bris928@aol.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('667-29-8941','Yazmin','Belmudes','20-Jan-82','901 Liberty Street, San Diego, CA 92154','(599) 276-0361','AARP',1112233450,'Tameka','Frazier','Yazmin619@mail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('393-52-1961','Valeria','Meza','27-Apr-90','605 Fifth Street, Ontario, CA 91762','(346) 058-6905','Golden Rule Insurance Company',1112233450,'Erich','Garza','Valeria309@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('631-61-1897','Lupita','Garcia','25-Jun-88','282 South Young Street, San Jose, CA 95123','(377) 974-9303','Humana',1112233448,'Micheal','Sims','Lupita673@yahoo.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('273-64-7511','Tania','Cardenas','09-Oct-60','8561 Applegate Street, Oxnard, CA 93033','(523) 786-0131','Unitrin',1112233448,'Adolph','Stein','Tania415@yahoo.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('757-85-4821','Marcela','Rico','17-Jun-67','9744 Center Dr., Santa Ana, CA 92707','(921) 318-4007','Blue Cross',1112233448,'Aubrey','Carr','Marcela925@aol.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('705-01-7448','Axl','Mendoza','22-Jul-90','993 N. Tanglewood Drive, Santa Clara, CA 95051','(414) 966-6126','State Farm',1112233445,'Eugenio','Morse','Axl559@aol.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('783-71-6364','Judith','Gonzalez','15-May-60','830 Gartner Rd., Fairfield, CA 94533','(551) 917-8737','Liberty Medical',1112233445,'Boyd','Frye','Judith941@icloud.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('385-92-6769','Jaime','Eduardo','01-Dec-67','8968 Southampton Street, Santa Ana, CA 92701','(261) 813-1671','Kaiser Permanente',1112233445,'Cesar','Hebert','Jaime167@outlook.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('761-76-8317','Zahyra','Sepulveda','09-May-61','9241 West Helen Lane, Chino, CA 91710','(936) 468-6553','United Health Group',1112233466,'Cristopher','Archer','Zahyra937@mail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('703-73-2329','Ayanna','Lewis','20-Jul-70','95 Spruce Road, Indio, CA 92201','(161) 731-7547','Oxford Health Plans',1112233466,'Lessie','Ewing','Ayanna443@yahoo.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('553-81-2877','Ricky','Martin','09-May-79','9082 Courtland Drive, La Habra, CA 90631','(203) 018-1739','Health Spring',1112233466,'Ines','Cruz','Ricky961@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('622-67-7397','Sofia','Garcia','26-Sep-65','211 Lakeview St., Fontana, CA 92335','(379) 163-5595','AARP',1112233467,'Lacey','Stanley','Sofia541@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('025-36-8821','Maximilian','Adams','03-Jun-68','312 Sherman Rd., San Francisco, CA 94112','(571) 927-9585','Horace Mann Educators Corporation',1112233467,'Sheri','Dean','Maximilian376@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('731-29-1769','Brittny','Wilson','14-Apr-99','41 School St., Hayward, CA 94541','(659) 316-5821','Oxford Health Plans',1112233467,'Mercedes','Mccarthy','Brittny919@hotmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('606-25-6577','Nazario','Hernandez','17-Oct-81','7725 Myrtle St., Hawthorne, CA 90250','(169) 191-6441','Kaiser Permanente',1112233469,'Rich','Reese','Nazario665@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('405-73-3469','Raul','Muro','22-Feb-01','35 Randall Mill Street, Anaheim, CA 92805','(497) 251-6269','Aetna',1112233469,'Cathryn','Lang','Raul967@mail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('676-12-9577','Frank','Pimentel','12-Jan-79','52 S. Mammoth St., Chino Hills, CA 91709','(277) 710-0001','Kaleida Health',1112233469,'Amie','Lin','Frank291@gmail.com');
INSERT INTO PATIENT(SSN,PatientFName,PatientLname,DOB,Address,Phone,InsuranceName,PatientPhysician,Next_Of_Kin_First_Name,Next_Of_Kin_Last_Name,PatientEmail) VALUES ('733-23-7063','Luis','Aguilar','08-Mar-96','276 W. Annadale Ave., San Francisco, CA 94110','(260) 691-2607','Golden Rule Insurance Company',1112233469,'Flora','Hartman','Luis458@icloud.com');
    
--Insert Nurse Tuples
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000000,'517-46-6021','Tobias','Cross','Medical-Surgical',107,1,'Tobias421@hotmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000001,'807-05-6546','Johanna','Mcknight','Family',100,0,'Johanna941@gmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000002,'311-51-0836','Devon','Henderson','Medical-Surgical',107,1,'Devon280@outlook.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000003,'766-61-9064','Georgette','Richmond','Aesthetic',110,0,'Georgette121@gmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000004,'148-92-9586','Jonathon','Bishop','Emergency Room',107,1,'Jonathon439@mail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000005,'442-66-8209','Lindsay','Castaneda','Oncology',103,0,'Lindsay185@mail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000006,'093-64-1729','Terra','Richardson','Cardiovascular',105,0,'Terra199@yahoo.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000007,'243-69-8854','Yolanda','Leonard','Emergency Room',107,1,'Yolanda552@mail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000008,'769-56-6319','Kent','Bartlett','Dermatology',106,1,'Kent139@aol.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000009,'848-61-3905','Laurence','Snow','Family',100,1,'Laurence513@yahoo.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000010,'048-85-2133','Juan','Holloway','Family',100,1,'Juan793@outlook.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000011,'001-66-3611','Heriberto','Harvey','Family',100,1,'Heriberto95@hotmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000012,'393-50-0001','Elnora','Palmer','Cardiovascular',105,1,'Elnora253@outlook.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000013,'871-53-0694','Charlene','Pearson','Dermatology',106,1,'Charlene547@yahoo.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000014,'386-34-0752','Reyna','Levine','Aesthetic',110,0,'Reyna316@mail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000015,'457-09-8605','Jessica','Espinoza','Medical-Surgical',107,1,'Jessica638@aol.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000016,'625-81-3233','Micheal','Benton','Dermatology',106,0,'Micheal757@gmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000017,'001-79-7253','Lily','Bean','Oncology',103,0,'Lily441@outlook.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000018,'257-73-3737','Newton','Baird','Laboratory and delivery',108,0,'Newton1@yahoo.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000019,'401-28-7985','Leticia','Farley','Medical-Surgical',107,1,'Leticia856@hotmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000020,'610-41-1435','Petra','Suarez','Aesthetic',110,1,'Petra226@yahoo.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000021,'369-16-8668','Leland','Sherman','Cardiovascular',105,0,'Leland813@gmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000022,'046-73-0001','Jamar','Young','Cardiovascular',105,1,'Jamar841@gmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000023,'001-82-9267','Phil','Miller','Aesthetic',110,1,'Phil685@aol.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000024,'694-57-0465','Elise','Hunter','Laboratory and delivery',108,0,'Elise970@yahoo.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000025,'001-71-4379','Geraldine','Reed','Laboratory and delivery',108,1,'Geraldine961@gmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000026,'214-77-6691','Jospeh','Walker','Oncology',103,1,'Jospeh951@icloud.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000027,'817-31-5105','Miriam','Hardin','Cardiovascular',105,0,'Miriam775@mail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000028,'001-61-3607','Rodrigo','Meadows','Aesthetic',110,0,'Rodrigo729@icloud.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000029,'183-41-1756','Sheri','Christensen','Emergency Room',107,0,'Sheri199@icloud.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000030,'344-55-7729','Augustine','Holden','Dermatology',106,0,'Augustine81@yahoo.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000031,'001-31-2851','Allison','Fuentes','Emergency Room',107,0,'Allison750@icloud.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000032,'585-37-9972','Andreas','Hood','Dermatology',106,0,'Andreas1@icloud.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000033,'201-91-3097','Jarvis','Roman','Aesthetic',110,1,'Jarvis406@hotmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000034,'637-64-4418','Gerardo','Bowen','Pediatrics',101,1,'Gerardo913@mail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000035,'098-78-1651','Olin','Copeland','Dermatology',106,1,'Olin547@hotmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000036,'673-15-9989','Cletus','Ford','Laboratory and delivery',108,0,'Cletus349@outlook.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000037,'817-64-3936','Buck','Cox','Emergency Room',107,0,'Buck273@outlook.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000038,'506-27-9531','Casey','Burgess','Pediatrics',101,0,'Casey645@gmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000039,'609-01-8704','Dianna','Cook','Family',100,0,'Dianna833@mail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000040,'187-41-1219','Lenore','Weaver','Dermatology',106,0,'Lenore331@mail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000041,'361-09-4697','Brandi','Cannon','Medical-Surgical',107,0,'Brandi1@gmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000042,'207-09-4176','Garry','Higgins','Family',100,1,'Garry367@yahoo.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000043,'001-56-0001','Mohamed','Morales','Medical-Surgical',107,1,'Mohamed973@gmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000044,'357-41-5401','Joy','Garza','Cardiovascular',105,1,'Joy302@mail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000045,'193-57-6835','Susan','Simmons','Dermatology',106,1,'Susan487@mail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000046,'351-65-4087','Spencer','Tanner','Aesthetic',110,0,'Spencer23@outlook.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000047,'281-51-8240','Duane','Hall','Family',100,1,'Duane409@icloud.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000048,'001-91-8326','Isreal','Lara','Medical-Surgical',107,1,'Isreal241@outlook.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000049,'280-91-8842','Kurt','Villa','Emergency Room',107,1,'Kurt93@icloud.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000050,'681-91-2849','Edmund','Lozano','Medical-Surgical',107,0,'Edmund963@mail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000051,'817-81-0703','Ruth','Elliott','Oncology',103,1,'Ruth971@yahoo.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000052,'069-45-0564','Bernardo','Gentry','Family',100,0,'Bernardo403@mail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000053,'496-61-5095','Stacy','Lewis','Emergency Room',107,1,'Stacy193@icloud.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000054,'311-28-1881','Jefferey','Mcclain','Laboratory and delivery',108,0,'Jefferey705@aol.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000055,'080-21-8905','Louis','Green','Dermatology',106,0,'Louis211@aol.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000056,'295-16-7801','Ezra','Gregory','Emergency Room',107,1,'Ezra346@yahoo.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000057,'833-07-8201','Glenda','Frost','Medical-Surgical',107,1,'Glenda721@yahoo.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000058,'001-49-3941','Raymundo','Mosley','Dermatology',106,0,'Raymundo371@yahoo.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000059,'076-81-3367','Earlene','Castillo','Dermatology',106,1,'Earlene944@hotmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000060,'676-57-5577','Cornelia','Hendrix','Oncology',103,1,'Cornelia165@hotmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000061,'093-71-0399','Tony','Travis','Medical-Surgical',107,0,'Tony833@yahoo.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000062,'716-97-7471','Archie','Bernard','Dermatology',106,1,'Archie241@gmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000063,'075-73-5665','Celia','Owen','Emergency Room',107,0,'Celia277@gmail.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000064,'109-22-2791','Bianca','Shaffer','Pediatrics',101,0,'Bianca52@yahoo.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000065,'426-13-0001','Tommie','Mcdonald','Family',100,0,'Tommie287@outlook.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000066,'732-85-6076','Lorna','Stein','Laboratory and delivery',108,0,'Lorna625@icloud.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000067,'229-01-5214','Adan','Booker','Dermatology',106,1,'Adan307@icloud.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000068,'561-16-2731','Pete','Romero','Pediatrics',101,0,'Pete793@aol.com');
INSERT INTO NURSE(NurseID,SSN,NurseFname,NurseLname,NursePosition,NurseDepartment,Registered,NurseEmail) VALUES (2000000069,'305-09-0001','Mel','Ball','Oncology',103,0,'Mel752@yahoo.com');

--Insert Prescription Tuples
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110000,1112233445,'715-01-3961',1000000049,'4-Jan-09',123456777,'250 mg take two pills a day');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110001,1112233446,'386-97-2781',1000000000,'4-Feb-09',123456778,'300 mg take one pill a day');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110002,1112233447,'451-19-1951',1000000001,'5-Mar-10',123456779,'100 mg take one pill a day');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110003,1112233448,'389-89-1463',1000000002,'4-Jan-11',123456780,'1000 mg take one pill in the morning');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110004,1112233449,'694-64-2401',1000000003,'9-Jan-09',123456781,'250 mg take two pills a day');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110005,1112233450,'603-43-2266',1000000004,'12-Feb-09',123456782,'500 mg take 3 pills a day');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110006,1112233451,'541-11-5179',1000000005,'4-Apr-09',123456783,'88 mg take one pill a day');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110007,1112233452,'449-66-8269',1000000006,'4-Jun-09',123456784,'10 mg take two orally a day after every meal');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110008,1112233453,'569-57-9157',1000000007,'4-Jul-09',123456785,'2 mg take before bed');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110009,1112233454,'456-25-5209',1000000008,'4-Aug-09',123456786,'2 mg take before bed');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110010,1112233455,'409-18-1177',1000000009,'4-Sep-09',123456787,'500 mg take 3 pills a day');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110011,1112233456,'554-01-4351',1000000010,'4-Oct-09',123456788,'25 mg take after every meal');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110012,1112233457,'286-56-0001',1000000011,'4-Nov-09',123456789,'50 mg take before/after every meal');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110013,1112233458,'001-55-8781',1000000012,'4-Dec-09',123456790,'2 mg take after every meal');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110014,1112233459,'595-28-1975',1000000013,'4-Dec-08',123456791,'15 mg take two pills once every other day');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110015,1112233460,'391-81-6556',1000000014,'5-Dec-09',123456792,'20 mg take once everyday other day');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110016,1112233461,'311-67-1361',1000000015,'6-Dec-09',123456793,'550 mg take once in the morning orally');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110017,1112233462,'378-01-7171',1000000016,'7-Dec-09',123456794,'1000 mg apply to wound lightly (keep from sun)');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110018,1112233463,'676-86-6257',1000000017,'8-Dec-09',123456795,'2 mg take before bed');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110019,1112233464,'243-14-3840',1000000018,'9-Dec-09',123456796,'45 mg apply cream to wound');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110020,1112233465,'691-13-0001',1000000019,'10-Dec-09',123456797,'600 mg take before bed');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110021,1112233466,'841-61-6826',1000000020,'11-Dec-09',123456798,'99 mg take once after every meal');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110022,1112233467,'041-85-2941',1000000021,'12-Dec-09',123456799,'100 mg take one pill a day');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110023,1112233468,'463-92-1870',1000000022,'13-Dec-09',123456800,'500 mg take 3 pills a day');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110024,1112233469,'673-91-9121',1000000023,'14-Dec-09',123456801,'300 mg take one pill a day');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110025,1112233470,'838-81-4390',1000000024,'16-Dec-09',123456802,'88 mg take one pill a day');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110026,1112233471,'533-37-4939',1000000025,'15-Dec-09',123456803,'45 mg apply cream to wound');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110027,1112233472,'183-09-5161',1000000026,'17-Dec-09',123456804,'99 mg take once after every meal');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110028,1112233473,'874-33-9729',1000000027,'18-Dec-09',123456805,'20 mg take once everyday other day');
INSERT INTO Prescription(PrescriptionID,PhysicianID,PatientID,Medication,PrescDate,AppointmentID,Dose) VALUES (1111110029,1112233474,'501-09-2821',1000000028,'19-Dec-09',123456806,'20 mg take once everyday other day');

--Insert Physician Tuples
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233445,'123-35-2232','Tomasz','Wallace',1,'twallce@gmail.com', 100);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233446,'647-95-7708','Mae','Church',0,'mcurch@gmail.com', 100);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233447,'264-19-5309','Lillian','Greaves',0,'lgreaves@gmail.com', 100);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233448,'314-21-3643', 'Tom','Welsh','1','twelsh@gmail.com', 101);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233449, '825-64-0084', 'Bill', 'Padilla',0,'bpad@gmail.com', 101);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233450,'165-25-2545','Daniel','Ortega',0,'dort@gmail.com', 101);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233451,'510-55-9024','Jim','Ashton',1,'jash@gmail.com', 102);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233452,'227-68-4256','Greg','Redman',0,'gred@gmail.com', 102);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233453,'528-97-1309','Lina','Read',0,'lread@gmail.com', 102);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233454,'278-48-0029','Chris','Will',1,'cwill@gmail.com', 103);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233455,'800-48-8266','Rafa','Lopez',0,'rlopez@gmail.com', 103);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233456,'606-45-7674','John','Ramirez',0,'jrami@gmail.com', 103);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233457,'914-56-5873','Sam','Watkins',1,'swat@gmail.com', 103);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233458,'470-24-1161','Gbay','Garibay',0,'gbay@gmail.com', 104);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233459,'129-61-4077','Joseph','Carpio',0,'jcarp@gmail.com', 104);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233460,'957-49-7035','DD','Morales',1,'ddmor@gmail.com', 105);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233461,'552-28-774','Michael','Garica',0,'micg@gmail.com', 105);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233462,'799-89-9618','Rudy','Morales',0,'rudy@gmail.com', 105);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233463,'425-78-6529','Derek','Fisher','1','dfish@gmail.com', 106);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233464,'666-79-3784','Jimmy','Garop',0,'jimy@gmail.com', 106);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233465,'563-22-0817','Ronaldo','Kaye',0,'ronaldo@gmail.com', 106);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233466,'885-76-8699','Pooja','Bevan',1,'pooja@gmail.com', 107);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233467,'776-79-2859','Shea','Sinclair',0,'shea@gmail.com', 107);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233468,'559-04-9042','Lilly','Torrez',0,'lilly@gmail.com', 107);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233469,'907-25-1194','Zena','Wicks',1,'zena@gmail.com', 108);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233470,'611-54-3124','Jose','Clements',0,'joseclem@gmail.com', 108);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233471,'967-04-6123','Dilan','Gay',0,'dillang@gmail.com', 108);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233472,'922-44-5785','Josie','Power',1,'josipowe@gmail.com', 109);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233473,'125-45-6510','Jason','Webster',0,'jasweb@gmail.com', 109);
INSERT INTO Physician(PhysicianID,SSN,PhysicianFname,PhysicianLname,Partnered,Email,DepartmentID) VALUES (1112233474,'706-99-1114','Susan','Corpuz',0,'suscor@gmail.com', 109);

--Insert Referrals Tuples
INSERT INTO Referrals(ReferralID,PhysicianID,PatientID,Reason,ReferralTo) VALUES (000001,1112233445,'715-01-3961','Needs to see specialist','Dino Optomology');
INSERT INTO Referrals(ReferralID,PhysicianID,PatientID,Reason,ReferralTo) VALUES (000002,1112233446,'386-97-2781','2nd opinion','San Bernardino Hearts');
INSERT INTO Referrals(ReferralID,PhysicianID,PatientID,Reason,ReferralTo) VALUES (000003,1112233447,'451-19-1951','Needs to see specialist','San Bernardino Hearts');
INSERT INTO Referrals(ReferralID,PhysicianID,PatientID,Reason,ReferralTo) VALUES (000004,1112233448,'389-89-1463','2nd opinion','SBMD');
INSERT INTO Referrals(ReferralID,PhysicianID,PatientID,Reason,ReferralTo) VALUES (000005,1112233449,'694-64-2401','2nd opinion','SBMD');

--Appointment Table Functional Dependencies
ALTER TABLE APPOINTMENTS
    ADD CONSTRAINT ApRoom_FK FOREIGN KEY(ApRoom) REFERENCES Room(RoomNumber);
ALTER TABLE APPOINTMENTS
    ADD CONSTRAINT ApPatient_FK FOREIGN KEY(ApPatient) REFERENCES PATIENT(SSN);
ALTER TABLE APPOINTMENTS
    ADD CONSTRAINT PrepNurse_FK FOREIGN KEY(PrepNurse) REFERENCES NURSE(NurseID);
ALTER TABLE APPOINTMENTS
    ADD CONSTRAINT ApPhysician_FK FOREIGN KEY(ApPhysician) REFERENCES PHYSICIAN(PhysicianID); 

--Referrals Table Functional Dependencies
ALTER TABLE REFERRALS
   ADD CONSTRAINT Referral_Patient_Fk FOREIGN KEY(PatientID) REFERENCES Patient(SSN);
ALTER TABLE REFERRALS
   ADD CONSTRAINT Referral_Physician_Fk FOREIGN KEY(PhysicianID) REFERENCES Physician(PhysicianID);

--Prescription Table Functional Dependencies    
ALTER TABLE PRESCRIPTION
   ADD CONSTRAINT PatientID_FK FOREIGN KEY(PatientID) REFERENCES Patient(SSN);    
ALTER TABLE PRESCRIPTION
   ADD CONSTRAINT PhysicianID_FK FOREIGN KEY(PhysicianID) REFERENCES Physician(PhysicianID);    
ALTER TABLE PRESCRIPTION
   ADD CONSTRAINT Medication_FK FOREIGN KEY(Medication) REFERENCES Medication(MedicationID);
ALTER TABLE PRESCRIPTION
   ADD CONSTRAINT Appointment_Presc_FK FOREIGN KEY(AppointmentID) REFERENCES Appointments(AppointmentID);

--Physician Table Functional Dependencies   
ALTER TABLE PHYSICIAN
    ADD CONSTRAINT Dept_FK FOREIGN KEY(DepartmentID) REFERENCES DEPARTMENT(DeptID);   
 
--Nurse Table Functional Dependencies                   
ALTER TABLE NURSE
    ADD CONSTRAINT nurse_nurse_department_fk FOREIGN KEY (NurseDepartment) REFERENCES DEPARTMENT(DeptID);

--Patient Table Functional Dependencies
ALTER TABLE PATIENT
    ADD CONSTRAINT patient_physician_fk FOREIGN KEY (PatientPhysician) REFERENCES PHYSICIAN(PhysicianID);

--Department Table Functional Dependencies                          
ALTER TABLE DEPARTMENT
    ADD CONSTRAINT Dept_Head_FK FOREIGN KEY (DeptHead) REFERENCES PHYSICIAN (PhysicianID);
  
---------------------------------------------------------------------------
--                       Patient View                                    --
--------------------------------------------------------------------------- 
-- Shows revelant information about the patient such as primary physician, appointment, contact info.
CREATE VIEW PATIENT_VU AS
    SELECT
        P.SSN AS SSN,
        P.PATIENTFNAME || ' ' || P.PATIENTLNAME AS NAME,
        P.DOB AS DATE_OF_BIRTH,
        P.PHONE AS PHONE_NUMBER,
        PHD.PHYSICIANFNAME || ' ' || PHD.PHYSICIANLNAME AS PRIMARY_PHYSICIAN,
        D.DEPTNAME AS NAME_OF_DEPARTMENT,
        AP.APSTART AS DATE_OF_APPOINTMENT,
        AP.APEND AS END_OF_APPOINTMENT,
        N.NURSEFNAME || ' ' ||N.NURSELNAME AS PREPNURSE_NAME
    FROM
        PATIENT P,
        PHYSICIAN PHD,
        DEPARTMENT D,
        APPOINTMENTS AP,
        NURSE N
        WHERE PHD.DEPARTMENTID = D.DEPTID
            AND P.PATIENTPHYSICIAN = PHD.PHYSICIANID
            AND P.SSN = AP.APPATIENT
            AND AP.PREPNURSE = N.NURSEID;
        
SELECT * FROM PATIENT_VU;

---------------------------------------------------------------------------
--                 Patient Medication View                               --
--------------------------------------------------------------------------- 
-- Shows the medication each patient is taken, when it was assigned,and by who
CREATE VIEW PATIENT_MEDICATION_VU AS
    SELECT
        P.SSN AS SSN,
        P.PATIENTFNAME || ' ' || P.PATIENTLNAME AS NAME,
        PHD.PHYSICIANFNAME || ' ' || PHD.PHYSICIANLNAME AS PHYSICIAN_PRESCRIBED_MEDICATION,
        AP.APSTART AS APPOINTMENT_MEDICATION_PRESCRIBED,
        M.MEDNAME AS NAME_OF_MEDICATION,
        PR.PRESCDATE AS DATE_PRESCRIBED,
        PR.DOSE AS DOSE
    FROM
        PATIENT P,
        PHYSICIAN PHD, 
        DEPARTMENT D,
        MEDICATION M,
        PRESCRIPTION PR,
        APPOINTMENTS AP
        WHERE PHD.DEPARTMENTID = D.DEPTID
            AND P.PATIENTPHYSICIAN = PHD.PHYSICIANID
            AND P.SSN = AP.APPATIENT
            AND P.SSN = PR.PATIENTID
            AND PR.MEDICATION = M.MEDICATIONID;

SELECT * FROM PATIENT_MEDICATION_VU;


-- This Join will show the referral reason of patients.
-- It will show the patient, physician who made the referral,
-- and the reason for the referral.
SELECT
    P.PATIENTFNAME || ' '|| PATIENTLNAME AS PATIENT_NAME,
    PHD.PHYSICIANFNAME || ' ' || PHD.PHYSICIANLNAME AS PHYSICIAN_NAME,
    R.REASON AS REFERRAL_REASON,
    R.REFERRALTO AS REFERRAL_PLACE
FROM
        PATIENT P 
JOIN    PHYSICIAN PHD 
        ON P.PATIENTPHYSICIAN = PHD.PHYSICIANID
JOIN    REFERRALS R
        ON R.PATIENTID = P.SSN;
        
-- This join will show the nurse which patient need to treat,
-- at what time is the appointment, which room they need to take
-- the patient to.
SELECT
    N.NURSEFNAME || ' ' || N.NURSELNAME AS PREPNURSE_NAME,
    AP.APSTART AS APPOINTMENT_STARTS,
    R.ROOMNUMBER AS ROOM_NUMBER,
    R.ROOMTYPE AS ROOM_TYPE
FROM
        APPOINTMENTS AP
JOIN    NURSE N
        ON AP.PREPNURSE = N.NURSEID
JOIN    ROOM R
        ON AP.APROOM = R.ROOMNUMBER
ORDER BY AP.APSTART ASC;


--An SQL query to find which  rooms are being utilized
--the most during appointments
SELECT COUNT(PrepNurse), AProom 
FROM Appointments
GROUP BY AProom
HAVING COUNT(PrepNurse) > 2;

--An SQL query to find which departments have a disproportianate
--number of registered nurses
SELECT COUNT(Registered), NurseDepartment 
FROM Nurse
GROUP BY NurseDepartment
HAVING COUNT(Registered) > 10;

-- Query 1 from patient table
-- Shows all patients that have Kaiser as their insurance
SELECT
    PATIENTFNAME || ' ' || PATIENTLNAME AS PATIENT,
    INSURANCENAME
FROM
    PATIENT
    WHERE INSURANCENAME = 'Kaiser Permanente';

-- Query 2 from nurse table
-- Selectes all nurses that are registered.
SELECT 
    NURSEFNAME || ' ' || NURSELNAME AS NURSE
FROM 
    NURSE
    WHERE REGISTERED = '1';
    
-- Query 3 from department table
-- Shows which physician is in charge for each department.
SELECT 
    DEPTNAME AS DEPARTMENT,
    PHYSICIANFNAME || ' ' || PHYSICIANLNAME AS PHYSICIAN_HEAD
FROM
    DEPARTMENT D,
    PHYSICIAN PHD
    WHERE D.DEPTHEAD = PHD.PHYSICIANID;
    
-- Query 4 from medication table
-- Shows which medications has a dosage of 1000 mg.
SELECT 
    MEDNAME AS MEDICATION_NAME,
    INSTRUCTIONS
FROM
    MEDICATION
    WHERE INSTRUCTIONS LIKE '%1000%';
    
-- Query 5 from physician table
-- Shows which physicians are partnered.
SELECT 
    PHYSICIANFNAME || ' ' || PHYSICIANLNAME AS PHYSICIAN_NAME
FROM
    PHYSICIAN
    WHERE PARTNERED = '1';
    
-- Query 6 from appointments table
-- Shows all apointments that are on room 106.
SELECT
    P.PATIENTFNAME || ' ' || P.PATIENTLNAME AS PATIENT_NAME,
    AP.APROOM AS ROOM_NUMBER,
    AP.APSTART AS APPOINTMENT_STARTS
FROM
        PATIENT P
JOIN    APPOINTMENTS AP
        ON P.SSN = AP.APPATIENT
        WHERE AP.APROOM = '106';
    