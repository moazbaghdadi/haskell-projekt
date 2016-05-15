CREATE TABLE Seasons (
	year INTEGER NOT NULL PRIMARY KEY
);
CREATE TABLE Team (
	name VARCHAR(80) PRIMARY KEY,
	points INTEGER DEFAULT 0,
	logo VARCHAR(80) DEFAULT 'noLogo.jpg'
);
CREATE TABLE Player (
	playerNr INTEGER NOT NULL,
	team VARCHAR(80) REFERENCES team(name),
	name VARCHAR(80) NOT NULL,
	goals INTEGER DEFAULT 0,
	assists INTEGER DEFAULT 0,
	photo VARCHAR(80) DEFAULT 'noPicture.jpg',

	PRIMARY KEY(playerNr, team)
);
CREATE TABLE Match (
	matchWeek INTEGER NOT NULL,
	season INTEGER REFERENCES Seasons(year),
	homeTeam VARCHAR(80) REFERENCES Team(name),
	awayTeam VARCHAR(80) REFERENCES Team(name),
	CHECK (awayTeam != homeTeam),

	PRIMARY KEY (matchWeek, season, homeTeam, awayTeam)
);