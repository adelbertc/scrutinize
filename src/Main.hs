module Main where

import Text.Pandoc.Tut (runHint)
import Text.Pandoc.JSON

main :: IO ()
main = toJSONFilter runHint
