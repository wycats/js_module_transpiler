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

      passed_args = []
      received_args = []

      if !@exports.empty? || @export_as
        if into = @options[:into]
          passed_args << "window.#{into} = {}"
        else
          passed_args << "window"
        end

        received_args << "exports"
      end

      preamble = []
      preamble << %{  "use strict";}

      dependency_names.each do |name|
        global_import = @options[:imports][name]
        passed_args << "window.#{global_import}"

        if @import_as.key?(name)
          received_args << @import_as[name]
        else
          received_args << global_import

          @imports[name].each do |import|
            preamble << "  var #{import} = #{global_import}.#{import};"
          end
        end
      end

      output = []
      output << "(function(#{received_args.join(", ")}) {"

      preamble.each do |line|
        output << line
      end

      @lines.each do |line|
        if line =~ /^\s*$/
          output << line
        else
          output << "  #{line}"
        end
      end

      if @export_as
        output << "  exports.#{@export_as} = #{@export_as};"
      else
        @exports.each do |export|
          output << "  exports.#{export} = #{export};"
        end
      end

      output << "})(#{passed_args.join(", ")});"

      output.join("\n")
    end
  end
end
