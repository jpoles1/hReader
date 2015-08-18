module RSS where
  import Network.HTTP
  import Data.List
  import Text.XML.Light
  import Control.Monad
  import Debug.Trace
  import qualified Data.ByteString.Lazy.Char8 as L
  -- Types containing data on individual RSS entries
  data RssEntry = RssEntry {guid :: Maybe String, title:: Maybe String, link :: Maybe String}
  instance Show RssEntry where
    show x =  "Title: " ++ (show . guid $ x) ++ "\nGUID: " ++ (show . title $ x) ++ "\nLink : " ++ (show . link $ x)
  type RssData = [RssEntry]
  -- Types containing data on RSS feeds
  type RssSources = [String]
  getStories :: IO [RssData] -> IO RssData
  getStories = liftM concat
  displayFeeds :: IO [RssData] -> IO String
  displayFeeds dat = liftM (concat . map prettyRss) dat
  -- | Takes a list of RSS.xml feeds, and outputs an array of RssData objects containing the information from each RSS.xml
  fetchFeeds :: RssSources -> IO [RssData]
  fetchFeeds srcs = sequence $ map (\src -> getRssData src >>= return . parseRssData) srcs
  getRssData :: String -> IO [Content]
  getRssData src = do
    xmldat <- simpleHTTP (getRequest src) >>= getResponseBody
    return $ parseXML xmldat
  parseRssData :: [Content] -> RssData
  parseRssData xml = map (\(guid, title, link) -> RssEntry guid title link) entrytuples
    where body = elChildren . head . elChildren . last . onlyElems $ xml
          getAttr :: String -> [Maybe String]
          getAttr attr = filter (/=Nothing) $ map ((fmap strContent) . (findChild $ items attr)) body
          items x = QName {qName = x, qURI = Nothing, qPrefix = Nothing}
          entrytuples = zip3 (getAttr "guid") (getAttr "title") (getAttr "link")
  prettyRss :: RssData -> String
  prettyRss rss = "RSS Contents" ++ div 60 ++ (concat . (intersperse $ div 15) $ map (show) rss)
    where div n = "\n\n" ++ replicate n '-' ++ "\n\n"
