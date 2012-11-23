describe "JsModuleTranspiler::Compiler (to_amd)" do
  def should_compile_as(input, output, options={})
    name = options[:anonymous] ? nil : "jquery"

    input = input.gsub(/^ {6}/, '')
    output = output.gsub(/^ {6}/, '').sub(/\n*\z/, '')

    compiler = JsModuleTranspiler::Compiler.new(input, name)
    compiler.to_amd.sub(/\n*\z/, '').should == output
  end

  def should_raise(input, message)
    compiler = JsModuleTranspiler::Compiler.new(input, 'jquery')

    lambda { compiler.to_amd }.should raise_error(JsModuleTranspiler::CompileError, message)
  end

  it "generates a single export if `export =` is used" do
    should_compile_as <<-INPUT, <<-OUTPUT
      var jQuery = function() { };

      export = jQuery;
    INPUT
      define("jquery",
        [],
        function() {
          "use strict";
          var jQuery = function() { };

          return jQuery;
        });
    OUTPUT
  end

  it "generates an export object if `export foo` is used" do
    should_compile_as <<-INPUT, <<-OUTPUT
      var jQuery = function() { };

      export jQuery;
    INPUT
      define("jquery",
        ["exports"],
        function(__exports__) {
          "use strict";
          var jQuery = function() { };

          __exports__.jQuery = jQuery;
        });
    OUTPUT
  end

  it "generates an export object if `export { foo, bar }` is used" do
    should_compile_as <<-INPUT, <<-OUTPUT
      var get = function() { };
      var set = function() { };

      export { get, set };
    INPUT
      define("jquery",
        ["exports"],
        function(__exports__) {
          "use strict";
          var get = function() { };
          var set = function() { };

          __exports__.get = get;
          __exports__.set = set;
        });
    OUTPUT
  end

  it "raises if both `export =` and `export foo` is used" do
    should_raise <<-INPUT, "You cannot use both `export =` and `export` in the same module"
      export { get, set };
      export = Ember;
    INPUT
  end

  it "converts `import foo from \"bar\"`" do
    should_compile_as <<-INPUT, <<-OUTPUT
      import _ from "underscore";
    INPUT
      define("jquery",
        ["underscore"],
        function(__dependency1__) {
          "use strict";
          var _ = __dependency1__._;
        });
    OUTPUT
  end

  it "converts `import { get, set } from \"ember\"`" do
    should_compile_as <<-INPUT, <<-OUTPUT
      import { get, set } from "ember";
    INPUT
      define("jquery",
        ["ember"],
        function(__dependency1__) {
          "use strict";
          var get = __dependency1__.get;
          var set = __dependency1__.set;
        });
    OUTPUT
  end

  it "converts `import \"bar\" as foo`" do
    should_compile_as <<-INPUT, <<-OUTPUT
      import "underscore" as _;
    INPUT
      define("jquery",
        ["underscore"],
        function(_) {
          "use strict";
        });
    OUTPUT
  end

  it "supports anonymous modules" do
    should_compile_as <<-INPUT, <<-OUTPUT, anonymous: true
      import "underscore" as _;
    INPUT
      define(
        ["underscore"],
        function(_) {
          "use strict";
        });
    OUTPUT
  end
end
