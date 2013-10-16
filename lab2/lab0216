--Removing existent tables

DROP TABLE Results;
DROP TABLE Races;
DROP TABLE Horses;
DROP TABLE Competitions;
DROP TABLE Owners;
DROP TABLE Jockeys;

--Create table for jockeys

CREATE TABLE
    Jockeys
    (
        Jockey_ID NUMBER(10) PRIMARY KEY,
        Jockey_Name VARCHAR2(100) NOT NULL,
        Jockey_Address VARCHAR2(300),
        Jockey_DateOfBirth DATE,
        Jockey_Height NUMBER(10) NOT NULL
            CHECK (Jockey_Height > 0),
        Jockey_Weight NUMBER(10) NOT NULL
            CHECK (Jockey_Weight > 0)
    );


--Insert some values into Jockeys table

INSERT INTO Jockeys VALUES
    (1, 'Louis Silva', '61 Constance St, Nottingham NG7, Great Bitain', to_date('16-12-1984','dd-mm-yyyy'), 178, 64);

INSERT INTO Jockeys VALUES
    (2, 'Daniel Blanch', '15-16 Cambridge Ave, Wilmslow, Cheshire East SK9 5JX, Great Bitain', to_date('03-04-1976','dd-mm-yyyy'), 190, 88);


--Create table for owners

CREATE TABLE
    Owners
    (
        Owner_ID NUMBER(10) PRIMARY KEY,
        Owner_Name VARCHAR2(100) NOT NULL,
        Owner_Address VARCHAR2(300) NOT NULL
    );


--Insert some values into Owners table

INSERT INTO Owners VALUES
    (1, 'sir Paul Willamson', 'River Bollin Trail, Wilmslow, Cheshire East SK9 4LA, Great Bitain');

INSERT INTO Owners VALUES
    (2, 'John Makferson', '85 Llanelian Rd, Old Colwyn, Colwyn Bay, Conwy LL29 8UN, Great Bitain');


--Create table for competitions

CREATE TABLE
    Competitions
    (
        Competition_ID NUMBER(10) PRIMARY KEY,
        Competition_Name VARCHAR2(100) NOT NULL,
        Competition_Date DATE NOT NULL,
        Competition_Area VARCHAR2(100),
        Competition_NumberOfRaces NUMBER(10) NOT NULL
            CHECK (Competition_NumberOfRaces > 0)
    );


--Insert some values into Competitions table

INSERT INTO Competitions VALUES
    (1, 'Spring Races', to_date('19-04-2012','dd-mm-yyyy'), '', 5);

INSERT INTO Competitions VALUES
    (2, 'Summer Races', to_date('14-07-2012','dd-mm-yyyy'), 'Sheffield', 8);


--Create table for horses

CREATE TABLE
    Horses
    (
        Horse_ID NUMBER(10) PRIMARY KEY,
        Jockey_ID NUMBER(10) NOT NULL REFERENCES Jockeys(Jockey_ID),
        Owner_ID NUMBER(10) NOT NULL REFERENCES Owners(Owner_ID),
        Horse_Name VARCHAR2(100) NOT NULL,
        Horse_Gender VARCHAR2(1) NOT NULL
            CHECK (Horse_Gender IN('M', 'F')), -- 'M' - Male, 'F' - Female
        Horse_DateOfBirth DATE NOT NULL
    );


--Insert some values into Horses table

INSERT INTO Horses VALUES
    (1, 2, 1, 'Ginger', 'F', to_date('19-04-2010','dd-mm-yyyy'));

INSERT INTO Horses VALUES
    (2, 1, 2, 'Storm', 'M', to_date('28-08-2009','dd-mm-yyyy'));


--Create table for races of competitions

CREATE TABLE
    Races
    (
        Race_ID NUMBER(10) PRIMARY KEY,
        Competition_ID NUMBER(10) NOT NULL REFERENCES Competitions(Competition_ID) ON UPDATE CASCADE
    );


--Insert some values into Races table

INSERT INTO Races VALUES
    (1, 1);

INSERT INTO Races VALUES
    (2, 1);

INSERT INTO Races VALUES
    (3, 1);


--Create table for results

CREATE TABLE
    Results
    (
        Result_ID NUMBER(10) PRIMARY KEY,
        Horse_ID NUMBER(10) NOT NULL REFERENCES Horses(Horse_ID),
        Race_ID NUMBER(10) NOT NULL REFERENCES Races(Race_ID),
        Race_HorsePlace NUMBER(3) NOT NULL
            CHECK (Race_HorsePlace >= 0) -- 0 if horse didn't finished
    );


--Insert some values into Results table

INSERT INTO Results VALUES
    (1, 1, 2, 1);

INSERT INTO Results VALUES
    (2, 2, 3, 2);

COMMIT;​
