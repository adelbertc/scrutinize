module Main where

import Text.Pandoc.Scrutinize
import Text.Pandoc.JSON

main :: IO ()
main = toJSONFilter typeCheckCode
