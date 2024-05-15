{-# LANGUAGE OverloadedStrings #-}

module Generate
  ( newTVarUUID,
    generateUUID,
  )
where

import Control.Concurrent.Async (Concurrently (..), runConcurrently)
import Control.Concurrent.STM.TVar (modifyTVar)
import Data.ByteString.Builder (Builder)
import Data.Text.Encoding (encodeUtf8Builder)
import Data.UUID qualified as UUID
import Data.UUID.V4 (nextRandom)

newTVarUUID :: IO (TVar Builder)
newTVarUUID = newTVarIO mempty

generateUUID :: Int -> TVar Builder -> IO () -> IO ()
generateUUID length uuidsVar action =
  replicateM_ length (insertUUID uuidsVar action)

insertUUID :: TVar Builder -> IO () -> IO ()
insertUUID uuidsVar action = do
  uuid <- liftIO nextRandom

  let appendUuids =
        atomically
          ( modifyTVar uuidsVar $ \uuids ->
              (encodeUtf8Builder $ UUID.toText uuid <> "\n")
                <> uuids
          )

  void $
    runConcurrently $
      (,)
        <$> Concurrently appendUuids
        <*> Concurrently action
