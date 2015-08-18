{-# LANGUAGE OverloadedStrings, TypeSynonymInstances, FlexibleInstances#-}
module Main where
  import RSS
  import Web.Spock.Safe
  import Data.Monoid
  import Network.Wai.Middleware.Static
  import qualified Data.Text as T
  rssSources = ["http://xkcd.com/rss.xml", "http://www.smbc-comics.com/rss.php"] :: RssSources
  main :: IO ()
  -- main = (fetchFeeds rssSources !! 0) >>= return . prettyRss  >>= putStrLn
  main = (displayFeeds $ fetchFeeds rssSources) >>= putStrLn >> startServer
  -- main = getRssData "http://www.smbc-comics.com/rss.php" >>= return . parseRssData >>= return . prettyRss >>= putStrLn
  type HandlerM = ActionT IO
  startServer = runSpock 8080 $ return (staticPolicy (noDots >-> addBase "static"))
  appMiddleware :: SpockT IO ()
  appMiddleware = do
    middleware $ staticPolicy (noDots >-> addBase "static")
  appRoutes :: SpockT IO ()
  appRoutes = do
    get root $ do text "gotten"
  getIndex :: HandlerM ()
  getIndex = text "Hello!" --readFile "static/index.html" >>= return . T.pack
