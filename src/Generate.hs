{-# LANGUAGE OverloadedStrings #-}

module Generate
  ( newTMVarUUID,
    generateUUID,
  )
where

import Control.Concurrent.Async (Concurrently (..), runConcurrently)
import Data.ByteString.Builder (Builder)
import Data.Text.Encoding (encodeUtf8Builder)
import Data.UUID qualified as UUID
import Data.UUID.V4 (nextRandom)

newTMVarUUID :: IO (TMVar Builder)
newTMVarUUID = newEmptyTMVarIO

generateUUID :: Int -> TMVar Builder -> IO () -> IO ()
generateUUID length uuidVar action = do
  replicateM_ length (insertUUID uuidVar action)

insertUUID :: TMVar Builder -> IO () -> IO ()
insertUUID uuidsVar action = do
  uuid <- liftIO nextRandom

  let putUuid =
        atomically
          ( putTMVar uuidsVar (encodeUtf8Builder $ UUID.toText uuid <> "\n")
          )

  void $
    runConcurrently $
      (,)
        <$> Concurrently putUuid
        <*> Concurrently action
