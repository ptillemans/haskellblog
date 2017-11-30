{-# LANGUAGE RankNTypes #-}
module Main
  where

import qualified Data.Conduit.List as CL
import qualified Data.Conduit.Binary as CB
import Control.Monad.State
import Control.Monad.Trans.Resource
import Data.ByteString.Char8 (ByteString, empty, pack, unpack)
import Data.Conduit
import System.IO (stdin)

wordsSource :: Monad m => String -> Producer m [String]
wordsSource = yield . words  -- yield simply pushes its argument down the conduit chain to the next Conduit

identitySink :: Monad m => ConduitM [a] o m [a]
identitySink = CL.foldMap id  -- Simply returns the input 'as is' as output

numLettersConduit :: Monad m => Conduit [String] m [Int]
numLettersConduit = CL.map (map length)  -- Transforms each String input by counting the number of characters

showConduit :: Monad m => Conduit [Int] m [String]
showConduit = CL.map (map show)  -- S

main = do
  let input = "The quick brown fox jumped over the lazy dog"
  xs <- wordsSource input
     $= numLettersConduit  -- Plug it in to the middle of the conduit stack
     $= showConduit -- turn int back to string
     $$ identitySink
  mapM_ (putStrLn . show) xs
