
# Why

This gulp plugin allows to use the Haste compiler to produce Requirejs modules from Haskell programs. You can export only one function at the moment.

# Prerequisites

* Install the [Haste compiler](https://github.com/valderman/haste-compiler)

# Installation

```
npm install gulp-haste
```

# Configuration

```javascript

haste = require('gulp-haste');

gulp.src("*.hs")
    .pipe(haste(options))
    .pipe(gulp.dest("build"));
```

where `options` is an optional hash. If you omit `options`, the Haskell's function exported is `main`.

# Options

```javascript
var options = {
   export: "name_of_haskell_function";
}
```

`export` specifies a different function to be exported. This function should be specified in the Haskell program like this:

```haskell
import Haste.Foreign

myFunction:: Int -> IO Bool
myFunction _ = return True

main = do 
    export "name_of_haskell_function" myFunction 
```
