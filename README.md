[![Simple Haskell](http://simplehaskell.org/badges/badge.svg)](http://simplehaskell.org)
# Simple Haskell "Real world app"

A "simple Haskell" web app in order to show how Haskell shines at building "standard" apps with industrial practices (tdd & bdd).

It aims to implement the [real world app](https://github.com/gothinkster/realworld) API

## Main 3rd party libraries
- Testing : [hspec](https://hackage.haskell.org/package/hspec)
- HTTP router : [Scotty](https://hackage.haskell.org/package/scotty)
- Logs : [Katip](https://hackage.haskell.org/package/katip)
- Postgresql : TODO
- OpenTracing : TODO ?

## TDD

```
stack test --fast --file-watch
```
