CREATE TABLE Seasons (
	year INTEGER NOT NULL PRIMARY KEY
);
CREATE TABLE Team (
	name VARCHAR(80) PRIMARY KEY,
	points INTEGER DEFAULT 0,
	logo VARCHAR(80) DEFAULT 'noLogo.jpg'
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