module Text.Pandoc.Lines(Lines, getLines, lines) where

import Data.Semigroup
import Prelude hiding (lines)
import qualified Prelude as P (lines)

newtype Lines = Lines { getLines :: [String] } deriving (Show)

instance Semigroup Lines where
  (<>) = mappend

instance Monoid Lines where
  mempty = Lines []
  x `mappend` y = Lines $ getLines x ++ getLines y

lines :: String -> Lines
lines = Lines . P.lines
