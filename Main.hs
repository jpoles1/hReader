{-# LANGUAGE TypeSynonymInstances, FlexibleInstances, ScopedTypeVariables, DeriveGeneric #-}
module Main where
  import Control.Applicative ((<$>), optional)
  import Control.Concurrent
  import Control.Monad.IO.Class
  import Control.Monad (msum)
  import Data.Maybe (fromMaybe)
  import Data.Text (Text)
  import Data.Text.Lazy (unpack)
  import Happstack.Server
  import JSON
  import RSS
  import ReaderTypes
  main :: IO ()
  main = do
    putStrLn "RSS Server Started" >> startServer
  serverConfig :: Conf
  serverConfig = Conf {port = 8000, validator = Nothing, logAccess = Just logMAccess, timeout = 30, threadGroup = Nothing}
  startServer :: IO ()
  startServer = simpleHTTP serverConfig $ myApp
  myApp :: ServerPartT IO Response
  myApp = msum [dir "static" $ serveIndex, dir "fetchRSS" $ path serveSortedRss, dir "fetchRSS" $ serveRss, serveIndex]
  serveIndex :: ServerPartT IO Response
  serveIndex = serveDirectory EnableBrowsing ["index.html"] "static"
  serveRss :: ServerPartT IO Response
  serveRss = do
    sources <- liftIO $ getSources "settings.json"
    feed <- liftIO $ getStoriesByFeed sources
    ok $ Response {rsCode=200, rsFlags=nullRsFlags, rsBody = feed, rsValidator = Nothing, rsHeaders=(mkHeaders [("Content-Type","text/JSON")])}
  serveSortedRss :: String -> ServerPartT IO Response
  serveSortedRss sorttype = do
    sources <- liftIO $ getSources "settings.json"
    feed <- liftIO (fetchFeeds sources >>= (sortRss $ SortFeed ByTitle Ascend))
    ok $ Response {rsCode=200, rsFlags=nullRsFlags, rsBody = feed, rsValidator = Nothing, rsHeaders=(mkHeaders [("Content-Type","text/JSON")])}
  serveString :: String -> ServerPart Response
  serveString str = ok $ toResponse (str)
