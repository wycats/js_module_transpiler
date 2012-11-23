# JsModuleTranspiler

JS Module Transpiler is an experimental compiler that allows you
to write your JavaScript using a subset of the current ES6 module
syntax, and compile it into AMD modules (and soon, CommonJS modules)

**WARNING: The ES6 module syntax is still undergoing a lot of churn,
and will definitely still change before final approval.**

**JS Module Transpiler will track ES6 syntax, and not attempt to
maintain backwards compatibility with syntax that ultimately did
not succeed as part of ES6.**

This compiler provides a way to experiment with ES6 syntax in real
world scenarios to see how the syntax holds up. It also provides a
nicer, more declarative way to write AMD (or CommonJS) modules.

## Usage

### Executable

The easiest way to use the transpiler is via the command line:

```
$ gem install js_module_transpiler
$ compile-modules foo.js --to compiled
```

Here is the basic usage:

```
compile-modules INPUT --to OUTPUT [--type=TYPE]
  [--anonymous] [--module-name=NAME]

INPUT
  An input file or glob pattern relative to the current
  directory to process.

OUTPUT
  An output directory relative to the current directory.
  If it does not exist, it will be created.

TYPE
  One of `amd` (for AMD output) or `cjs` (for CommonJS
  output). At present, only AMD output is supported.

ANONYMOUS
  If you use the --anonymous flag with the AMD type, the
  transpiler will output a module with no name.

NAME
  You can supply a name to use as the module name.
  By default, the transpiler will use the name of the
  file (without the ending `.js`) as the module name.
  You may not use this option if your INPUT resolves
  to multiple files.
```

### Library

You can also use the transpiler as a library:

```ruby
require "js_module_transpiler"

compiler = JsModuleTranspiler::Compiler.new(string, name)
compiler.to_amd # AMD output
```

The `string` parameter is a string of JavaScript written using
the declarative module syntax.

The `name` parameter is an optional name that should be used
as the name of the module if appropriate (for AMD, this maps
onto the first parameter to the `define` function).

## Support Syntax

Again, this syntax is in flux and is closely tracking the
module work being done by TC39.

### Exports

There are two ways to do exports.

```javascript
var get = function(obj, key) {
  return obj[key];
};

var set = function(obj, key, value) {
  obj[key] = value;
  return obj;
};

export { get, set };
```

You can also write this form as:

```javascript
var get = function(obj, key) {
  return obj[key];
};

export get;

var set = function(obj, key, value) {
  obj[key] = value;
  return obj;
};

export set;
```

Both of these export two variables: `get` and `set`. Below,
in the import section, you will see how to use these exports
in another module.

You can also export a single variable *as the module itself*:

```javascript
var jQuery = function() {};

jQuery.prototype = {
  // ...
};

export = jQuery;
```

### Imports

If you want to import variables exported individually from
another module, you use this syntax:

```javascript
import { get, set } from "ember";
```

To import a module that set its export using `export =`,
you use this syntax:

```javascript
import "jquery" as jQuery;
```

As you can see, the import and export syntaxes are symmetric.

## AMD Compiled Output

### Individual Exports

This input:

```javascript
var get = function(obj, key) {
  return obj[key];
};

var set = function(obj, key, value) {
  obj[key] = value;
  return obj;
};

export { get, set };
```

will compile into this AMD output:

```javascript
define("ember",
  [],
  function(__exports__) {
    var get = function(obj, key) {
      return obj[key];
    };

    var set = function(obj, key, value) {
      obj[key] = value;
      return obj;
    };

    __exports__.get = get;
    __exports__.set = set;
  });
```

The output is the same whether you use the single-line
export (`export { get, set }`) or multiple export lines,
as above.

### A Single Export

This input:

```javascript
var jQuery = function() {};

jQuery.prototype = {
  // ...
};

export = jQuery;
```

will compile into this AMD output:

```javascript
define("ember",
  [],
  function() {
    var jQuery = function() {};

    jQuery.prototype = {
      // ...
    };

    return jQuery;
  });
```

### Individual Imports

This input:

```javascript
import { get, set } from "ember";
```

will compile into this AMD output:

```javascript
define("app",
  ["ember"],
  function(__dependency1__) {
    var get = __dependency1__.get;
    var set = __dependency1__.set;
  });
```

### Importing a Whole Module (`import as`)

This input:

```javascript
import "jquery" as jQuery;
```

will compile into this AMD output:

```javascript
define("app",
  ["jquery"],
  function(jQuery) {
  });
```

## Installation

Add this line to your application's Gemfile:

    gem 'js_module_transpiler'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install js_module_transpiler

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
