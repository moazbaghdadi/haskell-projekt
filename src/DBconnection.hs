{-# LANGUAGE OverloadedStrings #-}
module DBconnection where

--local imports--
import Utils
-----------------

import Database.PostgreSQL.Simple
import Data.Int (Int64)

--------------------------------------------------------------
-----------------         Queries        ---------------------
--------------------------------------------------------------

-- Connection to the database
conn :: IO Connection
conn = connectPostgreSQL "host=localhost dbname=testDB user=postgres password=postgres"

seasonQuery :: IO [Integer]
seasonQuery = do
    connection <- conn
    query connection "SELECT * from seasons" ()

teamQuery :: Integer -> IO [Team]
teamQuery season = do 
    connection <- conn
    query connection  "select t.name, p.points, p.goaldiff, t.logo from team t join points p on t.name = p.team where season = ? order by (points, goaldiff) desc" (Only season)

teamQueryUnorderd :: IO [TeamName]
teamQueryUnorderd = do 
    connection <- conn
    query connection "select t.name from team t" ()
 
getChances :: Integer -> IO [TeamName]
getChances season = do 
    connection <- conn
    query connection "select t.name from team t join (select x2.team,x2.points+x1.maximum as maxpoints from (select (38-max(m.matchweek))*3 as maximum from match m where season = ?) x1, (select p.team,p.points from team t join points p on t.name = p.team where season = ? ) x2) m on t.name = m.team  where m.maxpoints >= (select max(p.points) from points p where season = ?) order by m.maxpoints desc" (season, season, season)

allMatchesQuery :: Integer -> IO [Match]
allMatchesQuery season = do 
    connection <- conn
    query connection "select matchweek, season, hometeam, awayteam, homescore, awayscore from match where season = ?" (Only season)
       
matchQuery :: Integer -> String -> IO [Match]
matchQuery season team = do
    connection <- conn
    query connection "select matchweek, season, hometeam, awayteam, homescore, awayscore from match where season = ? and (hometeam = ? or awayteam = ?)" (season, team, team)

addMatch :: Match -> IO (Int64)
addMatch (Match week season home away score1 score2) = do
    connection <- conn
    execute connection "INSERT INTO Match VALUES (?,?,?,?,?,?);" (week, season, home, away, score1, score2)