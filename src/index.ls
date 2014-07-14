map    = require('map-stream');
debug  = require("debug")("gulp-haste")
sh     = require('shelljs')
path   = require('path')
os     = require('os')
moment = require('moment')
gutil  = require('gulp-util')

otm = if (os.tmpdir?) then os.tmpdir() else "/var/tmp"
cwd = process.cwd()

get-tmp-file = ->
    name = "gulp-haste_#{moment().format('HHmmss')}_"+Math.floor(Math.random()*20000)
    dire = "#{otm}/#{name}" 
    return dire

rm-tmp-file = (dir) ->
    sh.rm '-rf', dir 


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
  path.join(dirname, basename+extname)

haste = (options) -> 

    map (file, cb) ->

        cp = { dirname, basename, extname } = decode-path(file)
        extname = ".js"
        new-path = encode-path(dirname, basename, extname)
        debug(JSON.stringify(cp, 0 ,4))

        if options?.export? and options.export 
            imprt = "%%(); module.exports = Haste;"
        else 
            imprt = "module.exports = %%"

        fil = get-tmp-file()
        cmd = 'hastec --start="' + imprt + ';" ' + file.path + ' --out='+fil 

        debug("invoking hastec compiler")
        debug cmd
        sh.exec cmd, {+silent}, (code) ->
            if code != 0
                cb(true)
            else 
                debug("Reading #fil")
                output        = sh.cat(fil)
                rm-tmp-file fil
                file.path     = gutil.replaceExtension(file.path, '.js');
                file.contents = new Buffer(output)
                cb(false, file)

module.exports = haste