{-# LANGUAGE OverloadedStrings, TypeSynonymInstances, FlexibleInstances#-}
module Main where
  import RSS
  rssSources = ["http://xkcd.com/rss.xml", "http://www.smbc-comics.com/rss.php"] :: RssSources
  main :: IO ()
  main = (fetchFeeds rssSources !! 0) >>= return . prettyRss  >>= putStrLn
  -- main = (displayFeeds $ fetchFeeds rssSources) >>= putStrLn
  -- main = getRssData "http://www.smbc-comics.com/rss.php" >>= return . parseRssData >>= return . prettyRss >>= putStrLn
