USE [DATA TEST];

--1.1 Create the database and tables-- 

CREATE TABLE Faculty (
    FacultyID    CHAR(4)      NOT NULL,
    FacultyName  VARCHAR(50)  NOT NULL,
    CONSTRAINT PK_Faculty PRIMARY KEY (FacultyID)
);

CREATE TABLE Venue (
    VenueID       CHAR(4)      NOT NULL,
    VenueName     VARCHAR(50)  NOT NULL,
    VenueAddress  VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Venue PRIMARY KEY (VenueID)
);

CREATE TABLE Debate (
    DebateID        CHAR(4)  NOT NULL,
    FacultyID_A     CHAR(4)  NOT NULL,
    FacultyID_B     CHAR(4)  NOT NULL,
    VenueID         CHAR(4)  NOT NULL,
    DebateDate      DATE     NOT NULL,
    DebateTime      TIME(0)  NOT NULL,
    DebateDuration  INT      NOT NULL,   -- minutes
    CONSTRAINT PK_Debate PRIMARY KEY (DebateID),
    CONSTRAINT FK_Debate_FacultyA FOREIGN KEY (FacultyID_A) REFERENCES Faculty(FacultyID),
    CONSTRAINT FK_Debate_FacultyB FOREIGN KEY (FacultyID_B) REFERENCES Faculty(FacultyID),
    CONSTRAINT FK_Debate_Venue    FOREIGN KEY (VenueID)     REFERENCES Venue(VenueID)
);
GO

--1.2 Populate the tables--
INSERT INTO Faculty (FacultyID, FacultyName) VALUES
('F001', 'Faculty of Science'),
('F002', 'Faculty of Engineering'),
('F003', 'Faculty of Humanities'),
('F004', 'Faculty of Law'),
('F005', 'Faculty of Commerce');

INSERT INTO Venue (VenueID, VenueName, VenueAddress) VALUES
('V001', 'Newton Hall',       '12 University Road, Cape Town'),
('V002', 'Curie Centre',      '44 Innovation Avenue, Gqeberha'),
('V003', 'Plato Auditorium',  '88 Knowledge Street, Durban'),
('V004', 'Darwin Hall',       '15 Research Lane, Johannesburg'),
('V005', 'Aristotle Theatre', '9 Academic Crescent, Tshwane');

INSERT INTO Debate (DebateID, FacultyID_A, FacultyID_B, VenueID, DebateDate, DebateTime, DebateDuration) VALUES
('D001', 'F001', 'F002', 'V001', '2026-08-10', '10:00', 60),
('D002', 'F003', 'F005', 'V004', '2026-08-11', '14:00', 90),
('D003', 'F002', 'F003', 'V005', '2026-08-12', '18:00', 90),
('D004', 'F001', 'F005', 'V003', '2026-08-13', '16:00', 120),
('D005', 'F002', 'F005', 'V001', '2026-08-14', '17:00', 120);
GO

-- 1.3 Alter DEBATE: add a field for seats available -- 
ALTER TABLE Debate
ADD SeatsAvailable INT NULL;
GO

--1.4 Update the new field-- 
UPDATE Debate
SET SeatsAvailable = 400
WHERE DebateID = 'D003';
GO

--2.1 Venues where no debates will be hosted-- 
SELECT v.VenueName
FROM Venue v
WHERE NOT EXISTS (SELECT 1 FROM Debate d WHERE d.VenueID = v.VenueID);
GO


--2.2 Total debate duration per venue, alphabetical-- 
SELECT v.VenueName        AS VENUE_NAME,
       SUM(d.DebateDuration) AS TOTAL_DURATION
FROM Venue v
LEFT JOIN Debate d ON d.VenueID = v.VenueID
GROUP BY v.VenueName
ORDER BY v.VenueName ASC;
GO
-- 2.3 Longest debate at venue V001 --
SELECT v.VenueName        AS VENUE_NAME,
       d.DebateDate       AS DEBATE_DATE,
       d.DebateDuration   AS DEBATE_DURATION
FROM Venue v
INNER JOIN Debate d ON d.VenueID = v.VenueID
WHERE v.VenueID = 'V001'
  AND d.DebateDuration = (SELECT MAX(DebateDuration)
                          FROM Debate
                          WHERE VenueID = 'V001');
GO
