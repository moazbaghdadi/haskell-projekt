
module DBconnection where

import Database.HDBC.PostgreSQL
import Database.HDBC
import Data.Aeson

data Table = Table {season, 
    teams :: [Team]}
    
data Team = Team { team :: String, 
    points :: Integer, 
    goaldiff :: Integer, 
    logo :: String}

data Match = Match {
    matchweek :: Integer, 
    season, 
    hometeam :: String, 
    awayteam :: String, 
    homescore :: String,
    awayscore :: String}

type season :: integer

instance FromJSON Match where
  parseJSON (Object v) =
    Match <$> v .: "matchweek"
          <*> v .: "season"
          <*> v .: "hometeam"
          <*> v .: "awayteam"
          <*> v .: "homescore"
          <*> v .: "awayscore"
  parseJSON _ = mzero

instance FromRow Team where
  fromRow = Todo <$> field <*> field <*> field

seasonQuery :: IO ()
seasonQuery = 
    do -- Connect to the database
       conn <- connectPostgreSQL' "host=localhost dbname=testDB user=postgres password=postgres"

       -- Run the query and store the results in r
       r <- quickQuery' conn
            "SELECT * from seasons"
            []

       -- Convert each row into a String
       let stringRows = map convRow r
                        
       -- Print the rows out
       mapM_ putStrLn stringRows

       -- And disconnect from the database
       disconnect conn

    where convRow :: [SqlValue] -> String
          convRow [sqlyear] = 
              "season: " ++ show year
              where year = (fromSql sqlyear)::Integer
                    {-year = case fromSql year of
                             Just x -> x
                            Nothing -> "NULL"-}
          convRow x = fail $ "Unexpected result: " ++ show x 

teamQuery :: Integer -> IO [Team]
teamQuery season = 
    do -- Connect to the database
       conn <- connectPostgreSQL' "host=localhost dbname=testDB user=postgres password=postgres"

       -- Run the query and store the results in r
       r <- quickQuery' conn
            "select t.name, p.points, p.goaldiff, t.logo from team t join points p on t.name = p.team where season = ? order by (points, goaldiff) desc"
            [toSql season]

       -- Convert each row into a String
       let stringRows = map convRow r

       -- Print the rows out
       mapM_ putStrLn [stringRows]

       -- And disconnect from the database
       disconnect conn

    where convRow :: [SqlValue] -> Team
          convRow [sqlname, sqlseason, sqlpoints, sqlgoaldiff, sqllogo] = 
              (T name (P points) (D goaldiff) (L logo))
              where points = (fromSql sqlpoints)::Integer
                    goaldiff = (fromSql sqlgoaldiff)::Integer
                    season = (fromSql sqlseason)::Integer
                    name = case fromSql sqlname of
                             Just x -> x
                             Nothing -> "NULL"
                    logo = case fromSql sqllogo of
                             Just x -> x
                             Nothing -> "NULL"

addMatch :: Match -> IO Match
addMatch (Match week season home away score1 score2) =
    do -- Connect to the database
       conn <- connectPostgreSQL' "host=localhost dbname=testDB user=postgres password=postgres"
    -- Run the query and store the results in r
       r <- quickQuery' conn
            "INSERT INTO Match VALUES (?,?,?,?,?,?);"
            [toSql week, toSql season, toSql home, toSql away, toSql score1, toSql score2]
       
       -- Convert each row into a String
       let stringRows = show r
       
       -- Print the rows out
       mapM_ putStrLn stringRows
       
       -- And disconnect from the database
       disconnect conn