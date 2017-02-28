module Text.Pandoc.Tut where

import Data.Monoid
import Language.Haskell.Interpreter
import System.Exit
import Text.Pandoc

typeCheckWithPrelude :: (MonadInterpreter m) => String -> m Bool
typeCheckWithPrelude code = do
  setImports ["Prelude"]
  typeChecks code

runHint :: Block -> IO Block
runHint c@(CodeBlock _ contents) = do
  tc <- runInterpreter $ typeCheckWithPrelude contents
  either (die . show) (\b -> if b then return c
                                  else die $ "The following block did not type check!\n" <> contents) tc
runHint block = return block
