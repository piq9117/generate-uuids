{-# LANGUAGE OverloadedRecordDot #-}

module Main where

import CLI (CliInput (..), execParseCommand)
import Generate (generateUUID, newTMVarUUID)
import WriteUUID (uuidsToStdOut, writeUuidsToFile)

main :: IO ()
main = do
  cliInput <- execParseCommand
  uuidsVar <- newTMVarUUID
  generateUUID
    cliInput.count
    uuidsVar
    ( case cliInput.filepath of
        Nothing -> uuidsToStdOut uuidsVar
        Just filepath -> writeUuidsToFile uuidsVar filepath
    )
