describe "JsModuleTranspiler::Compiler (to_cjs)" do
  it "generates a single export if `export =` is used" do
    should_compile_cjs <<-INPUT, <<-OUTPUT
      var jQuery = function() { };

      export = jQuery;
    INPUT
      "use strict";
      var jQuery = function() { };

      module.exports = jQuery;
    OUTPUT
  end

  it "generates an export object if `export foo` is used" do
    should_compile_cjs <<-INPUT, <<-OUTPUT
      var jQuery = function() { };

      export jQuery;
    INPUT
      "use strict";
      var jQuery = function() { };

      exports.jQuery = jQuery;
    OUTPUT
  end

  it "generates an export object if `export { foo, bar }` is used" do
    should_compile_cjs <<-INPUT, <<-OUTPUT
      var get = function() { };
      var set = function() { };

      export { get, set };
    INPUT
      "use strict";
      var get = function() { };
      var set = function() { };

      exports.get = get;
      exports.set = set;
    OUTPUT
  end

  it "raises if both `export =` and `export foo` is used" do
    should_raise <<-INPUT, "You cannot use both `export =` and `export` in the same module"
      export { get, set };
      export = Ember;
    INPUT
  end

  it "converts `import foo from \"bar\"`" do
    should_compile_cjs <<-INPUT, <<-OUTPUT
      import View from "ember";
    INPUT
      "use strict";
      var View = require("ember").View;
    OUTPUT
  end

  it "converts `import { get, set } from \"ember\"" do
    should_compile_cjs <<-INPUT, <<-OUTPUT
      import { get, set } from "ember";
    INPUT
      "use strict";
      var __dependency1__ = require("ember");
      var get = __dependency1__.get;
      var set = __dependency1__.set;
    OUTPUT
  end

  it "support single quotes in import from" do
    should_compile_cjs <<-INPUT, <<-OUTPUT
      import { get, set } from 'ember';
    INPUT
      "use strict";
      var __dependency1__ = require("ember");
      var get = __dependency1__.get;
      var set = __dependency1__.set;
    OUTPUT
  end

  it "converts `import \"bar\" as foo`" do
    should_compile_cjs <<-INPUT, <<-OUTPUT
      import "underscore" as _;
    INPUT
      "use strict";
      var _ = require("underscore");
    OUTPUT
  end

  it "supports single quotes in import as" do
    should_compile_cjs <<-INPUT, <<-OUTPUT
      import 'underscore' as undy;
    INPUT
      "use strict";
      var undy = require("underscore");
    OUTPUT
  end

  it "supports anonymous modules" do
    should_compile_cjs <<-INPUT, <<-OUTPUT, anonymous: true
      import "underscore" as undy;
    INPUT
      "use strict";
      var undy = require("underscore");
    OUTPUT
  end
end



