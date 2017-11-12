import Data.Conduit
import Control.Monad.State

sumSink :: Monad m => Sink Int (StateT Int m) Int
sumSink = do
    awaitForever $ modify . (+)
    get

accumConduit :: Monad m => Conduit Int (StateT Int m) Int
accumConduit = awaitForever $ \i -> do
    total <- get
    let total' = total + i
    yield total'
    put total'

main :: IO ()
main = evalStateT (mapM_ yield [1..10] $$ accumConduit =$ sumSink) 0 >>= print
