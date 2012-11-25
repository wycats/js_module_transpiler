require "js_module_transpiler/abstract_compiler"

module JsModuleTranspiler
  class AMDCompiler < AbstractCompiler
    def stringify
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
