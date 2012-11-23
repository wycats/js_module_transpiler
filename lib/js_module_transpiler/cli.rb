require "thor"
require "thor/group"
require "fileutils"

module JsModuleTranspiler
  class CLI < Thor::Group
    desc "Compile a file or group of files into AMD or CommonJS modules"

    argument :path,     :desc => "A file or glob of the input"
    class_option :to,   :desc => "The output directory", :required => true
    class_option :type, :desc => "The type of the output", :enum => ['amd', 'cjs'], :default => 'amd'

    def compile
      FileUtils.mkdir_p options[:to]

      files = Dir[path]

      files.each do |file|
        compile_file(file, File.join(options[:to], file))
      end
    end

    private

    def compile_file(filename, output)
      compiler = JsModuleTranspiler::Compiler.new(File.basename(filename), File.read(filename))
      compiled_output = compiler.send "to_#{options[:type]}"

      File.open(output, 'w') { |file| file.write compiled_output }
    end
  end
end

