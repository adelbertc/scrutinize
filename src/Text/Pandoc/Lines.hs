module Text.Pandoc.Lines(Lines, getLines, lines, liness, linesMany) where

import Prelude hiding (lines)
import qualified Prelude as P (lines)

newtype Lines = Lines { getLines :: [String] } deriving (Show)

instance Monoid Lines where
  mempty = Lines []
  x `mappend` y = Lines $ getLines x ++ getLines y

lines :: String -> Lines
lines = Lines . P.lines

liness :: [Lines] -> Lines
liness = mconcat

linesMany :: [String] -> Lines
linesMany = liness . fmap lines
