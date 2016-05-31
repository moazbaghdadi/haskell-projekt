{-# LANGUAGE OverloadedStrings #-}
module Main where

import           DBconnection
import           Control.Applicative
import           System.IO.Unsafe
import           Snap.Core
import           Snap.Util.FileServe
import           Snap.Http.Server
import           Data.Aeson
import           Data.ByteString.Char8
import           Control.Monad.IO.Class


instance ToJSON Table where
    toJSON (Table season teams) = object ["season" .= season, "teams" .= toJSON teams]

instance ToJSON Team where
    toJSON (Team team points goaldiff logo) = object ["team" .= team, "points" .= points, "goaldiff" .= goaldiff, "logo" .= logo]

instance ToJSON TeamName where
    toJSON (TeamName teamname) = object ["teamname" .= teamname]

main :: IO ()
main = quickHttpServe site

site :: Snap ()
site =
    route [ ("/", serveDirectory "views")
          , ("/getTable", loadTable)
          , ("/getTeams", loadTeams)
          , ("/postmatch", postmatch)
          ]
          
loadTable :: Snap ()
loadTable =  do
    result <- liftIO $ teamQuery 2015
    method GET $ writeJSON Table {season1 = 2015 , teams = result }

loadTeams :: Snap ()
loadTeams =  do
    result <- liftIO $ teamQueryUnorderd
    method GET $ writeJSON result

postmatch :: Snap ()
postmatch = do
    wk <- getParam "matchweek"
    season <- getParam "season"
    hteam <- getParam "hometeam"
    ateam <- getParam "awayteam"
    hscore <- getParam "homescore"
    ascore <- getParam "awayscore"
    x <- liftIO $ addMatch (Match (bsToInteger wk) (bsToInteger season) (bsToString hteam) (bsToString ateam) (bsToInteger hscore) (bsToInteger ascore) )
    method POST $ loadTable
          

bsToInteger :: Maybe ByteString -> Integer
bsToInteger bs = maybe (0 :: Integer) (read . unpack) bs

bsToString :: Maybe ByteString -> String
bsToString bs = maybe ("" :: String) (unpack) bs

-- | Mark response as 'application/json'
jsonResponse :: MonadSnap m => m ()
jsonResponse = modifyResponse $ setHeader "Content-Type" "application/json"

writeJSON :: (MonadSnap m, ToJSON a) => a -> m ()
writeJSON a = do
  jsonResponse
  writeLBS . encode $ a