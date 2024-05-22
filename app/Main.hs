{-# LANGUAGE OverloadedRecordDot #-}

module Main where

import CLI (CliInput (..), execParseCommand)
import Generate (generateUUID, newTVarUUID)
import WriteUUID (writeUuidsToFile)

main :: IO ()
main = do
  cliInput <- execParseCommand
  uuidsVar <- newTVarUUID
  generateUUID
    cliInput.count
    uuidsVar
    (writeUuidsToFile uuidsVar cliInput.filepath)
