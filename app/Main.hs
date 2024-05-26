{-# LANGUAGE OverloadedRecordDot #-}

module Main where

import CLI (CliInput (..), execParseCommand)
import Generate (generateUUID, newTMVarUUID)
import WriteUUID (writeUuidsToFile)

main :: IO ()
main = do
  cliInput <- execParseCommand
  uuidsVar <- newTMVarUUID
  generateUUID
    cliInput.count
    uuidsVar
    (writeUuidsToFile uuidsVar cliInput.filepath)
