library node_preamble;

final _minified = r"""var self=Object.create(global);self.scheduleImmediate=self.setImmediate?function(e){global.setImmediate(e)}:function(e){setTimeout(e,0)},self.require=require,self.exports=exports,self.process=process,self.__dirname=__dirname,self.__filename=__filename,global.window||(self.location={get href(){return"file://"+(e=process.cwd(),"win32"!=process.platform?e:"/"+e.replace(/\\/g,"/"))+"/";var e}},function(){var e=null;self.document={get currentScript(){return null==e&&(e={src:function(){try{throw new Error}catch(n){var e=n.stack,r=new RegExp("^ *at [^(]*\\((.*):[0-9]*:[0-9]*\\)$","mg"),l=null;do{var t=r.exec(e);null!=t&&(l=t)}while(null!=t);return l[1]}}()}),e}}}(),self.dartDeferredLibraryLoader=function(e,r,l){try{load(e),r()}catch(e){l(e)}});""";

final _normal = r"""
// make sure to keep this as 'var'
// we don't want block scoping
var self = Object.create(global);

self.scheduleImmediate = self.setImmediate
    ? function (cb) {
        global.setImmediate(cb);
      }
    : function(cb) {
        setTimeout(cb, 0);
      };

self.require = require;
self.exports = exports;
self.process = process;

self.__dirname = __dirname;
self.__filename = __filename;

// if we're running in a browser, Dart supports most of this out of box
// make sure we only run these in Node.js environment
if (!global.window) {
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
