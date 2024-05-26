module WriteUUID (writeUuidsToFile) where

import Conduit
  ( MonadUnliftIO,
    allNewBuffersStrategy,
    builderToByteStringWith,
    runConduitRes,
    sinkIOHandle,
    transPipe,
    yieldM,
    (.|),
  )
import Control.Concurrent (myThreadId)
import Control.Exception (bracket)
import Data.ByteString.Builder (Builder)
import Foreign.StablePtr (freeStablePtr, newStablePtr)
import System.IO (openFile)

writeUuidsToFile ::
  (MonadIO m, MonadUnliftIO m) =>
  TMVar Builder ->
  FilePath ->
  m ()
writeUuidsToFile uuidsVar path = do
  -- 1mb buffer size
  let minPartSize = 1 * 1024 * 1024
  threadId <- liftIO myThreadId
  liftIO $ bracket (newStablePtr threadId) (freeStablePtr) $ \_ ->
    runConduitRes $
      (yieldM (atomically (takeTMVar uuidsVar)))
        .| transPipe
          liftIO
          (builderToByteStringWith $ allNewBuffersStrategy minPartSize)
        .| sinkIOHandle (openFile path AppendMode)
