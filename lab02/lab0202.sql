DROP TABLE RESULTS;
DROP TABLE RACES;
DROP TABLE COMPETITIONS;

DROP TABLE HORSES;

DROP TABLE JOCKEYS;
DROP TABLE OWNERS;

----------------------------------------------------------------------------------------------------

CREATE TABLE JOCKEYS
    (
        ID NUMBER(2) PRIMARY KEY,
	    NAME VARCHAR2(50) NOT NULL,  
	    ADDRESS VARCHAR2(50) NOT NULL,
        HEIGHT NUMBER(2) NOT NULL,
        WEIGHT NUMBER(2) NOT NULL,
        BIRTH DATE NOT NULL
    );

CREATE TABLE OWNERS
    (
        ID NUMBER(2) PRIMARY KEY,
        NAME VARCHAR2(50) NOT NULL,
        ADDRESS VARCHAR2(50) NOT NULL
    );

CREATE TABLE HORSES
    (
        ID NUMBER(2) PRIMARY KEY,
        JOCKEY_ID NUMBER(2) REFERENCES JOCKEYS(ID) NOT NULL,
        OWNER_ID NUMBER(2) REFERENCES OWNERS(ID) NOT NULL,
        NICK VARCHAR2(10) NOT NULL,
        BIRTH DATE NOT NULL,
        SEX VARCHAR2(5) NOT NULL        
    );

CREATE TABLE COMPETITIONS
    (
        ID NUMBER(2) PRIMARY KEY,
        COMPETITION_DATE DATE NOT NULL,
        PLACE VARCHAR2(50) NOT NULL,
        NAME VARCHAR2(50),
        RACE_COUNT NUMBER(2) NOT NULL
    );

CREATE TABLE RACES
    (
        ID NUMBER(2) PRIMARY KEY,
        COMPETITION_ID NUMBER(2) REFERENCES COMPETITIONS(ID) NOT NULL        
    );

CREATE TABLE RESULTS
    (
        RACE_ID NUMBER(2) REFERENCES RACES(ID) NOT NULL,
        HORSE_ID NUMBER(2) REFERENCES HORSES(ID) NOT NULL,
        POSITION NUMBER(2) NOT NULL
    );

COMMIT;
----------------------------------------------------------------------------------------------------