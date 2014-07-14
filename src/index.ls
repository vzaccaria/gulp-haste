map   = require('map-stream');
debug = require("debug")("gulp-haste")
sh = require('shelljs')

decode-path = (file) ->

  workdir    = file.cwd
  sourcefile = file.path
  rpath      = path.relative(workdir, sourcefile)
  extname    = path.extname(rpath)

  return {
    dirname: path.dirname(rpath)
    basename: path.basename(rpath, extname)
    extname: extname
  }

encode-path = (dirname, basename, extname) ->
  relative: path.join(dirname, basename+extname)

haste = (options) -> 

    map (file, cb) ->

        { dirname, basename, extname } = decode-path(file)
        extname                        = "js"
        new-path                       = encode-path(dirname, basename, extname)

        if not options.export?
            imprt = "%%"
        else 
            imprt = "Haste[#{options.export}]"

        cmd = 'hastec --start="exports = ' + imprt + ';" ' + sourcefile + '--out=/dev/stdout'

        debug("invoking hastec compiler")
        sh.exec cmd, (code, output) ->
            if code != 0
                cb(true)
            else 
                file.path     = path.join(file.base, new-path)
                file.contents = new Buffer(output)
                cb(false, file)

