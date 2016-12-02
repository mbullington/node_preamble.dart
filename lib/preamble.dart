library node_preamble;

var _NODE_PREAMBLE = r"""
  // TODO: This isn't really a correct transformation. For example, it will fail
  // for paths that contain characters that need to be escaped in URLs. Once
  // dart-lang/sdk#27979 is fixed, it should be possible to make it better.
  global.location = {
    href: "file://" + (function() {
      var cwd = process.cwd();
      if (process.platform != 'win32') return cwd;
      return '/' + cwd.replace('\\', '/');
    }) + "/"
  };
  global.scheduleImmediate = setImmediate;
  global.self = global;
  global.require = require;
  global.export = export;
  global.process = process;
  
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
  global.document = {
    get currentScript() {
      if (cachedCurrentScript == null) {
        cachedCurrentScript = {src: computeCurrentScript()};
      }
      return cachedCurrentScript;
    }
  };

  global.dartDeferredLibraryLoader = function(uri, successCallback, errorCallback) {
    try {
      load(uri);
      successCallback();
    } catch (error) {
      errorCallback(error);
    }
  };
""";

String getPreamble() => _NODE_PREAMBLE;
