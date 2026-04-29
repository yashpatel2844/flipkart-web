CREATE DATABASE IPL_DB;

USE IPL_DB;

CREATE TABLE Teams(
team_id INT PRIMARY KEY AUTO_INCREMENT,
team_name VARCHAR(50),
captain VARCHAR(50),
coach VARCHAR(50),
home_ground VARCHAR(50)
);

CREATE TABLE Players(
player_id INT PRIMARY KEY AUTO_INCREMENT,
player_name VARCHAR(50),
team_id INT,
role VARCHAR(30),
country VARCHAR(30),
price DECIMAL(12,2),
FOREIGN KEY(team_id) REFERENCES Teams(team_id)
);

CREATE TABLE Matches(
match_id INT PRIMARY KEY AUTO_INCREMENT,
team1_id INT,
team2_id INT,
venue VARCHAR(50),
match_date DATE,
winner_team_id INT,
FOREIGN KEY(team1_id) REFERENCES Teams(team_id),
FOREIGN KEY(team2_id) REFERENCES Teams(team_id),
FOREIGN KEY(winner_team_id) REFERENCES Teams(team_id)
);

CREATE TABLE Scorecard(
score_id INT PRIMARY KEY AUTO_INCREMENT,
match_id INT,
player_id INT,
runs INT,
wickets INT,
catches INT,
FOREIGN KEY(match_id) REFERENCES Matches(match_id),
FOREIGN KEY(player_id) REFERENCES Players(player_id)
);

CREATE TABLE PointsTable(
team_id INT PRIMARY KEY,
matches_played INT DEFAULT 0,
won INT DEFAULT 0,
lost INT DEFAULT 0,
points INT DEFAULT 0,
net_run_rate DECIMAL(5,2),
FOREIGN KEY(team_id) REFERENCES Teams(team_id)
);

INSERT INTO Teams(team_name,captain,coach,home_ground)
VALUES
('Mumbai Indians','Hardik Pandya','Boucher','Wankhede'),
('Chennai Super Kings','Ruturaj Gaikwad','Fleming','Chepauk'),
('Royal Challengers Bengaluru','Rajat Patidar','Andy Flower','Chinnaswamy'),
('Kolkata Knight Riders','Ajinkya Rahane','Chandrakant Pandit','Eden Gardens');

INSERT INTO Players(player_name,team_id,role,country,price)
VALUES
('Rohit Sharma',1,'Batsman','India',16000000),
('Jasprit Bumrah',1,'Bowler','India',12000000),
('MS Dhoni',2,'WK-Batsman','India',12000000),
('Ravindra Jadeja',2,'All Rounder','India',16000000),
('Virat Kohli',3,'Batsman','India',17000000),
('Glenn Maxwell',3,'All Rounder','Australia',11000000),
('Andre Russell',4,'All Rounder','West Indies',12000000),
('Sunil Narine',4,'Bowler','West Indies',10000000);

INSERT INTO PointsTable(team_id)
VALUES (1),(2),(3),(4);

INSERT INTO Matches(team1_id,team2_id,venue,match_date,winner_team_id)
VALUES
(1,2,'Wankhede','2026-04-01',1),
(3,4,'Chinnaswamy','2026-04-02',3),
(1,3,'Wankhede','2026-04-03',1),
(2,4,'Chepauk','2026-04-04',2);

INSERT INTO Scorecard(match_id,player_id,runs,wickets,catches)
VALUES
(1,1,75,0,1),
(1,2,10,3,0),
(1,3,40,0,1),
(2,5,82,0,0),
(2,7,35,2,1),
(3,1,60,0,0),
(3,5,45,0,0),
(4,4,55,2,1);

UPDATE PointsTable
SET matches_played = 2
WHERE team_id IN (1,2,3,4);

UPDATE PointsTable
SET won = 2, points = 4
WHERE team_id = 1;

UPDATE PointsTable
SET won = 1, points = 2
WHERE team_id IN (2,3);

UPDATE PointsTable
SET lost = 2
WHERE team_id = 4;

UPDATE PointsTable
SET lost = 1
WHERE team_id IN (2,3);

-- ALL TEAMS
SELECT * FROM Teams;

-- ALL PLAYERS
SELECT * FROM Players;

-- MATCH SCHEDULE
SELECT * FROM Matches;

-- SCORECARD
SELECT * FROM Scorecard;

-- ORANGE CAP
SELECT p.player_name, SUM(s.runs) AS TotalRuns
FROM Scorecard s
JOIN Players p ON s.player_id = p.player_id
GROUP BY p.player_name
ORDER BY TotalRuns DESC
LIMIT 1;

-- PURPLE CAP
SELECT p.player_name, SUM(s.wickets) AS TotalWickets
FROM Scorecard s
JOIN Players p ON s.player_id = p.player_id
GROUP BY p.player_name
ORDER BY TotalWickets DESC
LIMIT 1;

-- TOP 5 RUN SCORERS
SELECT p.player_name, SUM(s.runs) AS Runs
FROM Scorecard s
JOIN Players p ON s.player_id = p.player_id
GROUP BY p.player_name
ORDER BY Runs DESC
LIMIT 5;

-- TEAM WITH MOST WINS
SELECT t.team_name, COUNT(*) AS Wins
FROM Matches m
JOIN Teams t ON m.winner_team_id = t.team_id
GROUP BY t.team_name
ORDER BY Wins DESC;

-- MOST EXPENSIVE PLAYER
SELECT player_name, price
FROM Players
ORDER BY price DESC
LIMIT 1;

-- POINTS TABLE
SELECT t.team_name, p.matches_played, p.won, p.lost, p.points
FROM PointsTable p
JOIN Teams t ON p.team_id = t.team_id
ORDER BY p.points DESC;

-- BEST ALL ROUNDER
SELECT p.player_name,
SUM(s.runs) AS Runs,
SUM(s.wickets) AS Wickets
FROM Scorecard s
JOIN Players p ON s.player_id = p.player_id
GROUP BY p.player_id, p.player_name
ORDER BY (SUM(s.runs) + SUM(s.wickets)) DESC
LIMIT 1;

-- VIEW
CREATE VIEW TopScorers AS
SELECT p.player_name, SUM(s.runs) AS TotalRuns
FROM Scorecard s
JOIN Players p ON s.player_id = p.player_id
GROUP BY p.player_name;

SELECT * FROM TopScorers;

-- STORED PROCEDURE
DELIMITER //

CREATE PROCEDURE TeamPlayers(IN tid INT)
BEGIN
SELECT player_name, role
FROM Players
WHERE team_id = tid;
END //

DELIMITER ;

CALL TeamPlayers(1);

-- WINDOW FUNCTION
SELECT player_name, total_runs,
RANK() OVER(ORDER BY total_runs DESC) AS Ranking
FROM
(
SELECT p.player_name, SUM(s.runs) AS total_runs
FROM Scorecard s
JOIN Players p ON s.player_id = p.player_id
GROUP BY p.player_name
) x;







