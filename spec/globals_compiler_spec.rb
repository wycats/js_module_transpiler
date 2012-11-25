describe "JsModuleTranspiler::Compiler (to_globals)" do
  it "generates a single export if `export =` is used" do
    should_compile_globals <<-INPUT, <<-OUTPUT
      var jQuery = function() { };

      export = jQuery;
    INPUT
      (function(exports) {
        "use strict";
        var jQuery = function() { };

        exports.jQuery = jQuery;
      })(window);
    OUTPUT
  end

  it "generates an export object if `export foo` is used" do
    should_compile_globals <<-INPUT, <<-OUTPUT
      var jQuery = function() { };

      export jQuery;
    INPUT
      (function(exports) {
        "use strict";
        var jQuery = function() { };

        exports.jQuery = jQuery;
      })(window);
    OUTPUT
  end

  it "uses a single window export if `export foo` is used with the :into option" do
    should_compile_globals <<-INPUT, <<-OUTPUT, :into => "Ember"
      var get = function() {};
      var set = function() {};

      export get;
      export set;
    INPUT
      (function(exports) {
        "use strict";
        var get = function() {};
        var set = function() {};

        exports.get = get;
        exports.set = set;
      })(window.Ember = {});
    OUTPUT
  end

  it "generates an export object if `export { foo, bar }` is used" do
    should_compile_globals <<-INPUT, <<-OUTPUT
      var get = function() { };
      var set = function() { };

      export { get, set };
    INPUT
      (function(exports) {
        "use strict";
        var get = function() { };
        var set = function() { };

        exports.get = get;
        exports.set = set;
      })(window);
    OUTPUT
  end

  it "uses a single window export if `export { foo, bar }` is used with the :into option" do
    should_compile_globals <<-INPUT, <<-OUTPUT, :into => "Ember"
      var get = function() { };
      var set = function() { };

      export { get, set };
    INPUT
      (function(exports) {
        "use strict";
        var get = function() { };
        var set = function() { };

        exports.get = get;
        exports.set = set;
      })(window.Ember = {});
    OUTPUT
  end

  it "raises if both `export =` and `export foo` is used" do
    should_raise <<-INPUT, "You cannot use both `export =` and `export` in the same module"
      export { get, set };
      export = Ember;
    INPUT
  end

  it "converts `import foo from \"bar\"` using a map to globals" do
    should_compile_globals <<-INPUT, <<-OUTPUT, :imports => { "ember" => "Ember" }
      import View from "ember";
    INPUT
      (function(Ember) {
        "use strict";
        var View = Ember.View;
      })(window.Ember);
    OUTPUT
  end

  it "converts `import { get, set } from \"ember\" using a map to globals`" do
    should_compile_globals <<-INPUT, <<-OUTPUT, :imports => { "ember" => "Ember" }
      import { get, set } from "ember";
    INPUT
      (function(Ember) {
        "use strict";
        var get = Ember.get;
        var set = Ember.set;
      })(window.Ember);
    OUTPUT
  end

  it "support single quotes in import from" do
    should_compile_globals <<-INPUT, <<-OUTPUT, :imports => { "ember" => "Ember" }
      import { get, set } from 'ember';
    INPUT
      (function(Ember) {
        "use strict";
        var get = Ember.get;
        var set = Ember.set;
      })(window.Ember);
    OUTPUT
  end

  it "converts `import { get, set } from \"ember\" using a map to globals` with exports" do
    should_compile_globals <<-INPUT, <<-OUTPUT, :imports => { "ember" => "Ember" }, :into => "DS"
      import { get, set } from "ember";

      export { get, set };
    INPUT
      (function(exports, Ember) {
        "use strict";
        var get = Ember.get;
        var set = Ember.set;

        exports.get = get;
        exports.set = set;
      })(window.DS = {}, window.Ember);
    OUTPUT
  end

  it "converts `import \"bar\" as foo`" do
    should_compile_globals <<-INPUT, <<-OUTPUT, :imports => { "underscore" => "_" }
      import "underscore" as _;
    INPUT
      (function(_) {
        "use strict";
      })(window._);
    OUTPUT
  end

  it "supports single quotes in import as" do
    should_compile_globals <<-INPUT, <<-OUTPUT, :imports => { "underscore" => "_" }
      import 'underscore' as undy;
    INPUT
      (function(undy) {
        "use strict";
      })(window._);
    OUTPUT
  end

  it "supports anonymous modules" do
    should_compile_globals <<-INPUT, <<-OUTPUT, anonymous: true, :imports => { "underscore" => "_" }
      import "underscore" as undy;
    INPUT
      (function(undy) {
        "use strict";
      })(window._);
    OUTPUT
  end
end


