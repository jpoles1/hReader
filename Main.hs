{-# LANGUAGE OverloadedStrings, TypeSynonymInstances, FlexibleInstances, ScopedTypeVariables, DeriveGeneric #-}
module Main where
  import Control.Applicative ((<$>), optional)
  import Control.Concurrent
  import Data.Maybe (fromMaybe)
  import Data.Text (Text)
  import Data.Text.Lazy (unpack)
  import Happstack.Lite
  import Text.Blaze.Html5 (Html, (!), a, form, input, p, toHtml, label)
  import Text.Blaze.Html5.Attributes (action, enctype, href, name, size, type_, value)
  import qualified Text.Blaze.Html5 as H
  import qualified Text.Blaze.Html5.Attributes as A
  import JSON
  import RSS
  rssSources = ["http://xkcd.com/rss.xml", "http://www.smbc-comics.com/rss.php"] :: RssSources
  main :: IO ()
  main = do
    putStrLn "RSS Server Started"
    servtid <- forkIO startServer
    print servtid
  startServer :: IO ()
  startServer = do
    sources <- getSources "settings.json"
    rss <- displayFeeds $ fetchFeeds sources
    serve Nothing $ myApp rss
  myApp :: String -> ServerPart Response
  myApp fetchedRss = msum [dir "static" $ serveIndex, dir "fetchRSS" $ loadData fetchedRss, serveIndex]
  serveIndex :: ServerPart Response
  serveIndex = serveDirectory EnableBrowsing ["index.html"] "static"
  loadData :: String -> ServerPart Response
  loadData str = ok $ toResponse (str)
  restartServer :: ThreadId -> IO()
  restartServer tid = killThread tid
