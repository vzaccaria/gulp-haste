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
            imprt = "\"hasteMain(); module.exports = Haste;\""
        else 
            imprt = "\"module.exports = hasteMain\""

        add-opt = []

        if options?.with-js? 
            add-opt.push("--with-js=#{options.with-js}")

        fil = get-tmp-file()

        cmd = "cd #dirname && hastec --start=#imprt #{file.path} --out=#fil #{add-opt * ' '}"

        debug("invoking hastec compiler")
        debug cmd
        sh.exec cmd, {+silent}, (code,out) ->
            if code != 0
                debug("Error:")
                debug(out)
                cb(true, out)
            else 
                debug("Reading #fil")
                output        = sh.cat(fil)
                file.path     = gutil.replaceExtension(file.path, '.js');
                debug("output to #{file.path}")
                file.contents = new Buffer(output)
                cb(false, file)

module.exports = haste