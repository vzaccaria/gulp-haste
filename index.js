(function(){
  var map, debug, sh, path, os, moment, gutil, otm, cwd, getTmpFile, rmTmpFile, decodePath, encodePath, haste, join$ = [].join;
  map = require('map-stream');
  debug = require("debug")("gulp-haste");
  sh = require('shelljs');
  path = require('path');
  os = require('os');
  moment = require('moment');
  gutil = require('gulp-util');
  otm = os.tmpdir != null ? os.tmpdir() : "/var/tmp";
  cwd = process.cwd();
  getTmpFile = function(){
    var name, dire;
    name = ("gulp-haste_" + moment().format('HHmmss') + "_") + Math.floor(Math.random() * 20000);
    dire = otm + "/" + name;
    return dire;
  };
  rmTmpFile = function(dir){
    return sh.rm('-rf', dir);
  };
  decodePath = function(file){
    var workdir, sourcefile, rpath, extname;
    workdir = file.cwd;
    sourcefile = file.path;
    rpath = path.relative(workdir, sourcefile);
    extname = path.extname(rpath);
    return {
      dirname: path.dirname(rpath),
      basename: path.basename(rpath, extname),
      extname: extname
    };
  };
  encodePath = function(dirname, basename, extname){
    return path.join(dirname, basename + extname);
  };
  haste = function(options){
    return map(function(file, cb){
      var cp, ref$, dirname, basename, extname, newPath, imprt, addOpt, fil, cmd;
      cp = (ref$ = decodePath(file), dirname = ref$.dirname, basename = ref$.basename, extname = ref$.extname, ref$);
      extname = ".js";
      newPath = encodePath(dirname, basename, extname);
      debug(JSON.stringify(cp, 0, 4));
      if ((options != null ? options['export'] : void 8) != null && options['export']) {
        imprt = "\"hasteMain(); module.exports = Haste;\"";
      } else {
        imprt = "\"module.exports = hasteMain\"";
      }
      addOpt = [];
      if ((options != null ? options.withJs : void 8) != null) {
        addOpt.push("--with-js=" + options.withJs);
      }
      fil = getTmpFile();
      cmd = "cd " + dirname + " && hastec --start=" + imprt + " " + file.path + " --out=" + fil + " " + join$.call(addOpt, ' ');
      debug("invoking hastec compiler");
      debug(cmd);
      return sh.exec(cmd, {
        silent: true
      }, function(code, out){
        var output;
        if (code !== 0) {
          debug("Error:");
          debug(out);
          return cb(true, out);
        } else {
          debug("Reading " + fil);
          output = sh.cat(fil);
          file.path = gutil.replaceExtension(file.path, '.js');
          debug("output to " + file.path);
          file.contents = new Buffer(output);
          return cb(false, file);
        }
      });
    });
  };
  module.exports = haste;
}).call(this);
