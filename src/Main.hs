module Main where

import Text.Pandoc.Tut
import Text.Pandoc.JSON

main :: IO ()
main = toJSONFilter typeCheckCode
