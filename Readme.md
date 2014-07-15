
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

where `options` is an optional hash. If you omit `options`, the Haskell's function exported is just `main`.

# Options

```javascript
var options = {
   export: true;
   withJs: "file.js"
}
```

* `export=true` specifies that the whole set of FFI exported functions should be made available when requiring the module; 
* `withJs` includes the specified file in the prologue of the compiled program.

# Example
The code below FFI exports one function, which will be available by requiring the module:

```haskell
import Haste.Foreign

myFunction:: Int -> IO Bool
myFunction _ = return True

main = do 
    export "name_of_haskell_function" myFunction 
```

In order to load this function javascript-side:

```javascript
myHaskellFunction = require('converted_by_hastec').name_of_haskell_function
```


