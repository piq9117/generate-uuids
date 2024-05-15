{-# LANGUAGE OverloadedStrings #-}

module Generate
  ( newTVarUUID,
    generateUUID,
  )
where

import Control.Concurrent.Async (withAsync)
import Control.Concurrent.STM.TVar (modifyTVar)
import Data.ByteString.Builder (Builder)
import Data.Text.Encoding (encodeUtf8Builder)
import Data.UUID qualified as UUID
import Data.UUID.V4 (nextRandom)

newTVarUUID :: IO (TVar Builder)
newTVarUUID = newTVarIO mempty

generateUUID :: Int -> TVar Builder -> IO ()
generateUUID length uuidsVar = replicateM_ length (insertUUID uuidsVar)

insertUUID :: TVar Builder -> IO ()
insertUUID uuidsVar = do
  uuid <- liftIO nextRandom

  let appendUuids =
        atomically
          ( modifyTVar uuidsVar $ \uuids ->
              (encodeUtf8Builder $ UUID.toText uuid <> "\n")
                <> uuids
          )

  withAsync appendUuids $ \_ -> pure ()
