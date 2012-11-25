require "js_module_transpiler/abstract_compiler"

module JsModuleTranspiler
  class CjsCompiler < AbstractCompiler
    def stringify
      output = []
      dependency_number = 0

      output << %{"use strict";}

      @import_as.each do |import, name|
        output << %{var #{name} = require("#{import}");}
      end

      @imports.each do |import, variables|
        if variables.size == 1
          variable = variables.first
          output << %{var #{variable} = require("#{import}").#{variable};}
        else
          dependency_number += 1
          dependency = "__dependency#{dependency_number}__"
          output << %{var #{dependency} = require("#{import}");}

          variables.each do |variable|
            output << %{var #{variable} = #{dependency}.#{variable};}
          end
        end
      end

      @lines.each do |line|
        output << line
      end

      if @export_as
        output << %{module.exports = #{@export_as};}
      end

      @exports.each do |export|
        output << %{exports.#{export} = #{export};}
      end

      return output.join("\n")
    end
  end
end
