require "js_module_transpiler/amd_compiler"
require "js_module_transpiler/globals_compiler"

module JsModuleTranspiler
  class CompileError < StandardError
  end

  class Compiler
    EXPORT = %r{^\s*export\s+(?<exports>.*)\s*;\s*$}
    EXPORT_AS = %r{^\s*export\s*=\s*(?<export>.*)\s*;\s*$}

    IMPORT = %r{^\s*import\s+(?<pattern>.*)\s+from\s+(?:"(?<import>[^"]+)"|'(?<import>[^']+)')\s*;\s*$}
    IMPORT_AS = %r{^\s*import\s+(?:"(?<import>[^"]+)"|'(?<import>[^']+)')\s*as\s+(?<variable>.*)\s*;\s*$}

    # not supported yet
    #EXPORT_FROM = %r{^\s*export\s*(?<exports>.*)\s*from\s*"(?<module>[^"]+)"\s*;\s*$}

    attr_reader :imports, :exports, :import_as, :export_as, :module_name, :lines

    def initialize(string, module_name=nil, options={})
      @string = string
      @module_name = module_name
      @options = options

      @imports = {}
      @import_as = {}
      @exports = []
      @export_as = nil
      @lines = []

      parse
    end

    def parse
      @string.each_line { |line| parse_line(line) }
    end

    def parse_line(line)
      case line
      when EXPORT_AS
        process_export_as $~
      when EXPORT
        process_export $~
      when IMPORT_AS
        process_import_as $~
      when IMPORT
        process_import $~
      else
        process_line line.sub(/\n$/, '')
      end
    end

    # EXPORT = %r{^\s*export\s+(?<exports>.*)\s*;\s*$}
    def process_export(match)
      exports = match[:exports]

      if exports[0] == "{" and exports[-1] == "}"
        exports = exports[1...-1]
      end

      export_specifiers = exports.split(/\s*,\s*/).map(&:strip)

      @exports |= export_specifiers
    end

    # EXPORT_AS = %r{^\s*export\s*=\s*(?<export>.*)\s*;\s*$}
    def process_export_as(match)
      @export_as = match[:export]
    end

    # IMPORT = %r{^\s*import\s+(?<pattern>.*)\s+from\s+"(?<import>[^"]+)"\s*;\s*$}
    def process_import(match)
      pattern = match[:pattern]

      if pattern[0] == "{" and pattern[-1] == "}"
        pattern = pattern[1...-1]
      end

      import_names = pattern.split(/\s*,\s*/).map(&:strip)

      @imports[match[:import]] = import_names
    end

    # IMPORT_AS = %r{^\s*import\s+"(?<import>[^"]+)"\s*as\s+(?<variable>.*)\s*;\s*$}
    def process_import_as(match)
      @import_as[match[:import]] = match[:variable]
    end

    def process_line(line)
      @lines << line
    end

    def to_amd
      AMDCompiler.new(self, @options).stringify
    end

    def to_globals
      GlobalsCompiler.new(self, @options).stringify
    end
  end
end
