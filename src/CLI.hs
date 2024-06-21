{-# LANGUAGE GADTs #-}
{-# LANGUAGE OverloadedStrings #-}

module CLI
  ( Command (..),
    CliInput (..),
    execParseCommand,
  )
where

import Options.Applicative
  ( Parser,
    ParserInfo,
    auto,
    execParser,
    fullDesc,
    header,
    help,
    helper,
    info,
    long,
    option,
    progDesc,
    short,
    strOption,
  )

data Command
  = ParseCommand CliInput

data CliInput = CliInput
  { -- | filepath output of the uuids.
    -- If this is null, it will output to stdout
    filepath :: Maybe FilePath,
    count :: Int
  }

execParseCommand :: IO CliInput
execParseCommand = execParser parseOpts

parseCommand :: Parser CliInput
parseCommand =
  CliInput
    <$> ( optional $
            strOption
              ( long "filepath"
                  <> short 'f'
                  <> help "File path where uuids will be inserted"
              )
        )
    <*> ( option
            auto
            ( long "count"
                <> short 'c'
                <> help "Number of uuids"
            )
        )

parseOpts :: ParserInfo CliInput
parseOpts =
  info
    (parseCommand <**> helper)
    ( fullDesc
        <> progDesc "Generate UUIDs"
        <> header "generate-uuids: a CLI tool to generate uuids"
    )
