{-# LANGUAGE OverloadedStrings #-}
module Main where

---local imports---
import DBconnection
import Utils
-------------------

import Snap.Core
import Snap.Util.FileServe
import Snap.Http.Server
import Data.Aeson
import Control.Monad.IO.Class
   
--------------------------------------------------------------
----------------         Web Server        -------------------
--------------------------------------------------------------
   
main :: IO ()
main = quickHttpServe site

site :: Snap ()
site =
    route [ ("/", serveDirectory "views")
          , ("/getTable", loadTable)
          , ("/getTeams", loadTeams)
          , ("/getAllMatches", loadAllMatches)
          , ("/getMatch", loadMatch)
          , ("/postMatch", postmatch)
          , ("/getChances", chances)
          ]
          
--------------------------------------------------------------
---------------         GET Methods        -------------------
--------------------------------------------------------------
          
loadTable :: Snap ()
loadTable =  do
    result <- liftIO $ teamQuery 2015
    method GET $ writeJSON Table {season1 = 2015 , teams = result }

loadTeams :: Snap ()
loadTeams =  do
    result <- liftIO $ teamQueryUnorderd
    method GET $ writeJSON result

loadAllMatches :: Snap ()
loadAllMatches =  do
    season <- getParam "season"
    result <- liftIO $ (allMatchesQuery . bsToInteger) season
    method GET $ writeJSON result
    
loadMatch :: Snap ()
loadMatch =  do
    season <- getParam "season"
    team <- getParam "team"
    result <- liftIO $ matchQuery (bsToInteger season) (bsToString team)
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
    method GET $ loadTable

chances :: Snap ()
chances = do
    season <- getParam "season"
    result <- liftIO $ (getChances . bsToInteger) season
    method GET $ writeJSON result
