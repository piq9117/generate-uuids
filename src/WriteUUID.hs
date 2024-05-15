module WriteUUID (writeUuidsToFile) where

import Conduit
  ( MonadUnliftIO,
    allNewBuffersStrategy,
    builderToByteStringWith,
    runConduitRes,
    sinkFileBS,
    transPipe,
    yield,
    (.|),
  )
import Data.ByteString.Builder (Builder)

writeUuidsToFile ::
  (MonadIO m, MonadUnliftIO m) =>
  TVar Builder ->
  FilePath ->
  m ()
writeUuidsToFile uuidsVar path = do
  uuids <- readTVarIO uuidsVar
  -- 10mb buffer size
  let minPartSize = 10 * 1024 * 1024
  runConduitRes $
    yield uuids
      .| transPipe liftIO (builderToByteStringWith $ allNewBuffersStrategy minPartSize)
      .| sinkFileBS path
