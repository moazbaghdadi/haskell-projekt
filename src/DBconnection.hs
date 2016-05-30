{-# LANGUAGE OverloadedStrings #-}
module DBconnection where

import Database.PostgreSQL.Simple.FromRow
import Database.PostgreSQL.Simple
--import Database.HDBC.PostgreSQL
--import Database.HDBC
import Data.Int (Int64)
import Data.Aeson

data Table = Table {season1 :: Integer, 
    teams :: [Team]}
    
data Team = Team { team :: String, 
    points :: Integer, 
    goaldiff :: Integer, 
    logo :: String} deriving (Show)

data Match = Match {
    matchweek :: Integer, 
    season2 :: Integer,
    hometeam :: String, 
    awayteam :: String, 
    homescore :: Integer,
    awayscore :: Integer}

data TeamName = TeamName {teamname :: String} deriving (Show)
    
instance FromJSON Match where
  parseJSON (Object v) =
    Match <$> v .: "matchweek"
          <*> v .: "season2"
          <*> v .: "hometeam"
          <*> v .: "awayteam"
          <*> v .: "homescore"
          <*> v .: "awayscore"
  parseJSON _ = fail "error at converting JSON"

instance FromRow Team where
  fromRow = Team <$> field <*> field <*> field <*> field
  
instance FromRow Integer where
  fromRow = field

instance FromRow TeamName where
  fromRow = TeamName <$> field
  
seasonQuery :: IO [Integer]
seasonQuery = 
    do -- Connect to the database
       conn <- connectPostgreSQL "host=localhost dbname=testDB user=postgres password=postgres"

       -- Run the query
       query conn "SELECT * from seasons" ()


teamQuery :: Integer -> IO [Team]
teamQuery season = 
    do -- Connect to the database
       conn <- connectPostgreSQL "host=localhost dbname=testDB user=postgres password=postgres"

       -- Run the query
       query conn  "select t.name, p.points, p.goaldiff, t.logo from team t join points p on t.name = p.team where season = ? order by (points, goaldiff) desc" (Only season)

teamQueryUnorderd :: IO [TeamName]
teamQueryUnorderd = 
    do -- Connect to the database
       conn <- connectPostgreSQL "host=localhost dbname=testDB user=postgres password=postgres"

       -- Run the query
       query conn  "select t.name from team t" ()
       
addMatch :: Match -> IO (Int64)
addMatch (Match week season home away score1 score2) =
    do -- Connect to the database
       conn <- connectPostgreSQL "host=localhost dbname=testDB user=postgres password=postgres"
       
       -- Run the query
       execute conn "INSERT INTO Match VALUES (?,?,?,?,?,?) returning matchweek;" (week, season, home, away, score1, score2)