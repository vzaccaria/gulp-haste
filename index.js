(function(){
  var map, debug, sh, decodePath, encodePath, haste;
  map = require('map-stream');
  debug = require("debug")("gulp-haste");
  sh = require('shelljs');
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
    return {
      relative: path.join(dirname, basename + extname)
    };
  };
  haste = function(options){
    return map(function(file, cb){
      var ref$, dirname, basename, extname, newPath, imprt, cmd;
      ref$ = decodePath(file), dirname = ref$.dirname, basename = ref$.basename, extname = ref$.extname;
      extname = "js";
      newPath = encodePath(dirname, basename, extname);
      if (options['export'] == null) {
        imprt = "%%";
      } else {
        imprt = "Haste[" + options['export'] + "]";
      }
      cmd = 'hastec --start="exports = ' + imprt + ';" ' + sourcefile + '--out=/dev/stdout';
      debug("invoking hastec compiler");
      return sh.exec(cmd, function(code, output){
        if (code !== 0) {
          return cb(true);
        } else {
          file.path = path.join(file.base, newPath);
          file.contents = new Buffer(output);
          return cb(false, file);
        }
      });
    });
  };
}).call(this);
