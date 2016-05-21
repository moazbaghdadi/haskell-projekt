/* Trigger 1 */
CREATE OR REPLACE FUNCTION check_result() RETURNS TRIGGER AS $$ 
DECLARE
BEGIN
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