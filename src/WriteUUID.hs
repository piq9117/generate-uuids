module WriteUUID
  ( writeUuidsToFile,
    uuidsToStdOut,
  )
where

import Conduit
  ( ConduitT,
    MonadUnliftIO,
    ResourceT,
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
import Data.Conduit.Combinators (stdout)
import Foreign.StablePtr (freeStablePtr, newStablePtr)
import System.IO (openFile)
import Prelude hiding (stdout)

runAction ::
  (MonadIO m) =>
  TMVar Builder ->
  ConduitT ByteString Void (ResourceT IO) b ->
  m b
runAction uuidsVar action = do
  -- 1mb buffer size
  let minPartSize = 1 * 1024 * 1024
  threadId <- liftIO myThreadId
  liftIO $ bracket (newStablePtr threadId) (freeStablePtr) $ \_ ->
    runConduitRes $
      (yieldM (atomically (takeTMVar uuidsVar)))
        .| transPipe
          liftIO
          (builderToByteStringWith $ allNewBuffersStrategy minPartSize)
        .| action

writeUuidsToFile ::
  (MonadIO m, MonadUnliftIO m) =>
  TMVar Builder ->
  FilePath ->
  m ()
writeUuidsToFile uuidsVar path = 
  runAction uuidsVar (sinkIOHandle (openFile path AppendMode))

uuidsToStdOut ::
  (MonadIO m) =>
  TMVar Builder ->
  m ()
uuidsToStdOut uuidsVar = runAction uuidsVar stdout
