{-# LANGUAGE DeriveGeneric #-}
module JSON where
  import Data.Aeson
  import Control.Applicative
  import qualified Data.ByteString.Lazy as B
  import GHC.Generics
  data Configuration = Configuration {debug :: Bool, sources :: [String]} deriving (Show, Generic)
  instance FromJSON Configuration
  instance ToJSON Configuration
  getConfig :: FilePath -> IO Configuration
  getConfig path = do
     -- Get JSON data and decode it
     d <- (B.readFile path >>= return . eitherDecode) :: IO (Either String Configuration)
     -- If d is Left, the JSON was malformed.
     -- In that case, we report the error.
     -- Otherwise, we perform the operation of
     -- our choice. In this case, just print it.
     case d of
      Left err -> error err
      Right ps -> return ps
  getSources :: FilePath -> IO [String]
  getSources path = getConfig path >>= return . sources
