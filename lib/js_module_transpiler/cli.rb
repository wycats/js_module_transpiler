require "thor"
require "thor/group"
require "fileutils"

module JsModuleTranspiler
  class CLI < Thor::Group
    desc "Compile a file or group of files into AMD or CommonJS modules"

    argument :path,     :desc => "A file or glob of the input"
    class_option :to,   :desc => "The output directory", :required => true
    class_option :type, :desc => "The type of the output", :enum => ['amd', 'globals', 'cjs'], :default => 'amd'
    class_option :anonymous, :desc => "Do not include a module name", :type => :boolean
    class_option :module_name, :desc => "The name of the outputted module"
    class_option :imports, :desc => "When the type is `globals`, a hash of import names to their global name", :type => :hash
    class_option :global, :desc => "When the type is `globals`, the name of the global to export into"

    def compile
      FileUtils.mkdir_p options[:to]

      files = Dir[path]

      if files.length > 1 && options[:module_name]
        say "Invalid arguments", :red
        print_wrapped "You are compiling multiple files, but you specified a module name. You should either compile one file at a time with a module name, or compile multiple files and let the transpiler use the file name as the module name."
        exit 1
      end

      files.each do |file|
        compile_file(file, File.join(options[:to], file))
      end
    end

    private

    def compile_file(filename, output)
      module_name = if options[:anonymous]
        nil
      elsif options[:module_name]
        options[:module_name]
      else
        module_name = File.basename(filename).sub(/\.js$/, '')
      end

      compiler_options = {}

      if options[:global]
        compiler_options[:into] = options[:global]
      end

      if options[:imports]
        compiler_options[:imports] = options[:imports]
      end

      compiler = JsModuleTranspiler::Compiler.new(File.read(filename), module_name, compiler_options)
      compiled_output = compiler.send "to_#{options[:type]}"

      FileUtils.mkdir_p File.dirname(output)
      File.open(output, 'w') { |file| file.write compiled_output }
    end
  end
end

