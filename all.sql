DROP TABLE Match;
DROP TABLE POINTS;
DROP TABLE Team;
DROP TABLE Seasons;

CREATE TABLE Seasons (
	year INTEGER NOT NULL PRIMARY KEY
);
CREATE TABLE Team (
	name VARCHAR(80) PRIMARY KEY,
	logo VARCHAR(80) DEFAULT 'noLogo.jpg'
);
CREATE TABLE Points (
    team VARCHAR(80) REFERENCES Team(name),
    season INTEGER REFERENCES Seasons(year),
    points INTEGER DEFAULT 0,
    goalDiff INTEGER DEFAULT 0
);
CREATE TABLE Match (
	matchWeek INTEGER NOT NULL,
	season INTEGER REFERENCES Seasons(year),
	homeTeam VARCHAR(80) REFERENCES Team(name),
	awayTeam VARCHAR(80) REFERENCES Team(name),
	homeScore INTEGER NOT NULL,
	awayScore INTEGER NOT NULL,
	CHECK (awayTeam != homeTeam),

	PRIMARY KEY (matchWeek, season, homeTeam, awayTeam)
);

/* Trigger 1 */
CREATE OR REPLACE FUNCTION check_result() RETURNS TRIGGER AS $$ 
DECLARE
BEGIN
	
    UPDATE Points SET goalDiff = (goalDiff + new.homeScore - new.awayScore)
    WHERE team = new.hometeam
    AND season = new.season;

    UPDATE Points SET goalDiff = (goalDiff + new.awayScore - new.homeScore)
    WHERE team = new.awayteam
    AND season = new.season;
    
	IF new.homescore > new.awayscore THEN
		UPDATE Points SET points = points+3
		WHERE team = new.hometeam
        AND season = new.season;	
    
		RETURN new;
	END IF;

	IF new.homescore < new.awayscore THEN
		UPDATE Points SET points = points+3
		WHERE team = new.awayteam
        AND season = new.season;
        
		RETURN new;
	END IF;
    
	IF new.homescore = new.awayscore THEN
		UPDATE Points SET points = points+1
		WHERE team = new.hometeam
        AND season = new.season;
        
		UPDATE Points SET points = points+1
		WHERE team = new.awayteam
        AND season = new.season;
    
		RETURN new;
        
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_checkresult AFTER INSERT ON match
FOR EACH ROW EXECUTE PROCEDURE check_result();

BEGIN;


DELETE FROM Match;
DELETE FROM Seasons;
DELETE FROM team;

COMMIT;

INSERT INTO Seasons VALUES 
	(2015);

INSERT INTO Team (name) VALUES 
	('Real Madrid'),
	('Barcelona'),
	('Atletico Madrid'),
	('Betis'),
	('Celta Vigo'),
	('Deportivo La Coruna'),
	('Eibar'),
	('Espanyol'),
	('Getafe'),
	('Granada'),
	('Las Palmas'),
	('Levante'),
	('Malaga'),
	('Rayo Vallecano'),
	('Real Sociedad'),
	('Sevilla'),
	('Sporting de Gijon'),
	('Valencia'),
	('Villarreal'),
	('Athletic Bilbao');
	
    INSERT INTO Points (team, season) VALUES 
	('Real Madrid', 2015),
	('Barcelona', 2015),
	('Atletico Madrid', 2015),
	('Betis', 2015),
	('Celta Vigo', 2015),
	('Deportivo La Coruna', 2015),
	('Eibar', 2015),
	('Espanyol', 2015),
	('Getafe', 2015),
	('Granada', 2015),
	('Las Palmas', 2015),
	('Levante', 2015),
	('Malaga', 2015),
	('Rayo Vallecano', 2015),
	('Real Sociedad', 2015),
	('Sevilla', 2015),
	('Sporting de Gijon', 2015),
	('Valencia', 2015),
	('Villarreal', 2015),
	('Athletic Bilbao', 2015);
    
INSERT INTO Match (matchWeek, season, homeTeam, awayTeam, homeScore, awayScore) VALUES 
	(1, 2015, 'Malaga', 'Sevilla', 0, 0),
	(1, 2015, 'Espanyol', 'Getafe', 1, 0),
	(1, 2015, 'Deportivo La Coruna', 'Real Sociedad', 0, 0),
	(1, 2015, 'Atletico Madrid', 'Las Palmas', 1, 0),
	(1, 2015, 'Rayo Vallecano', 'Valencia', 0, 0),
	(1, 2015, 'Athletic Bilbao', 'Barcelona', 0, 1),
	(1, 2015, 'Sporting de Gijon', 'Real Madrid', 0, 0),
	(1, 2015, 'Levante', 'Celta Vigo', 1, 2),
	(1, 2015, 'Betis', 'Villarreal', 1, 1),
	(1, 2015, 'Granada', 'Eibar', 1, 3),
	
	(2, 2015, 'Villarreal', 'Espanyol', 3, 1),
	(2, 2015, 'Celta Vigo', 'Rayo Vallecano', 3, 0),
	(2, 2015, 'Real Sociedad', 'Sporting de Gijon', 0, 0),
	(2, 2015, 'Barcelona', 'Malaga', 1, 0),
	(2, 2015, 'Real Madrid', 'Betis', 5, 0),
	(2, 2015, 'Eibar', 'Athletic Bilbao', 2, 0),
	(2, 2015, 'Sevilla', 'Atletico Madrid', 0, 3),
	(2, 2015, 'Valencia', 'Deportivo La Coruna', 1, 1),
	(2, 2015, 'Las Palmas', 'Levante', 0, 0),
	(2, 2015, 'Getafe', 'Granada', 1, 2),
	
	(3, 2015, 'Levante', 'Sevilla', 1, 1),
	(3, 2015, 'Espanyol', 'Real Madrid', 0, 6),
	(3, 2015, 'Sporting de Gijon', 'Valencia', 0, 1),
	(3, 2015, 'Atletico Madrid', 'Barcelona', 1, 2),
	(3, 2015, 'Betis', 'Real Sociedad', 1, 0),
	(3, 2015, 'Granada', 'Villarreal', 1, 3),
	(3, 2015, 'Athletic Bilbao', 'Getafe', 3, 1),
	(3, 2015, 'Celta Vigo', 'Las Palmas', 3, 3),
	(3, 2015, 'Malaga', 'Eibar', 0, 0),
	(3, 2015, 'Rayo Vallecano', 'Deportivo La Coruna', 1, 3),
	
	(4, 2015, 'Getafe', 'Malaga', 1, 0),
	(4, 2015, 'Real Madrid', 'Granada', 1, 0),
	(4, 2015, 'Valencia', 'Betis', 0, 0),
	(4, 2015, 'Eibar', 'Atletico Madrid', 0, 2),
	(4, 2015, 'Real Sociedad', 'Espanyol', 2, 3),
	(4, 2015, 'Sevilla', 'Celta Vigo', 1, 2),
	(4, 2015, 'Deportivo La Coruna', 'Sporting de Gijon', 2, 3),
	(4, 2015, 'Villarreal', 'Athletic Bilbao', 3, 1),
	(4, 2015, 'Las Palmas', 'Rayo Vallecano', 0, 1),
	(4, 2015, 'Barcelona', 'Levante', 4, 1),
	
	(5, 2015, 'Atletico Madrid', 'Getafe', 2, 0),
	(5, 2015, 'Espanyol', 'Valencia', 1, 0),
	(5, 2015, 'Granada', 'Real Sociedad', 0, 3),
	(5, 2015, 'Celta Vigo', 'Barcelona', 4, 1),
	(5, 2015, 'Levante', 'Eibar', 2, 2),
	(5, 2015, 'Rayo Vallecano', 'Sporting de Gijon', 2, 1),
	(5, 2015, 'Athletic Bilbao', 'Real Madrid', 1, 2),
	(5, 2015, 'Las Palmas', 'Sevilla', 2, 0),
	(5, 2015, 'Malaga', 'Villarreal', 0, 1),
	(5, 2015, 'Betis', 'Deportivo La Coruna', 1, 2),
	
	(6, 2015, 'Valencia', 'Granada', 1, 0),
	(6, 2015, 'Barcelona', 'Las Palmas', 2, 1),
	(6, 2015, 'Real Madrid', 'Malaga', 0, 0),
	(6, 2015, 'Sevilla', 'Rayo Vallecano', 3, 2),
	(6, 2015, 'Villarreal', 'Atletico Madrid', 1, 0),
	(6, 2015, 'Eibar', 'Celta Vigo', 1, 1),
	(6, 2015, 'Sporting de Gijon', 'Betis', 1, 2),
	(6, 2015, 'Deportivo La Coruna', 'Espanyol', 3, 0),
	(6, 2015, 'Getafe', 'Levante', 3, 0),
	(6, 2015, 'Real Sociedad', 'Athletic Bilbao', 0, 0),
	
	(7, 2015, 'Sevilla', 'Barcelona', 2, 1),
	(7, 2015, 'Las Palmas', 'Eibar', 0, 2),
	(7, 2015, 'Celta Vigo', 'Getafe', 0, 0),
	(7, 2015, 'Levante', 'Villarreal', 1, 0),
	(7, 2015, 'Atletico Madrid', 'Real Madrid', 1, 1),
	(7, 2015, 'Malaga', 'Real Sociedad', 3, 1),
	(7, 2015, 'Athletic Bilbao', 'Valencia', 3, 1),
	(7, 2015, 'Granada', 'Deportivo La Coruna', 1, 1),
	(7, 2015, 'Espanyol', 'Sporting de Gijon', 1, 2),
	(7, 2015, 'Rayo Vallecano', 'Betis', 0, 2),
	
	(8, 2015, 'Barcelona', 'Rayo Vallecano', 5, 2),
	(8, 2015, 'Eibar', 'Sevilla', 1, 1),
	(8, 2015, 'Getafe', 'Las Palmas', 4, 0),
	(8, 2015, 'Villarreal', 'Celta Vigo', 1, 2),
	(8, 2015, 'Real Madrid', 'Levante', 3, 0),
	(8, 2015, 'Real Sociedad', 'Atletico Madrid', 0, 2),
	(8, 2015, 'Valencia', 'Malaga', 3, 0),
	(8, 2015, 'Deportivo La Coruna', 'Athletic Bilbao', 2, 2),
	(8, 2015, 'Sporting de Gijon', 'Granada', 3, 3),
	(8, 2015, 'Betis', 'Espanyol', 1, 3),
	
	(9, 2015, 'Barcelona', 'Eibar', 3, 1),
	(9, 2015, 'Sevilla', 'Getafe', 5, 0),
	(9, 2015, 'Las Palmas', 'Villarreal', 0, 0),
	(9, 2015, 'Celta Vigo', 'Real Madrid', 1, 2),
	(9, 2015, 'Levante', 'Real Sociedad', 0, 4),
	(9, 2015, 'Atletico Madrid', 'Valencia', 2, 1),
	(9, 2015, 'Malaga', 'Deportivo La Coruna', 2, 0),
	(9, 2015, 'Athletic Bilbao', 'Sporting de Gijon', 3, 0),
	(9, 2015, 'Granada', 'Betis', 1, 1),
	(9, 2015, 'Rayo Vallecano', 'Espanyol', 3, 0),
	
	(10, 2015, 'Getafe', 'Barcelona', 0, 2),
	(10, 2015, 'Eibar', 'Rayo Vallecano', 1, 0),
	(10, 2015, 'Villarreal', 'Sevilla', 2, 1),
	(10, 2015, 'Real Madrid', 'Las Palmas', 3, 1),
	(10, 2015, 'Real Sociedad', 'Celta Vigo', 2, 3),
	(10, 2015, 'Valencia', 'Levante', 3, 0),
	(10, 2015, 'Deportivo La Coruna', 'Atletico Madrid', 1, 1),
	(10, 2015, 'Sporting de Gijon', 'Malaga', 1, 0),
	(10, 2015, 'Betis', 'Athletic Bilbao', 1, 3),
	(10, 2015, 'Espanyol', 'Granada', 1, 1),
	
	(11, 2015, 'Eibar', 'Getafe', 3, 1),
	(11, 2015, 'Barcelona', 'Villarreal', 3, 0),
	(11, 2015, 'Sevilla', 'Real Madrid', 3, 2),
	(11, 2015, 'Las Palmas', 'Real Sociedad', 2, 0),
	(11, 2015, 'Celta Vigo', 'Valencia', 1, 5),
	(11, 2015, 'Levante', 'Deportivo La Coruna', 1, 1),
	(11, 2015, 'Atletico Madrid', 'Sporting de Gijon', 1, 0),
	(11, 2015, 'Malaga', 'Betis', 0, 1),
	(11, 2015, 'Athletic Bilbao', 'Espanyol', 2, 1),
	(11, 2015, 'Rayo Vallecano', 'Granada', 2, 1),
	
	(12, 2015, 'Getafe', 'Rayo Vallecano', 1, 1),
	(12, 2015, 'Villarreal', 'Eibar', 1, 1),
	(12, 2015, 'Real Madrid', 'Barcelona', 0, 4),
	(12, 2015, 'Real Sociedad', 'Sevilla', 2, 0),
	(12, 2015, 'Valencia', 'Las Palmas', 1, 1),
	(12, 2015, 'Deportivo La Coruna', 'Celta Vigo', 2, 0),
	(12, 2015, 'Sporting de Gijon', 'Levante', 0, 3),
	(12, 2015, 'Betis', 'Atletico Madrid', 0, 1),
	(12, 2015, 'Espanyol', 'Malaga', 2, 0),
	(12, 2015, 'Granada', 'Athletic Bilbao', 2, 0),
	
	(13, 2015, 'Las Palmas', 'Deportivo La Coruna', 0, 2),
	(13, 2015, 'Celta Vigo', 'Sporting de Gijon', 2, 1),
	(13, 2015, 'Levante', 'Betis', 0, 1),
	(13, 2015, 'Atletico Madrid', 'Espanyol', 1, 0),
	(13, 2015, 'Malaga', 'Granada', 2, 2),
	(13, 2015, 'Rayo Vallecano', 'Athletic Bilbao', 0, 3),
	(13, 2015, 'Getafe', 'Villarreal', 2, 0),
	(13, 2015, 'Eibar', 'Real Madrid', 0, 2),
	(13, 2015, 'Barcelona', 'Real Sociedad', 4, 0),
	(13, 2015, 'Sevilla', 'Valencia', 1, 0),
	
	(14, 2015, 'Villarreal', 'Rayo Vallecano', 2, 1),
	(14, 2015, 'Real Madrid', 'Getafe', 4, 1),
	(14, 2015, 'Real Sociedad', 'Eibar', 2, 1),
	(14, 2015, 'Valencia', 'Barcelona', 1, 1),
	(14, 2015, 'Deportivo La Coruna', 'Sevilla', 1, 1),
	(14, 2015, 'Sporting de Gijon', 'Las Palmas', 3, 1),
	(14, 2015, 'Betis', 'Celta Vigo', 1, 1),
	(14, 2015, 'Espanyol', 'Levante', 1, 1),
	(14, 2015, 'Granada', 'Atletico Madrid', 0, 2),
	(14, 2015, 'Athletic Bilbao', 'Malaga', 0, 0),
	
	(15, 2015, 'Villarreal', 'Real Madrid', 1, 0),
	(15, 2015, 'Getafe', 'Real Sociedad', 1, 1),
	(15, 2015, 'Eibar', 'Valencia', 1, 1),
	(15, 2015, 'Barcelona', 'Deportivo La Coruna', 2, 2),
	(15, 2015, 'Sevilla', 'Sporting de Gijon', 2, 0),
	(15, 2015, 'Las Palmas', 'Betis', 1, 0),
	(15, 2015, 'Celta Vigo', 'Espanyol', 1, 0),
	(15, 2015, 'Levante', 'Granada', 1, 2),
	(15, 2015, 'Atletico Madrid', 'Athletic Bilbao', 2, 1),
	(15, 2015, 'Rayo Vallecano', 'Malaga', 1, 2),
	
	(16, 2015, 'Real Madrid', 'Rayo Vallecano', 10, 2),
	(16, 2015, 'Real Sociedad', 'Villarreal', 0, 2),
	(16, 2015, 'Valencia', 'Getafe', 2, 2),
	(16, 2015, 'Deportivo La Coruna', 'Eibar', 2, 0),
	(16, 2015, 'Sporting de Gijon', 'Barcelona', 1, 3),
	(16, 2015, 'Betis', 'Sevilla', 0, 0),
	(16, 2015, 'Espanyol', 'Las Palmas', 1, 0),
	(16, 2015, 'Granada', 'Celta Vigo', 0, 2),
	(16, 2015, 'Athletic Bilbao', 'Levante', 2, 0),
	(16, 2015, 'Malaga', 'Atletico Madrid', 1, 0),
	
	(17, 2015, 'Real Madrid', 'Real Sociedad', 3, 1),
	(17, 2015, 'Villarreal', 'Valencia', 1, 0),
	(17, 2015, 'Getafe', 'Deportivo La Coruna', 0, 0),
	(17, 2015, 'Eibar', 'Sporting de Gijon', 2, 0),
	(17, 2015, 'Barcelona', 'Betis', 4, 0),
	(17, 2015, 'Sevilla', 'Espanyol', 2, 0),
	(17, 2015, 'Las Palmas', 'Granada', 4, 1),
	(17, 2015, 'Celta Vigo', 'Athletic Bilbao', 0, 1),
	(17, 2015, 'Levante', 'Malaga', 0, 1),
	(17, 2015, 'Rayo Vallecano', 'Atletico Madrid', 0, 2),
	
	(18, 2015, 'Rayo Vallecano', 'Real Sociedad', 2, 2),
	(18, 2015, 'Valencia', 'Real Madrid', 2, 2),
	(18, 2015, 'Deportivo La Coruna', 'Villarreal', 1, 2),
	(18, 2015, 'Sporting de Gijon', 'Getafe', 1, 2),
	(18, 2015, 'Betis', 'Eibar', 0, 4),
	(18, 2015, 'Espanyol', 'Barcelona', 0, 0),
	(18, 2015, 'Granada', 'Sevilla', 2, 1),
	(18, 2015, 'Athletic Bilbao', 'Las Palmas', 2, 2),
	(18, 2015, 'Malaga', 'Celta Vigo', 2, 0),
	(18, 2015, 'Atletico Madrid', 'Levante', 1, 0),
	
	(19, 2015, 'Real Sociedad', 'Valencia', 2, 0),
	(19, 2015, 'Real Madrid', 'Deportivo La Coruna', 5, 0),
	(19, 2015, 'Villarreal', 'Sporting de Gijon', 2, 0),
	(19, 2015, 'Getafe', 'Betis', 1, 0),
	(19, 2015, 'Eibar', 'Espanyol', 2, 1),
	(19, 2015, 'Barcelona', 'Granada', 4, 0),
	(19, 2015, 'Sevilla', 'Athletic Bilbao', 2, 0),
	(19, 2015, 'Las Palmas', 'Malaga', 1, 1),
	(19, 2015, 'Celta Vigo', 'Atletico Madrid', 0, 2),
	(19, 2015, 'Levante', 'Rayo Vallecano', 2, 1),
	
	(20, 2015, 'Sevilla', 'Malaga', 2, 1),
	(20, 2015, 'Celta Vigo', 'Levante', 4, 3),
	(20, 2015, 'Villarreal', 'Betis', 0, 0),
	(20, 2015, 'Real Sociedad', 'Deportivo La Coruna', 1, 1),
	(20, 2015, 'Valencia', 'Rayo Vallecano', 2, 2),
	(20, 2015, 'Real Madrid', 'Sporting de Gijon', 5, 1),
	(20, 2015, 'Getafe', 'Espanyol', 3, 1),
	(20, 2015, 'Las Palmas', 'Atletico Madrid', 0, 3),
	(20, 2015, 'Barcelona', 'Athletic Bilbao', 6, 0),
	(20, 2015, 'Eibar', 'Granada', 5, 1),
	
	(21, 2015, 'Sporting de Gijon', 'Real Sociedad', 5, 1),
	(21, 2015, 'Malaga', 'Barcelona', 1, 2),
	(21, 2015, 'Espanyol', 'Villarreal', 2, 2),
	(21, 2015, 'Granada', 'Getafe', 3, 2),
	(21, 2015, 'Rayo Vallecano', 'Celta Vigo', 3, 0),
	(21, 2015, 'Athletic Bilbao', 'Eibar', 5, 2),
	(21, 2015, 'Atletico Madrid', 'Sevilla', 0, 0),
	(21, 2015, 'Deportivo La Coruna', 'Valencia', 1, 1),
	(21, 2015, 'Betis', 'Real Madrid', 1, 1),
	(21, 2015, 'Levante', 'Las Palmas', 3, 2),
	
	(22, 2015, 'Barcelona', 'Atletico Madrid', 2, 1),
	(22, 2015, 'Getafe', 'Athletic Bilbao', 0, 1),
	(22, 2015, 'Eibar', 'Malaga', 1, 2),
	(22, 2015, 'Villarreal', 'Granada', 1, 0),
	(22, 2015, 'Real Sociedad', 'Betis', 2, 1),
	(22, 2015, 'Sevilla', 'Levante', 3, 1),
	(22, 2015, 'Valencia', 'Sporting de Gijon', 0, 1),
	(22, 2015, 'Las Palmas', 'Celta Vigo', 2, 1),
	(22, 2015, 'Real Madrid', 'Espanyol', 6, 0),
	(22, 2015, 'Deportivo La Coruna', 'Rayo Vallecano', 0, 0),
	
	(23, 2015, 'Malaga', 'Getafe', 3, 0),
	(23, 2015, 'Atletico Madrid', 'Eibar', 3, 1),
	(23, 2015, 'Rayo Vallecano', 'Las Palmas', 2, 0),
	(23, 2015, 'Athletic Bilbao', 'Villarreal', 0, 0),
	(23, 2015, 'Sporting de Gijon', 'Deportivo La Coruna', 1, 1),
	(23, 2015, 'Levante', 'Barcelona', 0, 2),
	(23, 2015, 'Betis', 'Valencia', 1, 0),
	(23, 2015, 'Celta Vigo', 'Sevilla', 1, 1),
	(23, 2015, 'Granada', 'Real Madrid', 1, 2),
	(23, 2015, 'Espanyol', 'Real Sociedad', 0, 5),
	
	(24, 2015, 'Sporting de Gijon', 'Rayo Vallecano', 2, 2),
	(24, 2015, 'Real Madrid', 'Athletic Bilbao', 4, 2),
	(24, 2015, 'Villarreal', 'Malaga', 1, 0),
	(24, 2015, 'Valencia', 'Espanyol', 2, 1),
	(24, 2015, 'Deportivo La Coruna', 'Betis', 2, 2),
	(24, 2015, 'Real Sociedad', 'Granada', 3, 0),
	(24, 2015, 'Sevilla', 'Las Palmas', 2, 0),
	(24, 2015, 'Getafe', 'Atletico Madrid', 0, 1),
	(24, 2015, 'Eibar', 'Levante', 2, 0),
	(24, 2015, 'Barcelona', 'Celta Vigo', 6, 1),
	
	(25, 2015, 'Levante', 'Getafe', 3, 0),
	(25, 2015, 'Las Palmas', 'Barcelona', 1, 2),
	(25, 2015, 'Espanyol', 'Deportivo La Coruna', 1, 0),
	(25, 2015, 'Betis', 'Sporting de Gijon', 1, 1),
	(25, 2015, 'Celta Vigo', 'Eibar', 3, 2),
	(25, 2015, 'Rayo Vallecano', 'Sevilla', 2, 2),
	(25, 2015, 'Malaga', 'Real Madrid', 1, 1),
	(25, 2015, 'Athletic Bilbao', 'Real Sociedad', 0, 1),
	(25, 2015, 'Granada', 'Valencia', 1, 2),
	(25, 2015, 'Atletico Madrid', 'Villarreal', 0, 0);