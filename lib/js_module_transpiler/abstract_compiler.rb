module JsModuleTranspiler
  class AbstractCompiler
    def initialize(compiler, options)
      @compiler = compiler

      @exports = compiler.exports
      @export_as = compiler.export_as
      @imports = compiler.imports
      @import_as = compiler.import_as

      @module_name = compiler.module_name
      @lines = compiler.lines

      @options = options

      assert_valid
    end

    private

    def assert_valid
      if @export_as && !@exports.empty?
        raise CompileError.new("You cannot use both `export =` and `export` in the same module")
      end
    end

    def dependency_names
      @dependency_names ||= [] | @imports.keys | @import_as.keys
    end
  end
end
