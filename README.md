# tut-pandoc
A [pandoc](http://pandoc.org/) filter in the spirit of the Scala [tut](https://github.com/tpolecat/tut)
documentation tool.

## Example usage

    $ stack build

    $ pandoc -f markdown -t json test/compiles.md | stack runghc src/Main.hs | pandoc -f json -t markdown
    Hello
    =====

    ``` {.haskell .tut}
    x = head [1,2,3]
    ```

    This is a paragraph.

    ``` {.haskell .tut}
    myFunc :: Int -> String
    myFunc = show

    y = fmap show [1,2,3]
    ```
    $ pandoc -f markdown -t json test/no-compile.md | stack runghc src/Main.hs | pandoc -f json -t markdown
    [removed].hs:3:1: error:
        parse error (possibly incorrect indentation or mismatched brackets)
    [removed].hs:3:1: error:
        parse error (possibly incorrect indentation or mismatched brackets)

    pandoc: Error in $: not enough input
    CallStack (from HasCallStack):
      error, called at src/Text/Pandoc/Error.hs:55:28 in pandoc-1.19.2.1-E0SxNY8GMzzEOa2v54Gdkt:Text.Pandoc.Error

## License
Code is provided under the Apache 2.0 license available at http://opensource.org/licenses/Apache-2.0,
as well as in the LICENSE file.
