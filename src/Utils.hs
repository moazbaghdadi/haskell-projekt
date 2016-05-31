{-# LANGUAGE OverloadedStrings #-}

module Utils where

import Data.Aeson
import Database.PostgreSQL.Simple.FromRow
import Data.ByteString.Char8
import Snap.Core

--------------------------------------------------------------
-------------         Data Structures        -----------------
--------------------------------------------------------------

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

--------------------------------------------------------------
----------------         Instances        --------------------
--------------------------------------------------------------
    
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

instance FromRow Match where
  fromRow = Match <$> field <*> field <*> field <*> field <*> field <*> field

instance ToJSON Table where
    toJSON (Table season teams) = object ["season" .= season, "teams" .= toJSON teams]

instance ToJSON Team where
    toJSON (Team team points goaldiff logo) = object ["team" .= team, "points" .= points, "goaldiff" .= goaldiff, "logo" .= logo]

instance ToJSON TeamName where
    toJSON (TeamName teamname) = object ["teamname" .= teamname]

instance ToJSON Match where
    toJSON (Match matchweek season2 hometeam awayteam homescore awayscore) = object ["matchweek" .= matchweek, "hometeam" .= hometeam, "awayteam" .= awayteam, "homescore" .= homescore, "awayscore" .= awayscore]

--------------------------------------------------------------
----------         ByteString Converters        --------------
--------------------------------------------------------------

bsToInteger :: Maybe ByteString -> Integer
bsToInteger bs = maybe (0 :: Integer) (read . unpack) bs

bsToString :: Maybe ByteString -> String
bsToString bs = maybe ("" :: String) (unpack) bs
    
--------------------------------------------------------------
------------         Copied Functions         ----------------
--------------------------------------------------------------

jsonResponse :: MonadSnap m => m ()
jsonResponse = modifyResponse $ setHeader "Content-Type" "application/json"

writeJSON :: (MonadSnap m, ToJSON a) => a -> m ()
writeJSON a = do
  jsonResponse
  writeLBS . encode $ a