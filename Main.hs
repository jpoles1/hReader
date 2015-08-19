{-# LANGUAGE OverloadedStrings, TypeSynonymInstances, FlexibleInstances#-}
module Main where
  import RSS
  rssSources = ["http://xkcd.com/rss.xml", "http://www.smbc-comics.com/rss.php"] :: RssSources
  main :: IO ()
  main = (displayFeeds $ fetchFeeds rssSources) >>= putStrLn
