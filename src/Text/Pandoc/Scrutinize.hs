module Text.Pandoc.Scrutinize where

import Data.List (isPrefixOf)
import Language.Haskell.Interpreter
import System.Exit (die)
import System.Directory (getTemporaryDirectory, removeFile)
import System.IO (Handle, hClose, hPutStrLn)
import System.IO.Temp (openTempFile)
import Text.Pandoc
import qualified Text.Pandoc.Scrutinize.Lines as L
import Text.Pandoc.Walk (query)

shouldCheck :: [String] -> Bool
shouldCheck attrs = ("haskell" `elem` attrs) && ("tut" `elem` attrs)

-- Extract Haskell code from the block
codeOf :: Block -> [String]
codeOf (CodeBlock (_, attrs, _) contents) = [contents | shouldCheck attrs]
codeOf _ = []

-- Shuffle the imports to the top of the file
-- We do this because we'd like to have imports local to slides
-- but Haskell does not like imports in the middle of the file
shuffleImports :: L.Lines -> [String]
shuffleImports = shuffle . foldr go ([], []) . L.getLines
  where shuffle (imports, rest) = imports ++ rest

        go str (imports, rest) = if "import " `isPrefixOf` str then (str : imports, rest) else (imports, str : rest)

-- Extract Haskell code from the document
extractCode :: Pandoc -> L.Lines
extractCode = foldMap L.lines . query codeOf

-- Pretty print errors
prettyError :: InterpreterError -> String
prettyError (UnknownError ie) = "Unknown error: " ++ ie
prettyError (WontCompile ie) = unlines $ fmap errMsg ie
prettyError (NotAllowed ie) = "Not allowed: " ++ ie
prettyError (GhcException ie) = "GHC exception thrown: " ++ ie

-- TODO Replace hClose + friends with something that actually has resource management

-- Get code from document, dump into file, then attempt to load the file as a module to type check
loadCode :: Pandoc -> FilePath -> Handle -> IO Pandoc
loadCode pandoc filePath handle = do
  hPutStrLn handle $ unlines $ shuffleImports $ extractCode pandoc
  hClose handle
  result <- runInterpreter $ loadModules [filePath]
  removeFile filePath
  either (die . prettyError) (const $ return pandoc) result

-- Type check the Haskell code of the document
typeCheckCode :: Pandoc -> IO Pandoc
typeCheckCode pandoc = do
  tmpDir <- getTemporaryDirectory
  (filePath, handle) <- openTempFile tmpDir "ScrutinizePandocTemp.hs"
  loadCode pandoc filePath handle
