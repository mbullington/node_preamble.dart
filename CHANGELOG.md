## 1.2.0

* Prevent encapsulation, `global.self = global` (old) vs.
  `var self = Object.create(global)` (new).

## 1.1.0

* Set `global.location` so that `Uri.base()` works properly on Windows in most
  cases.

* Define `global.exports` so that it's visible to the compiled JS.
