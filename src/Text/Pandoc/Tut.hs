module Text.Pandoc.Tut where

import Language.Haskell.Interpreter
import System.Exit (die)
import System.Directory (getTemporaryDirectory, removeFile)
import System.IO (Handle, hClose, hPutStrLn)
import System.IO.Temp (openTempFile)
import Text.Pandoc
import Text.Pandoc.Walk (query)

shouldCheck :: [String] -> Bool
shouldCheck attrs = ("haskell" `elem` attrs) && ("tut" `elem` attrs)

-- Extract Haskell code from the block
codeOf :: Block -> [String]
codeOf (CodeBlock (_, attrs, _) contents) = [contents | shouldCheck attrs]
codeOf _ = []

-- Extract Haskell code from the document
extractCode :: Pandoc -> [String]
extractCode = query codeOf

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
  hPutStrLn handle $ unlines $ extractCode pandoc
  hClose handle
  result <- runInterpreter $ loadModules [filePath]
  removeFile filePath
  either (die . prettyError) (const $ return pandoc) result

-- Type check the Haskell code of the document
typeCheckCode :: Pandoc -> IO Pandoc
typeCheckCode pandoc = do
  tmpDir <- getTemporaryDirectory
  (filePath, handle) <- openTempFile tmpDir "TutPandocTemp.hs"
  loadCode pandoc filePath handle
