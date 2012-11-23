require "thor"
require "thor/group"
require "fileutils"

module JsModuleTranspiler
  class CLI < Thor::Group
    desc "Compile a file or group of files into AMD or CommonJS modules"

    argument :path,     :desc => "A file or glob of the input"
    class_option :to,   :desc => "The output directory", :required => true
    class_option :type, :desc => "The type of the output", :enum => ['amd', 'cjs'], :default => 'amd'
    class_option :anonymous, :desc => "Do not include a module name", :type => :boolean
    class_option :module_name, :desc => "The name of the outputted module"

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

      compiler = JsModuleTranspiler::Compiler.new(File.read(filename), module_name)
      compiled_output = compiler.send "to_#{options[:type]}"

      File.open(output, 'w') { |file| file.write compiled_output }
    end
  end
end

