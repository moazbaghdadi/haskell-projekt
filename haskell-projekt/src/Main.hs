{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Control.Applicative
import           System.IO.Unsafe
import           Snap.Core
import           Snap.Util.FileServe
import           Snap.Http.Server
import           Data.Aeson
import           DBconnection

instance ToJSON Table where
    toJSON (Table season teams) = object ["season" .= season, "teams" .= toJSON teams]

instance ToJSON Team where
    toJSON (Team team points goaldiff logo) = object ["team" .= team, "points" .= points, "goaldiff" .= goaldiff, "logo" .= logo]

main :: IO ()
main = quickHttpServe site

site :: Snap ()
site =
    route [ ("/", serveDirectory "views")
          , ("echo/:echoparam", echoHandler)
          , ("/getTable", loadTable)
          ]

          
loadTable :: Snap ()
loadTable =  do
    method GET (writeJSON (Table {season1 = 2015 , teams = unsafePerformIO (teamQuery 2015) })) -- wie kann man es besser machen?

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