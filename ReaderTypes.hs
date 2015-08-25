{-# LANGUAGE DeriveGeneric #-}
module ReaderTypes where
  import Data.Aeson
  import GHC.Generics
  -- Type defining the configuration file layout (for JSON)
  data Configuration = Configuration {debug :: Bool, sources :: [String]} deriving (Show, Generic)
  instance FromJSON Configuration
  instance ToJSON Configuration
  -- Type defining the rss JSON layout and the data on individual RSS entries
  data RssEntry = RssEntry {guid :: Maybe String, title:: Maybe String, link :: Maybe String} deriving (Eq, Ord, Generic)
  instance FromJSON RssEntry
  instance ToJSON RssEntry
  instance Show RssEntry where
    show x =  "Title: " ++ (show . title $ x) ++ "\nGUID: " ++ (show . guid $ x) ++ "\nLink : " ++ (show . link $ x)
  data RssData = RssData {feedName :: String, feedEntries :: [RssEntry]} deriving (Eq, Ord, Generic)
  instance FromJSON RssData
  instance ToJSON RssData
  data RssList = RssList [RssData] deriving (Generic)
  instance FromJSON RssList
  instance ToJSON RssList
  -- Types containing data on RSS feeds
  type RssSources = [String]
  -- Type defining how the feed is sorted
  data SortType = ByDate | ByTitle | BySource deriving (Eq, Show, Read)
  data SortDirection = Ascend | Descend deriving (Eq, Show, Read)
  data SortFeed = SortFeed {sortType :: SortType, sortDirection :: SortDirection} deriving (Eq, Show, Read)
