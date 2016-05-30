{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Control.Applicative
import           System.IO.Unsafe
import           Snap.Core
import           Snap.Util.FileServe
import           Snap.Http.Server
import           Data.Aeson
import           DBconnection
import           Data.Int (Int64)
import           Data.ByteString.Char8


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
          , ("echo/:echoparam", echoHandler)
          , ("/getTable", loadTable)
          , ("/getTeams", loadTeams)
          --, ("/postmatch?:season", postmatch)
          ]

          
loadTable :: Snap ()
loadTable =  do
    method GET (writeJSON (Table {season1 = 2015 , teams = unsafePerformIO (teamQuery 2015) })) -- wie kann man es besser machen?

loadTeams :: Snap ()
loadTeams =  do
    method GET (writeJSON (unsafePerformIO (teamQueryUnorderd))) -- wie kann man es besser machen?
    
--createTodo :: Snap ()
--createTodo = do
--    wk <- getPostParam "matchweek"
--    s <- getPostParam "season"
--    hteam <- getPostParam "hometeam"
--    ateam <- getPostParam "awayteam"
--    hscore <- getPostParam "homescore"
--    ascore <- getPostParam "awayscore"
--    writeJSON (unsafePerformIO (addMatch (Match (runGet getWord32be bytes wk) s hteam ateam hscore ascore)))
--    modifyResponse $ setResponseCode 201

{--postmatch :: Snap ()
postmatch = do
    wk <- getParams
    s <- getParam "season"
    hteam <- getParam "hometeam"
    ateam <- getParam "awayteam"
    hscore <- getParam "homescore"
    ascore <- getParam "awayscore"
    maybe (writeBS "must specify echo/param in URL")
          writeBS wk
    --writeJSON (unsafePerformIO (addMatch (Match (getParam "matchweek") (getParam "season") (unpack maybe (getParam "hometeam")) (unpack . getParam "awayteam") (getParam "homescore") (getParam "awayscore") ))) -- wie kann man es besser machen?
 --}       
echoHandler :: Snap ()
echoHandler = do
    param <- getParam "echoparam"
    maybe (writeBS "must specify echo/param in URL")
          writeBS param

-- | Mark response as 'application/json'
jsonResponse :: MonadSnap m => m ()
jsonResponse = modifyResponse $ setHeader "Content-Type" "application/json"

writeJSON :: (MonadSnap m, ToJSON a) => a -> m ()
writeJSON a = do
  jsonResponse
  writeLBS . encode $ a

-------------------------------------------------------------------------------
-- | Try to parse request body as JSON with a default max size of
-- 50000.
getJSON :: (MonadSnap m, FromJSON a) => m (Either String a)
getJSON = getBoundedJSON 50000


-------------------------------------------------------------------------------
-- | Parse request body into JSON or return an error string.
getBoundedJSON 
    :: (MonadSnap m, FromJSON a) 
    => Int64 
    -- ^ Maximum size in bytes
    -> m (Either String a)
getBoundedJSON n = do
  bodyVal <- decode `fmap` readRequestBody n
  return $ case bodyVal of
    Nothing -> Left "Can't find JSON data in POST body"
    Just v -> case fromJSON v of
                Error e -> Left e
                Success a -> Right a

