library node_preamble;

final _minified = r"""var url=require("url"),dartNodePreambleSelf="undefined"!=typeof global?global:window,self=Object.create(dartNodePreambleSelf);self.scheduleImmediate=self.setImmediate?function(e){dartNodePreambleSelf.setImmediate(e)}:function(e){setTimeout(e,0)},self.require=require,self.exports=exports,"undefined"!=typeof process&&(self.process=process),"undefined"!=typeof __dirname&&(self.__dirname=__dirname),"undefined"!=typeof __filename&&(self.__filename=__filename),dartNodePreambleSelf.window||(self.location={get href(){return url.pathToFileURL?url.pathToFileURL(process.cwd()).href+"/":"file://"+(e=process.cwd(),"win32"!=process.platform?e:"/"+e.replace(/\\/g,"/"))+"/";var e}},function(){function e(){try{throw new Error}catch(n){var e=n.stack,r=new RegExp("^ *at [^(]*\\((.*):[0-9]*:[0-9]*\\)$","mg"),l=null;do{var t=r.exec(e);null!=t&&(l=t)}while(null!=t);return l[1]}}var r=null;self.document={get currentScript(){return null==r&&(r={src:e()}),r}}}(),self.dartDeferredLibraryLoader=function(e,r,l){try{load(e),r()}catch(e){l(e)}});""";

final _normal = r"""
// make sure to keep this as 'var'
// we don't want block scoping

var url = require("url");
var dartNodePreambleSelf = typeof global !== "undefined" ? global : window;

var self = Object.create(dartNodePreambleSelf);

self.scheduleImmediate = self.setImmediate
    ? function (cb) {
        dartNodePreambleSelf.setImmediate(cb);
      }
    : function(cb) {
        setTimeout(cb, 0);
      };

// CommonJS globals.
self.require = require;
self.exports = exports;

// Node.js specific exports, check to see if they exist & or polyfilled

if (typeof process !== "undefined") {
  self.process = process;
}

if (typeof __dirname !== "undefined") {
  self.__dirname = __dirname;
}

if (typeof __filename !== "undefined") {
  self.__filename = __filename;
}

// if we're running in a browser, Dart supports most of this out of box
// make sure we only run these in Node.js environment
if (!dartNodePreambleSelf.window) {
  self.location = {
    get href() {
      if (url.pathToFileURL) {
        return url.pathToFileURL(process.cwd()).href + "/";
      } else {
        // This isn't really a correct transformation, but it's the best we have
        // for versions of Node <10.12.0 which introduced `url.pathToFileURL()`.
        // For example, it will fail for paths that contain characters that need
        // to be escaped in URLs.
        return "file://" + (function() {
          var cwd = process.cwd();
          if (process.platform != "win32") return cwd;
          return "/" + cwd.replace(/\\/g, "/");
        })() + "/"
      }
    }
  };

  (function() {
    function computeCurrentScript() {
      try {
        throw new Error();
      } catch(e) {
        var stack = e.stack;
        var re = new RegExp("^ *at [^(]*\\((.*):[0-9]*:[0-9]*\\)$", "mg");
        var lastMatch = null;
        do {
          var match = re.exec(stack);
          if (match != null) lastMatch = match;
        } while (match != null);
        return lastMatch[1];
      }
    }

    var cachedCurrentScript = null;
    self.document = {
      get currentScript() {
        if (cachedCurrentScript == null) {
          cachedCurrentScript = {src: computeCurrentScript()};
        }
        return cachedCurrentScript;
      }
    };
  })();

  self.dartDeferredLibraryLoader = function(uri, successCallback, errorCallback) {
    try {
     load(uri);
      successCallback();
    } catch (error) {
      errorCallback(error);
    }
  };
}
""";

/// Returns the text of the preamble.
///
/// If [minified] is true, returns the minified version rather than the
/// human-readable version.
String getPreamble({bool minified: false, List<String> additionalGlobals: const []}) =>
    (minified ? _minified : _normal) +
    (additionalGlobals == null ? "" :
        additionalGlobals.map((global) => "self.$global=$global;").join());
