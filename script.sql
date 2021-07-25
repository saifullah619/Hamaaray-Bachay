/*
|-------------------------------------------|
|       DATABASE SYSTEMS - SEMESTER PROJECT |

|   Saif Ullah Dar          -   18I-0599    |
|-------------------------------------------|
*/

set pagesize 1500
set linesize 1200
set timing on
SET SERVEROUTPUT ON
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';





/*----------------------- [[ DDL SECTION ]]-------------------------------*/





/*----------------------- [[ PERSON DDL ]] --------------------------*/

CREATE TABLE PERSON
(
    CNIC VARCHAR2(13),
    F_NAME VARCHAR2(32),
    L_NAME VARCHAR2(32),
    CONTACT_NO VARCHAR2(15),
    GENDER CHAR(1) NOT NULL,
    EMAIL VARCHAR2(255),
    P_TYPE  NUMERIC(1),
    CHECK (P_TYPE BETWEEN 0 AND 2 OR P_TYPE = NULL),
    PRIMARY KEY(CNIC)
);


/*----------------------- [[ STAFF DDL ]] --------------------------*/

CREATE TABLE STAFF
(
    STAFF_ID INTEGER,
    CNIC VARCHAR2(13) NOT NULL,
    CITY VARCHAR2(32),
    AREA VARCHAR2(32),
    STREET VARCHAR2(16),
    JOB_TYPE VARCHAR(10) DEFAULT 'TEACHER',
    UNIQUE(CNIC),
    PRIMARY KEY(STAFF_ID),
    FOREIGN KEY (CNIC) REFERENCES PERSON(CNIC)
);


/*----------------------- [[ PARENT DDL ]] --------------------------*/

CREATE TABLE PARENT
(
    PARENT_ID INTEGER,
    CNIC VARCHAR2(13) NOT NULL,
    UNIQUE(CNIC),
    PRIMARY KEY(PARENT_ID),
    FOREIGN KEY (CNIC) REFERENCES PERSON(CNIC)
);


/*----------------------- [[ PARENT_HISTORY DDL ]] --------------------------*/

CREATE TABLE PARENT_HISTORY
(
    PARENT_ID INTEGER,
    HISTORY_ID INTEGER,
    CNIC VARCHAR2(13) NOT NULL,
    F_NAME VARCHAR2(32),
    L_NAME VARCHAR2(32),
    CONTACT_NO VARCHAR2(15),
    GENDER CHAR(1) NOT NULL,
    EMAIL VARCHAR2(255),
    PRIMARY KEY(PARENT_ID, HISTORY_ID),
    FOREIGN KEY(PARENT_ID) REFERENCES PARENT(PARENT_ID)
);


/*----------------- [[ PERSON INSERT & UPDATE TRIGGERS*/

CREATE OR REPLACE TRIGGER PERSON_INSERT
    AFTER INSERT ON PERSON
    FOR EACH ROW
DECLARE
    CUR_P_ID INTEGER;
BEGIN
    IF :NEW.P_TYPE IN (0,2) THEN
        INSERT INTO STAFF(STAFF_ID, CNIC)
        VALUES(1, :NEW.CNIC);
    END IF;

    IF :NEW.P_TYPE IN (1,2) THEN
        INSERT INTO PARENT(PARENT_ID, CNIC)
        VALUES(1, :NEW.CNIC);

        SELECT NVL(P.PARENT_ID,-1) INTO CUR_P_ID
        FROM PARENT P
        WHERE P.CNIC = :NEW.CNIC;

        INSERT INTO PARENT_HISTORY
        VALUES(CUR_P_ID, 0, :NEW.CNIC, :NEW.F_NAME, :NEW.L_NAME, :NEW.CONTACT_NO, :NEW.GENDER, :NEW.EMAIL);
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error! Insert failed in Trigger: PERSON_INSERT');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error! Unhandled exception in Trigger: PERSON_INSERT.');
END;
/

CREATE OR REPLACE TRIGGER PERSON_UPDATE
    AFTER UPDATE ON PERSON
    FOR EACH ROW
DECLARE
    CUR_P_ID INTEGER;
BEGIN
    IF :OLD.P_TYPE > 0 THEN
        SELECT NVL(P.PARENT_ID,-1) INTO CUR_P_ID
        FROM PARENT P
        WHERE P.CNIC = :OLD.CNIC;

        INSERT INTO PARENT_HISTORY
        VALUES(CUR_P_ID, 0, :NEW.CNIC, :NEW.F_NAME, :NEW.L_NAME, :NEW.CONTACT_NO, :NEW.GENDER, :NEW.EMAIL);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error! No data found in Trigger: PERSON_UPDATE');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error! Unhandled exception in Trigger: PERSON_UPDATE');
END;
/



/*----------------- [[ STAFF INSERT TRIGGER*/

CREATE SEQUENCE STAFF_ID_SEQ START WITH 2000;

CREATE OR REPLACE TRIGGER STAFF_ON_INSERT
    BEFORE INSERT ON STAFF
    FOR EACH ROW
BEGIN
    :NEW.STAFF_ID := STAFF_ID_SEQ.nextval;
END;
/



/*------------------ [[ PARENT INSERT TRIGGER*/

CREATE SEQUENCE PARENT_ID_SEQ START WITH 1000;

CREATE OR REPLACE TRIGGER PARENT_ON_INSERT
    BEFORE INSERT ON PARENT
    FOR EACH ROW
BEGIN
    :NEW.PARENT_ID := PARENT_ID_SEQ.nextval;
END;
/



/*-------------------[[ TRIGGER_HISTORY INSERT TRIGGER*/

CREATE OR REPLACE TRIGGER P_HIST_ON_INSERT
    BEFORE INSERT ON PARENT_HISTORY
    FOR EACH ROW
DECLARE
    MAX_HISTORY_ID INTEGER;
BEGIN
    SELECT NVL(MAX(HISTORY_ID),0) INTO MAX_HISTORY_ID
    FROM PARENT_HISTORY
    GROUP BY CNIC
    HAVING CNIC = :NEW.CNIC;

    :NEW.HISTORY_ID := MAX_HISTORY_ID + 1;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        :NEW.HISTORY_ID := 1;
END;
/


/*----------------------- [[ GUARDIAN DDL ]] --------------------------*/

CREATE TABLE GUARDIAN
(
    GUARDIAN_ID INTEGER,
    CNIC VARCHAR2(13) NOT NULL,
    F_NAME VARCHAR2(32),
    L_NAME VARCHAR2(32),
    CONTACT_NO VARCHAR2(15),
    GENDER CHAR(1) NOT NULL,
    PRIMARY KEY(GUARDIAN_ID),
    CHECK (CNIC NOT LIKE '%[^0-9]%'),
    CHECK (CONTACT_NO NOT LIKE '%[^0-9]%'),
    CHECK (GENDER IN ('M', 'F')),
    UNIQUE(CNIC)
);

/*----------------------- [[ GUARDIAN_HISTORY DDL ]] --------------------------*/

CREATE TABLE GUARDIAN_HISTORY
(
    GUARDIAN_ID INTEGER,
    HISTORY_ID INTEGER,
    CNIC VARCHAR2(13),
    F_NAME VARCHAR2(32),
    L_NAME VARCHAR2(32),
    CONTACT_NO VARCHAR2(15),
    GENDER CHAR(1),
    PRIMARY KEY(GUARDIAN_ID, HISTORY_ID),
    FOREIGN KEY(GUARDIAN_ID) REFERENCES GUARDIAN(GUARDIAN_ID)
);


/*-------------- [[ GUARDIAN INSERT & UPDATE TRIGGER*/

CREATE SEQUENCE GUARDIAN_ID_SEQ START WITH 5000;

CREATE OR REPLACE TRIGGER GUARDIAN_ON_INSERT
    BEFORE INSERT ON GUARDIAN
    FOR EACH ROW
BEGIN
    :NEW.GUARDIAN_ID := GUARDIAN_ID_SEQ.NEXTVAL;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error! Unhandled exception in Trigger: GUARDIAN_ON_INSERT');
END;
/

CREATE OR REPLACE TRIGGER GUARDIAN_AFTER_INSERT
    AFTER INSERT ON GUARDIAN
    FOR EACH ROW
DECLARE
    CUR_G_ID INTEGER;
BEGIN
    INSERT INTO GUARDIAN_HISTORY
    VALUES(:NEW.GUARDIAN_ID, 0, :NEW.CNIC, :NEW.F_NAME, :NEW.L_NAME, :NEW.CONTACT_NO, :NEW.GENDER);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error! Unhandled exception in Trigger: GUARDIAN_AFTER_INSERT');
END;
/

CREATE OR REPLACE TRIGGER GUARDIAN_UPDATE
    AFTER UPDATE ON GUARDIAN
    FOR EACH ROW
DECLARE
    CUR_G_ID INTEGER;
BEGIN
    INSERT INTO GUARDIAN_HISTORY
    VALUES(:NEW.GUARDIAN_ID, 0, :NEW.CNIC, :NEW.F_NAME, :NEW.L_NAME, :NEW.CONTACT_NO, :NEW.GENDER);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error! Unhandled exception in Trigger: GUARDIAN_UPDATE');
END;
/



/*------------- GUARDIAN_HISTORY INSERT TRIGGER*/

CREATE OR REPLACE TRIGGER G_HIST_ON_INSERT
    BEFORE INSERT ON GUARDIAN_HISTORY
    FOR EACH ROW
DECLARE
    MAX_HISTORY_ID INTEGER;
BEGIN
    SELECT NVL(MAX(HISTORY_ID),0) INTO MAX_HISTORY_ID
    FROM GUARDIAN_HISTORY
    GROUP BY GUARDIAN_ID
    HAVING GUARDIAN_ID = :NEW.GUARDIAN_ID;

    :NEW.HISTORY_ID := MAX_HISTORY_ID + 1;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        :NEW.HISTORY_ID := 1;
END;
/


/*-----------------------[[ CLASS DDL ]] ----------------------------*/

CREATE TABLE CLASS
(
    CLASS_ID INTEGER,
    CO_ED NUMERIC(1),
    REQ_GUARD NUMERIC(1),
    MIN_AGE NUMERIC(2),
    MAX_AGE NUMERIC(2),
    CHECK (CO_ED IN (0,1)),
    CHECK (REQ_GUARD IN (0,1)),
    PRIMARY KEY(CLASS_ID)
);

/*-----------------------[[ SECTION DDL ]] -------------------------*/

CREATE TABLE SECTION
(
    CLASS_ID INTEGER,
    SECTION_ID CHAR(1),
    TITLE VARCHAR2(8) UNIQUE,
    GENDER_RESTRAINT CHAR(1),
    PRIMARY KEY(CLASS_ID, SECTION_ID),
    FOREIGN KEY (CLASS_ID) REFERENCES CLASS(CLASS_ID),
    CHECK (SECTION_ID NOT LIKE '%[^A-Z]%'),
    CHECK (GENDER_RESTRAINT IN (NULL, 'M', 'F'))
);

CREATE OR REPLACE TRIGGER SECTION_ON_INSERT
    BEFORE INSERT ON SECTION
    FOR EACH ROW
DECLARE
    IS_CO_ED NUMERIC(1);
BEGIN
    SELECT CO_ED INTO IS_CO_ED
    FROM CLASS
    WHERE CLASS_ID = :NEW.CLASS_ID;

    IF IS_CO_ED = 1 THEN
        :NEW.GENDER_RESTRAINT := NULL;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error! This class does not exist.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error! Unhandled exception in Trigger: SECTION_ON_INSERT');
END;
/


/*----------------------- [[ FAMILY DDL ]] --------------------------*/

CREATE TABLE FAMILY
(
    FAMILY_ID INTEGER,
    FATHER_ID INTEGER,
    MOTHER_ID INTEGER,
    NUM_CHILDREN NUMBER(3) DEFAULT 0,
    SP_DISCOUNT NUMBER(3),
    JOIN_DATE DATE,
    EARLY_INTRODUCER NUMERIC(1) DEFAULT 0,
    CHECK (SP_DISCOUNT BETWEEN 0 AND 100),
    PRIMARY KEY(FAMILY_ID),
    UNIQUE(FATHER_ID, MOTHER_ID),
    FOREIGN KEY (FATHER_ID) REFERENCES PARENT(PARENT_ID),
    FOREIGN KEY (MOTHER_ID) REFERENCES PARENT(PARENT_ID)
);

CREATE SEQUENCE FAMILY_ID_SEQ START WITH 3260 INCREMENT BY 13;

CREATE OR REPLACE TRIGGER FAMILY_ON_INSERT
    BEFORE INSERT ON FAMILY
    FOR EACH ROW
DECLARE
    M_TYPE NUMERIC(1);
    F_TYPE NUMERIC(1);
BEGIN
    :NEW.FAMILY_ID := FAMILY_ID_SEQ.NEXTVAL;

    SELECT PE.P_TYPE INTO M_TYPE
    FROM PARENT P
    INNER JOIN PERSON PE ON P.CNIC = PE.CNIC
    WHERE P.PARENT_ID = :NEW.MOTHER_ID;

    SELECT PE.P_TYPE INTO F_TYPE
    FROM PARENT P
    INNER JOIN PERSON PE ON P.CNIC = PE.CNIC
    WHERE P.PARENT_ID = :NEW.FATHER_ID;

    IF M_TYPE = 2 OR F_TYPE = 2 THEN
        :NEW.SP_DISCOUNT := 100;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error! Unhandled exception in Trigger: FAMILY_ON_INSERT');
END;
/

CREATE OR REPLACE TRIGGER FAMILY_BEFORE_UPDATE
    BEFORE UPDATE ON FAMILY
    FOR EACH ROW
BEGIN
    IF :NEW.NUM_CHILDREN > 3 THEN
        :NEW.SP_DISCOUNT := 30;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error! Unhandled exception in Trigger: FAMILY_BEFORE_UPDATE');
END;
/

/*----------------------- [[ STUDENT DDL ]] --------------------------*/

CREATE TABLE STUDENT
(
    STUDENT_ID INTEGER,
    CNIC VARCHAR2(13),
    F_NAME VARCHAR2(32),
    L_NAME VARCHAR2(32),
    DOB DATE,
    GENDER CHAR(1) NOT NULL,
    PICTURE BFILE,
    CLASS_ID INTEGER,
    SECTION_ID CHAR(1),
    FAMILY_ID INTEGER,
    GUARDIAN_ID INTEGER,
    RELATION VARCHAR2(32),
    CHALLAN_ID VARCHAR2(15),
    ADMIT_DATE DATE,
    LAST_UPDATE_DATE DATE,
    PRIMARY KEY(STUDENT_ID),
    UNIQUE(CNIC),
    FOREIGN KEY (CLASS_ID, SECTION_ID) REFERENCES SECTION (CLASS_ID, SECTION_ID),
    FOREIGN KEY (FAMILY_ID) REFERENCES FAMILY(FAMILY_ID)
);

/*----------------------- [[ STUDENT_HISTORY DDL ]] --------------------------*/

CREATE TABLE STUDENT_HISTORY
(
    STUDENT_ID INTEGER,
    HISTORY_ID INTEGER,
    CNIC VARCHAR2(13),
    F_NAME VARCHAR2(32),
    L_NAME VARCHAR2(32),
    DOB DATE,
    GENDER CHAR(1),
    PICTURE BFILE,
    CLASS_ID INTEGER,
    SECTION_ID CHAR(1),
    FAMILY_ID INTEGER,
    GUARDIAN_ID INTEGER,
    RELATION VARCHAR2(32),
    CHALLAN_ID VARCHAR2(15),
    NEW_ADMIT_OR_CLASS_CHANGE NUMERIC(1),
    ADMIT_DATE DATE NOT NULL,
    LAST_UPDATE_DATE DATE NOT NULL,
    PRIMARY KEY (STUDENT_ID, HISTORY_ID)
);

/*------------- [[ STUDENT INSERT, DELETE & UPDATE TRIGGERS*/

CREATE SEQUENCE STUDENT_ID_SEQ START WITH 10000 INCREMENT BY 17;

CREATE OR REPLACE TRIGGER STUDENT_ON_INSERT
    BEFORE INSERT ON STUDENT
    FOR EACH ROW
DECLARE
    MIN_AGE_NOT_MET EXCEPTION; PRAGMA EXCEPTION_INIT(MIN_AGE_NOT_MET, -20111);
    MAX_AGE_EXCEEDED EXCEPTION; PRAGMA EXCEPTION_INIT(MAX_AGE_EXCEEDED, -20112);
    GENDER_MISMATCH EXCEPTION; PRAGMA EXCEPTION_INIT(GENDER_MISMATCH, -20113);
    GUARDIAN_IS_MALE EXCEPTION; PRAGMA EXCEPTION_INIT(GUARDIAN_IS_MALE, -20114);
    MIN_AGE_ALLOWED NUMERIC(2);
    MAX_AGE_ALLOWED NUMERIC(2);
    GENDER_RESTRAINT_A CHAR(1);
    REQ_GUARD_A NUMERIC(1);
    GUARD_GENDER CHAR(1);
    AGE NUMERIC(4,2);
BEGIN

    SELECT CLASS.REQ_GUARD, CLASS.MIN_AGE, CLASS.MAX_AGE, SECTION.GENDER_RESTRAINT INTO REQ_GUARD_A, MIN_AGE_ALLOWED, MAX_AGE_ALLOWED, GENDER_RESTRAINT_A
    FROM SECTION
    INNER JOIN CLASS
    ON SECTION.CLASS_ID = CLASS.CLASS_ID
    WHERE SECTION.CLASS_ID = :NEW.CLASS_ID AND SECTION.SECTION_ID = :NEW.SECTION_ID;

    SELECT GENDER INTO GUARD_GENDER
    FROM GUARDIAN
    WHERE GUARDIAN_ID = :NEW.GUARDIAN_ID;

    AGE := ROUND(MONTHS_BETWEEN(SYSDATE(),:NEW.DOB)/12,2);

    IF REQ_GUARD_A <> 0 AND GUARD_GENDER = 'M' THEN
        RAISE_APPLICATION_ERROR(-20114, 'Error! Guardian can not be Male');
    ELSIF AGE < MIN_AGE_ALLOWED THEN
        RAISE_APPLICATION_ERROR(-20111, 'Error! Student is too young for this class - Trigger: STUDENT_ON_INSERT');
    ELSIF AGE >= MAX_AGE_ALLOWED THEN
        RAISE_APPLICATION_ERROR(-20112, 'Error! Student is too old for this class - Trigger: STUDENT_ON_INSERT');
    ELSIF :NEW.GENDER <> NVL(GENDER_RESTRAINT_A,:NEW.GENDER) THEN
        RAISE_APPLICATION_ERROR(-20113, 'Error! This section is not CO-ED - Trigger: STUDENT_ON_INSERT');
    ELSE
        :NEW.STUDENT_ID := STUDENT_ID_SEQ.NEXTVAL;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         DBMS_OUTPUT.PUT_LINE('Error! No data found - Trigger: STUDENT_ON_INSERT');
END;
/



CREATE OR REPLACE TRIGGER STUDENT_AFTER_INSERT
    AFTER INSERT ON STUDENT
    FOR EACH ROW
DECLARE
    MIN_AGE_ALLOWED NUMERIC(2);
BEGIN

    SELECT MIN_AGE INTO MIN_AGE_ALLOWED FROM CLASS WHERE CLASS_ID = :NEW.CLASS_ID;

    IF ROUND(MONTHS_BETWEEN(SYSDATE(), :NEW.DOB)/12,0) = MIN_AGE_ALLOWED THEN
        UPDATE FAMILY
        SET EARLY_INTRODUCER = 1,
            NUM_CHILDREN = NUM_CHILDREN + 1
        WHERE FAMILY_ID = :NEW.FAMILY_ID;
    ELSE
        UPDATE FAMILY
        SET NUM_CHILDREN = NUM_CHILDREN + 1
        WHERE FAMILY_ID = :NEW.FAMILY_ID;
    END IF;

    INSERT INTO STUDENT_HISTORY
    VALUES(:NEW.STUDENT_ID, 0, :NEW.CNIC, :NEW.F_NAME, :NEW.L_NAME, :NEW.DOB, :NEW.GENDER, :NEW.PICTURE, :NEW.CLASS_ID, :NEW.SECTION_ID, :NEW.FAMILY_ID, :NEW.GUARDIAN_ID, :NEW.RELATION, :NEW.CHALLAN_ID, 1, :NEW.ADMIT_DATE, :NEW.LAST_UPDATE_DATE);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error! Unhandled exception in Trigger: STUDENT_AFTER_INSERT');
END;
/

CREATE OR REPLACE TRIGGER STUDENT_AFTER_DELETE
    AFTER DELETE ON STUDENT
    FOR EACH ROW
BEGIN
    UPDATE FAMILY
    SET NUM_CHILDREN = NUM_CHILDREN - 1
    WHERE FAMILY_ID = :OLD.FAMILY_ID;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error! Unhandled exception in Trigger: STUDENT_AFTER_DELETE');
END;
/

/*NEW_ADMIT_OR_CLASS_CHANGE IS 0: CLASS WASNT CHANGED, 1: NEW INSERT, 2: CLASS WAS UPDATED*/

CREATE OR REPLACE TRIGGER STUDENT_UPDATE
    AFTER UPDATE ON STUDENT
    FOR EACH ROW
DECLARE
    MIN_AGE_NOT_MET EXCEPTION; PRAGMA EXCEPTION_INIT(MIN_AGE_NOT_MET, -20111);
    MAX_AGE_EXCEEDED EXCEPTION; PRAGMA EXCEPTION_INIT(MAX_AGE_EXCEEDED, -20112);
    GENDER_MISMATCH EXCEPTION; PRAGMA EXCEPTION_INIT(GENDER_MISMATCH, -20113);
    GUARDIAN_IS_MALE EXCEPTION; PRAGMA EXCEPTION_INIT(GUARDIAN_IS_MALE, -20114);
    MIN_AGE_ALLOWED NUMERIC(2);
    MAX_AGE_ALLOWED NUMERIC(2);
    GENDER_RESTRAINT_A CHAR(1);
    REQ_GUARD_A NUMERIC(1);
    GUARD_GENDER CHAR(1);
    AGE NUMERIC(4,2);
    CUR_S_ID INTEGER;
    NEW_OR_UPDATE NUMERIC(1);
BEGIN

    IF :OLD.CLASS_ID <> :NEW.CLASS_ID OR :OLD.SECTION_ID <> :NEW.SECTION_ID THEN
        SELECT CLASS.REQ_GUARD, CLASS.MIN_AGE, CLASS.MAX_AGE, SECTION.GENDER_RESTRAINT INTO REQ_GUARD_A, MIN_AGE_ALLOWED, MAX_AGE_ALLOWED, GENDER_RESTRAINT_A
        FROM SECTION
        INNER JOIN CLASS
        ON SECTION.CLASS_ID = CLASS.CLASS_ID
        WHERE SECTION.CLASS_ID = :NEW.CLASS_ID AND SECTION.SECTION_ID = :NEW.SECTION_ID;

        SELECT GENDER INTO GUARD_GENDER
        FROM GUARDIAN
        WHERE GUARDIAN_ID = :NEW.GUARDIAN_ID;

        AGE := ROUND(MONTHS_BETWEEN(SYSDATE(),:NEW.DOB)/12,2);

        IF REQ_GUARD_A <> 0 AND GUARD_GENDER = 'M' THEN
        RAISE_APPLICATION_ERROR(-20114, 'Error! Guardian can not be Male');
        ELSIF AGE < MIN_AGE_ALLOWED THEN
            RAISE_APPLICATION_ERROR(-20111, 'Error! Student is too young for this class - Trigger: STUDENT_ON_INSERT');
        ELSIF AGE >= MAX_AGE_ALLOWED THEN
            RAISE_APPLICATION_ERROR(-20112, 'Error! Student is too old for this class - Trigger: STUDENT_ON_INSERT');
        ELSIF :NEW.GENDER <> NVL(GENDER_RESTRAINT_A,:NEW.GENDER) THEN
            RAISE_APPLICATION_ERROR(-20113, 'Error! This section is not CO-ED - Trigger: STUDENT_ON_INSERT');
        END IF;
        
    END IF;

    IF :OLD.CLASS_ID = :NEW.CLASS_ID AND :OLD.SECTION_ID = :NEW.SECTION_ID THEN
        NEW_OR_UPDATE := 0;
    ELSE
        NEW_OR_UPDATE := 2;
    END IF;

    INSERT INTO STUDENT_HISTORY
    VALUES(:NEW.STUDENT_ID, 0, :NEW.CNIC, :NEW.F_NAME, :NEW.L_NAME, :NEW.DOB, :NEW.GENDER, :NEW.PICTURE, :NEW.CLASS_ID, :NEW.SECTION_ID, :NEW.FAMILY_ID, :NEW.GUARDIAN_ID, :NEW.RELATION, :NEW.CHALLAN_ID, NEW_OR_UPDATE, :NEW.ADMIT_DATE, :NEW.LAST_UPDATE_DATE);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error! NO_DATA_FOUND in Trigger: STUDENT_UPDATE');
END;
/



/*----------------- [[ STUDENT_HISTORY INSERT TRIGGER*/

CREATE OR REPLACE TRIGGER S_HIST_ON_INSERT
    BEFORE INSERT ON STUDENT_HISTORY
    FOR EACH ROW
DECLARE
    MAX_HISTORY_ID INTEGER;
BEGIN
    SELECT NVL(MAX(HISTORY_ID),0) INTO MAX_HISTORY_ID
    FROM STUDENT_HISTORY
    GROUP BY STUDENT_ID
    HAVING STUDENT_ID = :NEW.STUDENT_ID;

    :NEW.HISTORY_ID := MAX_HISTORY_ID + 1;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        :NEW.HISTORY_ID := 1;
END;
/



/*----------------------- [[ ACCOMPANYING DDL ]] --------------------------*/


CREATE TABLE ACCOMPANYING
(
    STUDENT_ID INTEGER,
    TOKEN_NO INTEGER,
    GUARDIAN_ID INTEGER NOT NULL,  
    PREGNANT NUMERIC(1) DEFAULT 0,
    REASON VARCHAR2(64),
    PRIMARY KEY (STUDENT_ID, TOKEN_NO),
    FOREIGN KEY (STUDENT_ID) REFERENCES STUDENT(STUDENT_ID),
    FOREIGN KEY (GUARDIAN_ID) REFERENCES GUARDIAN(GUARDIAN_ID)
);

CREATE OR REPLACE TRIGGER ACCOMPANYING_BEFORE_INSERT
    BEFORE INSERT ON ACCOMPANYING
    FOR EACH ROW
DECLARE
    MAX_TOKEN_NO INTEGER;
    GID INTEGER;
    GUARDIAN_MISMATCH EXCEPTION;
    PRAGMA EXCEPTION_INIT(GUARDIAN_MISMATCH,-20211);
BEGIN
    SELECT GUARDIAN_ID INTO GID
    FROM STUDENT
    WHERE STUDENT_ID = :NEW.STUDENT_ID;

    IF GID <> :NEW.GUARDIAN_ID THEN
        RAISE_APPLICATION_ERROR(-20211, 'Guardian Mismatch');
    END IF;

    SELECT MAX(TOKEN_NO) INTO MAX_TOKEN_NO
    FROM ACCOMPANYING
    GROUP BY STUDENT_ID
    HAVING STUDENT_ID = :NEW.STUDENT_ID;

    :NEW.TOKEN_NO := MAX_TOKEN_NO + 1;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        :NEW.TOKEN_NO := 1;
END;
/



INSERT INTO PERSON
VALUES('4210118467511', 'AHMED', 'ALI', '3155547080', 'M', 'aliahmed@gmail.com', 2);

INSERT INTO PERSON
VALUES('4210118460750', 'ANWAR', 'ALI', '3155204019', 'M', 'anwarali@gmail.com', 1);

INSERT INTO PERSON
VALUES('4210118540750', 'HUSNA', 'ALI', '3155205227', 'F', 'husnaa@gmail.com', 1);

INSERT INTO PERSON
VALUES('4210118879750', 'SOMAYA', 'ANWAR', '3155206721', 'F', 'sanwar@gmail.com', 1);

INSERT INTO PERSON
VALUES('4429118879750', 'MUJTABA', 'IHSAN', '3155206721', 'F', 'mihsan@gmail.com', 1);

INSERT INTO PERSON
VALUES('8653118879750', 'SANA', 'HASAN', '3155206721', 'F', 'shasan@gmail.com', 1);

UPDATE PERSON
SET EMAIL = 'ahmedali@gmail.com'
WHERE CNIC = '4210118467511';

UPDATE PERSON
SET EMAIL = 'ahmed_2000@gmail.com'
WHERE CNIC = '4210118467511';

UPDATE PERSON
SET EMAIL = 'anwar_ali@gmail.com'
WHERE CNIC = '4210118460750';




INSERT INTO GUARDIAN(GUARDIAN_ID, CNIC, F_NAME, L_NAME, CONTACT_NO, GENDER)
VALUES(0, '4210128548299', 'OMAR', 'MANZAR', '3102593210', 'M');

INSERT INTO GUARDIAN(GUARDIAN_ID, CNIC, F_NAME, L_NAME, CONTACT_NO, GENDER)
VALUES(0, '4210128992799', 'ALINA', 'NILAM', '3105638124', 'F');

INSERT INTO GUARDIAN(GUARDIAN_ID, CNIC, F_NAME, L_NAME, CONTACT_NO, GENDER)
VALUES(0, '4210128993431', 'AMINA', 'AHMED', '3152934528', 'F');

INSERT INTO GUARDIAN(GUARDIAN_ID, CNIC, F_NAME, L_NAME, CONTACT_NO, GENDER)
VALUES(0, '4210128342332', 'TURAB', 'ASAD', '31322325223', 'M');

UPDATE GUARDIAN
SET CONTACT_NO = '3152593210'
WHERE CNIC = '4210128548299';



INSERT INTO CLASS
VALUES(1,1,1,3,4);

INSERT INTO CLASS
VALUES(2,0,0,4,5);

INSERT INTO CLASS
VALUES(3,0,0,5,6);

INSERT INTO CLASS
VALUES(4,0,0,6,7);

INSERT INTO CLASS
VALUES(5,0,0,7,8);

INSERT INTO CLASS
VALUES(6,0,0,8,9);

INSERT INTO CLASS
VALUES(7,0,0,9,10);

INSERT INTO CLASS
VALUES(8,0,0, 10,11 );



INSERT INTO SECTION
VALUES(1,'A','AAA', 'M');

INSERT INTO SECTION
VALUES(1,'B', 'AAB', 'M');

INSERT INTO SECTION
VALUES(2,'A', 'ABA', 'M');

INSERT INTO SECTION
VALUES(2,'B', 'ABB', 'F');

INSERT INTO SECTION
VALUES(2,'C', 'BAA', 'M');

INSERT INTO SECTION
VALUES(3,'A', 'BAB', 'F');

INSERT INTO SECTION
VALUES(3,'B', 'BBA', 'F');

INSERT INTO SECTION
VALUES(3,'C', 'BBB', 'M');

INSERT INTO SECTION
VALUES(4,'A', 'CAA', 'F');

INSERT INTO SECTION
VALUES(4,'B', 'CAB', 'M');

INSERT INTO SECTION
VALUES(5,'A', 'CBB', 'F');

INSERT INTO SECTION
VALUES(5,'B', 'CBC', 'M');

INSERT INTO SECTION
VALUES(6,'A', 'CCC', 'F');

INSERT INTO SECTION
VALUES(6,'B', 'CCA', 'M');

INSERT INTO SECTION
VALUES(7,'A', 'ACC', 'F');

INSERT INTO SECTION
VALUES(7,'B', 'BCC', 'M');

INSERT INTO SECTION
VALUES(8,'A', 'CAC', 'F');

INSERT INTO SECTION
VALUES(8,'B', 'BAC', 'M');



INSERT INTO FAMILY
VALUES(0,1000, 1002, 0, 0, '12/8/2014', 0);

INSERT INTO FAMILY
VALUES(0,1001, 1003, 0, 0, '14/8/2016', 0);

INSERT INTO FAMILY
VALUES(0,1008, 1009, 0, 0, '18/8/2017', 0);

INSERT INTO STUDENT
VALUES(0,'4210110000001', 'SHUMAYL', 'HASAN', TO_DATE('12/2/2017','DD/MM/YYYY'), 'F', NULL, 1,'A', 3312, 5002, 'AUNT', '9212184', TO_DATE('11/5/2020','DD/MM/YYYY'), TO_DATE('11/5/2020','DD/MM/YYYY'));

INSERT INTO STUDENT
VALUES(0,'4210110000002', 'SARA', 'SOHAIL', TO_DATE('12/2/2016','DD/MM/YYYY'), 'F', NULL, 2,'B', 3312, 5003, 'UNCLE', '9212190', TO_DATE('12/5/2020','DD/MM/YYYY'), TO_DATE('12/5/2020','DD/MM/YYYY'));

INSERT INTO STUDENT
VALUES(0,'4210110000003', 'HASAN', 'MAJEED', TO_DATE('21/10/2014','DD/MM/YYYY'), 'M', NULL, 3,'C', 3325, 5003, 'UNCLE', '9212190', TO_DATE('12/5/2017','DD/MM/YYYY'), TO_DATE('12/5/2019','DD/MM/YYYY'));

INSERT INTO STUDENT
VALUES(0,'4210110000004', 'HAREEM', 'MAJEED', TO_DATE('22/2/2015','DD/MM/YYYY'), 'F', NULL, 3,'B', 3325, 5003, 'UNCLE', '9212190', TO_DATE('12/5/2017','DD/MM/YYYY'), TO_DATE('12/5/2018','DD/MM/YYYY'));

INSERT INTO STUDENT
VALUES(0,'4210110000005', 'HAROON', 'MAJEED', TO_DATE('22/2/2016','DD/MM/YYYY'), 'M', NULL, 3,'C', 3325, 5003, 'UNCLE', '9212190', TO_DATE('12/5/2017','DD/MM/YYYY'), TO_DATE('12/5/2018','DD/MM/YYYY'));

INSERT INTO ACCOMPANYING
VALUES(10017,0,5002,0,'MOTHER IS SICK');

/* DROP ALL TABLES */

DROP TABLE ACCOMPANYING;

DROP TABLE STUDENT_HISTORY;
DROP TABLE STUDENT;
DROP SEQUENCE STUDENT_ID_SEQ;

DROP TABLE FAMILY;
DROP SEQUENCE FAMILY_ID_SEQ;

DROP TABLE SECTION; 
DROP TABLE CLASS;

DROP TABLE GUARDIAN_HISTORY;
DROP TABLE GUARDIAN;
DROP SEQUENCE GUARDIAN_ID_SEQ;

DROP TABLE PARENT_HISTORY;
DROP TABLE PARENT;
DROP SEQUENCE PARENT_ID_SEQ;
DROP TABLE STAFF;
DROP SEQUENCE STAFF_ID_SEQ;
DROP TABLE PERSON;

/*----------------------- [[ QUERIES (1 - 10) ----------------------------]]*/

/*------------------------[#1]*/

SELECT * FROM STUDENT;


/*------------------------[#2]*/
SELECT F.FATHER_ID, P2.CNIC, PS2.F_NAME, PS2.L_NAME, PS2.CONTACT_NO, F.MOTHER_ID, P1.CNIC, PS1.F_NAME, PS1.L_NAME, PS1.CONTACT_NO
FROM FAMILY F
INNER JOIN PARENT P1 ON F.MOTHER_ID = P1.PARENT_ID
INNER JOIN PERSON PS1 ON PS1.CNIC = P1.CNIC
INNER JOIN PARENT P2 ON F.FATHER_ID = P2.PARENT_ID
INNER JOIN PERSON PS2 ON PS2.CNIC = P2.CNIC;

/*------------------------[#3]*/

SELECT G.GUARDIAN_ID, G.CNIC, G.F_NAME||' '||G.L_NAME AS G_NAME, G.CONTACT_NO, G.GENDER, S.RELATION AS RELATIONSHIP, S.STUDENT_ID, S.F_NAME||' '||S.L_NAME AS S_NAME
FROM STUDENT S
INNER JOIN GUARDIAN G ON S.GUARDIAN_ID = G.GUARDIAN_ID
ORDER BY RELATION, G.GUARDIAN_ID;

/*------------------------[#4]*/

SELECT F.FAMILY_ID, F.FATHER_ID, P2.CNIC, PS2.F_NAME||' '||PS2.L_NAME AS FATHER_NAME, PS2.CONTACT_NO, F.MOTHER_ID, P1.CNIC, PS1.F_NAME||' '||PS1.L_NAME AS MOTHER_NAME, PS1.CONTACT_NO, S.STUDENT_ID, S.F_NAME||' '||S.L_NAME AS S_NAME
FROM FAMILY F
INNER JOIN PARENT P1 ON F.MOTHER_ID = P1.PARENT_ID
INNER JOIN PERSON PS1 ON PS1.CNIC = P1.CNIC
INNER JOIN PARENT P2 ON F.FATHER_ID = P2.PARENT_ID
INNER JOIN PERSON PS2 ON PS2.CNIC = P2.CNIC
INNER JOIN STUDENT S ON F.FAMILY_ID = S.FAMILY_ID
ORDER BY FAMILY_ID;

/*------------------------[#5]*/

SELECT * FROM STUDENT S1
WHERE (SELECT COUNT(*) FROM STUDENT S2 GROUP BY S2.FAMILY_ID HAVING S1.FAMILY_ID = S2.FAMILY_ID) > 1
ORDER BY CLASS_ID, SECTION_ID;

/*------------------------[#6]*/

/*
USE H.NEW_ADMIT_OR_CLASS_CHANGE > 0 - FOR INCLUDING NEW ADMISSIONS
USE H.NEW_ADMIT_OR_CLASS_CHANGE > 1 - FOR EXCLUDING NEW ADMISSIONS
*/

SELECT S.STUDENT_ID, S.CNIC, S.DOB, S.F_NAME||' '||S.L_NAME, S.CLASS_ID, S.SECTION_ID AS NAME FROM STUDENT_HISTORY H
INNER JOIN STUDENT S ON H.STUDENT_ID = S.STUDENT_ID
WHERE H.NEW_ADMIT_OR_CLASS_CHANGE > 0 AND H.LAST_UPDATE_DATE BETWEEN TO_DATE('27/5/2020','DD/MM/YYYY') AND TO_DATE('29/5/2020', 'DD/MM/YYYY');
/*------------------------[#7]*/

SELECT * FROM STUDENT
WHERE ADMIT_DATE BETWEEN TO_DATE('12/5/2020','DD/MM/YYYY') AND TO_DATE('29/5/2020', 'DD/MM/YYYY')
ORDER BY CLASS_ID, SECTION_ID;

/*------------------------[#8]*/

SELECT F.FAMILY_ID, F.FATHER_ID, P2.CNIC, PS2.F_NAME, PS2.L_NAME, PS2.CONTACT_NO, F.MOTHER_ID, P1.CNIC, PS1.F_NAME, PS1.L_NAME, PS1.CONTACT_NO, S.STUDENT_ID, S.F_NAME||' '||S.L_NAME AS S_NAME
FROM FAMILY F
INNER JOIN PARENT P1 ON F.MOTHER_ID = P1.PARENT_ID
INNER JOIN PERSON PS1 ON PS1.CNIC = P1.CNIC
INNER JOIN PARENT P2 ON F.FATHER_ID = P2.PARENT_ID
INNER JOIN PERSON PS2 ON PS2.CNIC = P2.CNIC
INNER JOIN STUDENT S ON F.FAMILY_ID = S.FAMILY_ID
WHERE F.JOIN_DATE BETWEEN TO_DATE('1/9/2017','DD/MM/YYYY') AND TO_DATE('29/10/2020', 'DD/MM/YYYY')
ORDER BY FAMILY_ID, STUDENT_ID;

/*------------------------[#9]*/

SELECT F.FATHER_ID, P2.CNIC, PS2.F_NAME, PS2.L_NAME, PS2.CONTACT_NO, F.MOTHER_ID, P1.CNIC, PS1.F_NAME, PS1.L_NAME, PS1.CONTACT_NO
FROM FAMILY F
INNER JOIN PARENT P1 ON F.MOTHER_ID = P1.PARENT_ID
INNER JOIN PERSON PS1 ON PS1.CNIC = P1.CNIC
INNER JOIN PARENT P2 ON F.FATHER_ID = P2.PARENT_ID
INNER JOIN PERSON PS2 ON PS2.CNIC = P2.CNIC
WHERE F.EARLY_INTRODUCER = 1
ORDER BY F.FAMILY_ID;

/*------------------------[#10]*/


/*
IN WHERE CONDITION (NEW_ADMIT_OR_CLASS_CHANGE):
AGAIN.. > 0 - INCLUDING NEW ADMISSIONS
        > 1 - EXCLUDING NEW ADMISSIONS
*/

SELECT STUDENT_ID, F_NAME||' '||L_NAME AS NAME, CLASS_ID, SECTION_ID
FROM STUDENT_HISTORY
WHERE NEW_ADMIT_OR_CLASS_CHANGE > 0
ORDER BY STUDENT_ID, CLASS_ID, SECTION_ID;




/*-------------------------[#11]*/



/*-------------------------[#12]*/

SELECT S.CLASS_ID, S.SECTION_ID, S.TITLE, COUNT(STM.STUDENT_ID) AS NUM_MALE_STUDENT, COUNT(STF.STUDENT_ID) AS NUM_FEMALE_STUDENT, COUNT(STM.STUDENT_ID) + COUNT(STF.STUDENT_ID) TOTAL_NUM
FROM STUDENT ST
LEFT JOIN STUDENT STM ON ST.STUDENT_ID = STM.STUDENT_ID AND STM.GENDER = 'M'
LEFT JOIN STUDENT STF ON ST.STUDENT_ID = STF.STUDENT_ID AND STF.GENDER = 'F'
RIGHT JOIN SECTION S ON ST.CLASS_ID = S.CLASS_ID AND ST.SECTION_ID = S.SECTION_ID
GROUP BY S.CLASS_ID, S.SECTION_ID, S.TITLE
ORDER BY S.CLASS_ID, S.SECTION_ID;

/*-------------------------[#13]*/

SELECT STUDENT_ID, F_NAME||' '||L_NAME AS S_NAME, TO_CHAR(DOB, 'DD/MM/YYYY') AS DOB, CNIC, CLASS_ID, SECTION_ID, LAST_UPDATE_DATE
FROM STUDENT ST WHERE ADD_MONTHS(SYSDATE,-5) > ST.LAST_UPDATE_DATE;

SELECT STUDENT_ID, F_NAME||' '||L_NAME AS S_NAME, TO_CHAR(DOB, 'DD/MM/YYYY') AS DOB, CNIC, CLASS_ID, SECTION_ID, LAST_UPDATE_DATE
FROM STUDENT ST 
WHERE ADD_MONTHS(SYSDATE, (-12 * 2 ) ) > ST.LAST_UPDATE_DATE;

/*-------------------------[#14]*/


/*PARENTS*/
SELECT P2.CNIC CNIC, PS2.F_NAME||' '||PS2.L_NAME AS NAME, PS2.CONTACT_NO, P1.CNIC, PS1.F_NAME||' '||PS1.L_NAME AS NAME, PS1.CONTACT_NO
FROM FAMILY F
INNER JOIN PARENT P1 ON F.MOTHER_ID = P1.PARENT_ID
INNER JOIN PERSON PS1 ON PS1.CNIC = P1.CNIC
INNER JOIN PARENT P2 ON F.FATHER_ID = P2.PARENT_ID
INNER JOIN PERSON PS2 ON PS2.CNIC = P2.CNIC
WHERE F.FAMILY_ID = (SELECT FAMILY_ID FROM STUDENT WHERE STUDENT_ID = 10561);

/*GUARDIAN*/
SELECT G.GUARDIAN_ID, G.CNIC, G.F_NAME||' '||G.LNAME AS NAME, G.GENDER, G.CONTACT_NO, FROM STUDENT S
INNER JOIN GUARDIAN G ON S.GUARDIAN_ID = G.GUARDIAN_ID
WHERE S.STUDENT_ID = 10561;

/*SIBLINGS*/
SELECT ST2.* FROM STUDENT ST1
INNER JOIN STUDENT ST2 ON ST1.FAMILY_ID = ST2.FAMILY_ID
WHERE ST1.STUDENT_ID <> ST2.STUDENT_ID AND ST1.STUDENT_ID = 10561;

/*CLASS HISTORY*/
SELECT STUDENT_ID, F_NAME||' '||L_NAME AS NAME, CLASS_ID, SECTION_ID AS SECTION
FROM STUDENT_HISTORY
WHERE STUDENT_ID = 10000;
/*-------------------------[#15]*/

SELECT S.STUDENT_ID, S.F_NAME||' '||S.L_NAME AS S_NAME, TO_CHAR(S.DOB, 'DD/MM/YYYY') AS DOB, S.CNIC, S.CLASS_ID, S.SECTION_ID, G.GUARDIAN_ID, G.F_NAME||' '||G.L_NAME AS GUARDIAN_NAME, G.GENDER AS GUARDIAN_GENDER
FROM PARENT P
INNER JOIN FAMILY F ON F.MOTHER_ID = P.PARENT_ID OR F.FATHER_ID = P.PARENT_ID
INNER JOIN STUDENT S ON S.FAMILY_ID = F.FAMILY_ID
INNER JOIN GUARDIAN G ON S.GUARDIAN_ID = G.GUARDIAN_ID
WHERE P.PARENT_ID = 1000
ORDER BY S.STUDENT_ID;

SELECT S.STUDENT_ID, S.F_NAME||' '||S.L_NAME AS S_NAME, TO_CHAR(S.DOB, 'DD/MM/YYYY') AS DOB, S.CNIC, S.CLASS_ID, S.SECTION_ID, G.GUARDIAN_ID, G.F_NAME||' '||G.L_NAME AS GUARDIAN_NAME, G.GENDER AS GUARDIAN_GENDER
FROM PERSON PE
INNER JOIN PARENT P ON P.CNIC = PE.CNIC
INNER JOIN FAMILY F ON F.MOTHER_ID = P.PARENT_ID OR F.FATHER_ID = P.PARENT_ID
INNER JOIN STUDENT S ON S.FAMILY_ID = F.FAMILY_ID
INNER JOIN GUARDIAN G ON S.GUARDIAN_ID = G.GUARDIAN_ID
WHERE PE.F_NAME||' '||PE.L_NAME LIKE '%A%'
ORDER BY S.STUDENT_ID;
