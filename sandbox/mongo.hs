{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}

import qualified Database.MongoDB as MDB
import qualified Database.MongoDB.GridFS as GFS
import Control.Monad.Trans (MonadIO, liftIO, lift)

import Conduit
import Data.Text (Text, unpack)
import Data.ByteString (ByteString)
import System.IO as IO


main :: IO ()
main = do
   pipe <- MDB.connect (MDB.host "127.0.0.1")
   _ <- MDB.access pipe MDB.master "baseball" run
   MDB.close pipe

run :: MDB.Action IO GFS.File
run = do
  bucket <- lift $ GFS.openDefaultBucket
  uploadFileFS "sandbox/bat.jpg" bucket


data Hole = Hole
hole :: Hole
hole = Hole


uploadFileFS :: (MonadIO m) => Text -> GFS.Bucket -> IO (MDB.Action m GFS.File)
uploadFileFS src bucket = do
  withBinaryFile (unpack src) ReadMode $ \h ->
    return (runConduit $ sourceHandle h .| GFS.sinkFile bucket src)
