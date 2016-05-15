module Main where

import Database.PostgreSQL.Simple
import Control.Monad
import Control.Applicative

main = do
  conn <- connect defaultConnectInfo {
    connectDatabase = "testDB"
  }

  putStrLn "2 + 2"
  mapM_ print =<< ( query_ conn "select 2 + 2" :: IO [Only Int] )
  
LINE 1: CREATE TABLE test (id INTEGER NOT NULL, desc VARCHAR(80))
                                                ^\n"}