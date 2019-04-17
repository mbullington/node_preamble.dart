library node_preamble;

final _minified = r"""var dartNodePreambleHasGlobal="undefined"!=typeof global,dartNodePreambleSelf=dartNodePreambleHasGlobal?global:window,self=Object.create(dartNodePreambleSelf);self.scheduleImmediate=self.setImmediate?function(e){dartNodePreambleSelf.setImmediate(e)}:function(e){setTimeout(e,0)},self.require=require,self.exports=exports;var dartNodePreambleHasProcess="undefined"!=typeof process;dartNodePreambleHasProcess&&(self.process=process);var dartNodePreambleHasDirname="undefined"!=typeof __dirname;dartNodePreambleHasDirname&&(self.__dirname=__dirname);var dartNodePreambleHasFilename="undefined"!=typeof __filename;dartNodePreambleHasFilename&&(self.__filename=__filename),dartNodePreambleSelf.window||(self.location={get href(){return"file://"+(e=process.cwd(),"win32"!=process.platform?e:"/"+e.replace(/\\/g,"/"))+"/";var e}},function(){function e(){try{throw new Error}catch(t){var e=t.stack,r=new RegExp("^ *at [^(]*\\((.*):[0-9]*:[0-9]*\\)$","mg"),a=null;do{var l=r.exec(e);null!=l&&(a=l)}while(null!=l);return a[1]}}var r=null;self.document={get currentScript(){return null==r&&(r={src:e()}),r}}}(),self.dartDeferredLibraryLoader=function(e,r,a){try{load(e),r()}catch(e){a(e)}});""";

final _normal = r"""
// make sure to keep this as 'var'
// we don't want block scoping

// Making typeof its own variable prevents Angular or Webpack
// from 'breaking guard' and ruining our check.
// https://github.com/medialize/sass.js/commit/6241c10dbe35b181ad78ecbd692fed5f86213ffb
var dartNodePreambleHasGlobal = typeof global !== "undefined";
var dartNodePreambleSelf = dartNodePreambleHasGlobal ? global : window;

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

var dartNodePreambleHasProcess = typeof process !== "undefined";
if (dartNodePreambleHasProcess) {
  self.process = process;
}

var dartNodePreambleHasDirname = typeof __dirname !== "undefined";
if (dartNodePreambleHasDirname) {
  self.__dirname = __dirname;
}

var dartNodePreambleHasFilename = typeof __filename !== "undefined";
if (dartNodePreambleHasFilename) {
  self.__filename = __filename;
}

// if we're running in a browser, Dart supports most of this out of box
// make sure we only run these in Node.js environment
if (!dartNodePreambleSelf.window) {
  // TODO: This isn't really a correct transformation. For example, it will fail
  // for paths that contain characters that need to be escaped in URLs. Once
  // dart-lang/sdk#27979 is fixed, it should be possible to make it better.
  self.location = {
    get href() {
      return "file://" + (function() {
        var cwd = process.cwd();
        if (process.platform != "win32") return cwd;
        return "/" + cwd.replace(/\\/g, "/");
      })() + "/";
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
}""";

/// Returns the text of the preamble.
///
/// If [minified] is true, returns the minified version rather than the
/// human-readable version.
String getPreamble({bool minified: false, List<String> additionalGlobals: const []}) =>
    (minified ? _minified : _normal) +
    (additionalGlobals == null ? "" :
        additionalGlobals.map((global) => "self.$global=$global;").join());
