{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}

import qualified Database.MongoDB as MDB
import qualified Database.MongoDB.GridFS as GFS
import Control.Monad.Trans (MonadIO, liftIO, lift)

import Conduit
import Data.Text (Text, pack, unpack)
import Data.ByteString (ByteString)
import System.IO as IO
import Debug.Trace (trace)


main :: IO ()
main = uploadFileFS "sandbox/bat.jpg"

runMongo :: MDB.Action IO a -> IO ()
runMongo f = do
   pipe <- MDB.connect (MDB.host "127.0.0.1")
   _ <- MDB.access pipe MDB.master "baseball" f
   liftIO $ putStr("uploaded, closing pipe")
   MDB.close pipe


uploadFileFS :: String -> IO ()
uploadFileFS src = do
  withBinaryFile src ReadMode $ \h -> runMongo $ do
    bucket <- trace "getting default bucket\n" $ GFS.openDefaultBucket
    liftIO $ putStr("uploading file\n")
    _ <- runConduit $ (trace "sourceHandle\n" $ sourceHandle h) .| (trace "sinkfile\n" $ GFS.sinkFile bucket (pack src))
    liftIO $ putStr("done uploading\n")
