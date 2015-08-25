module RSS where
  import Network.HTTP
  import Data.List
  import Text.XML.Light
  import Control.Monad
  import ReaderTypes
  import Data.Aeson
  import Data.Ord
  import qualified Data.ByteString.Lazy as B
  -- | Function will take a list of sources and output a JSON String: {Feed1: [Story1, Story2...]}
  getStoriesByFeed :: RssSources -> IO B.ByteString
  getStoriesByFeed srcs = fetchFeeds srcs >>= return . encode
  getSortedStories :: RssSources -> IO B.ByteString
  getSortedStories srcs = fetchFeeds srcs >>= return . encode
  -- | Function will take a list of sources and output a human-readable String
  sortRss :: SortFeed -> [RssData] -> IO B.ByteString
  sortRss (SortFeed sortType sortdirection) rssdata = return . encode $ sort rssdata
  --  | (sortType == ByDate) = sortBy (comparing (\S)) rssdata
  --  | otherwise = undefined
  -- | Serves a webpage containing the string
  displayFeeds :: RssSources -> IO String
  displayFeeds dat = undefined --liftM (concat . map prettyRss) dat
  -- | Function will take a list of sources and then produce a list of RssData objects containing sources and entries
  fetchFeeds :: RssSources -> IO [RssData]
  fetchFeeds srcs = sequence $ map fetchFeed srcs
  -- Function takes a single rss source and outputs an array
  fetchFeed :: String -> IO RssData
  fetchFeed src = getRssData src >>= \rawdata -> return $ RssData src $ parseRssData rawdata
  getRssData :: String -> IO [Content]
  getRssData src = do
    xmldat <- simpleHTTP (getRequest src) >>= getResponseBody
    return $ parseXML xmldat
  parseRssData :: [Content] -> [RssEntry]
  parseRssData xml = map (\(guid, title, link) -> RssEntry guid title link) entrytuples
    where body = elChildren . head . elChildren . last . onlyElems $ xml
          getAttr :: String -> [Maybe String]
          getAttr attr = filter (/=Nothing) $ map ((fmap strContent) . (findChild $ items attr)) body
          items x = QName {qName = x, qURI = Nothing, qPrefix = Nothing}
          entrytuples = zip3 (getAttr "guid") (getAttr "title") (getAttr "link")
