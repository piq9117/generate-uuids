{-# LANGUAGE GADTs #-}

module CLI where

data Command a where
  ParseCommand :: Text -> Command CliInput

data CliInput = CliInput
  { filePath :: FilePath,
    count :: Int
  }
