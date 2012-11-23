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

    def initialize(string, module_name=nil)
      @string = string
      @module_name = module_name

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
      assert_valid

      dependency_names = [] | @imports.keys | @import_as.keys

      arguments, preamble = build_preamble(dependency_names)

      unless @exports.empty?
        dependency_names << "exports"
        arguments << "__exports__"
      end

      output = []

      if @module_name
        output << %{define("#{@module_name}",}
      else
        output << %{define(}
      end

      output << "  [" + dependency_names.map(&:inspect).join(", ") + "],"
      output << "  function(" + arguments.join(", ") + ") {"
      output << "    \"use strict\";"

      preamble.each do |line|
        output << "    #{line}"
      end

      @lines.each do |line|
        if line =~ /^\s*$/
          output << line
        else
          output << "    #{line}"
        end
      end

      @exports.each do |export|
        output << "    __exports__.#{export} = #{export};"
      end

      if @export_as
        output << "    return #{@export_as};"
      end

      output << "  });"

      output.join("\n")
    end

    private

    def assert_valid
      if @export_as && !@exports.empty?
        raise CompileError.new("You cannot use both `export =` and `export` in the same module")
      end
    end

    def build_preamble(names)
      preamble = []
      arguments = []
      number = 0

      names.each do |name|
        if @import_as.key?(name)
          arguments << @import_as[name]
        else
          dependency = "__dependency#{number += 1}__"
          arguments << dependency
          preamble.concat imports_for_preamble(@imports[name], dependency)
        end
      end

      [ arguments, preamble ]
    end

    def imports_for_preamble(import_names, dependency_name)
      import_names.map do |import_name|
        "var #{import_name} = #{dependency_name}.#{import_name};"
      end
    end
  end
end
