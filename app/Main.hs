module Main where

import Generate (generateUUID, newTVarUUID)
import WriteUUID (writeUuidsToFile)

main :: IO ()
main = do
  uuidsVar <- newTVarUUID
  generateUUID
    10_000
    uuidsVar
    (writeUuidsToFile uuidsVar "uuid-file")
