
module Main where

import Database.HDBC.PostgreSQL
import Database.HDBC

data Table = Table Season [Team]

data Season = S Integer
data Team = T String Points Goaldiff Logo
data Points = P Integer
data Goaldiff = D Integer
data Logo = L String

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

teamQuery :: Integer -> IO ()
teamQuery season = 
    do -- Connect to the database
       conn <- connectPostgreSQL' "host=localhost dbname=testDB user=postgres password=postgres"

       -- Run the query and store the results in r
       r <- quickQuery' conn
            "select t.name, p.season, p.points, p.goaldiff, t.logo from team t join points p on t.name = p.team where season = ? order by (points, goaldiff) desc"
            [toSql season]

       -- Convert each row into a String
       let stringRows = teamsToJSON $ map convRow r
                        
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

tableToJSON :: Table -> String
tableToJSON (Table se teams) = "{\"season\" : \"" ++ x se ++ "\", \"table\" : [" ++ teamsToJSON teams ++ "] }"
    where x (S se)= show se

teamsToJSON :: [Team] -> String
teamsToJSON [] = ""
teamsToJSON ((T t p d l):ts) = "{ \"team\" : \"" ++ t ++ "\", \"points\" : \"" ++ getPoints p ++ "\", \"goaldiff\" : \"" ++ 
                             getGoaldiff d ++ "\", \"logo\" : \"" ++ getLogo l ++ "\"}" ++ comma ++ teamsToJSON ts
    where
        getPoints (P x) = show x
        getGoaldiff (D x) = show x
        getLogo (L x) = x
        comma = case ts of
            []     -> ""
            otherwise -> ", "