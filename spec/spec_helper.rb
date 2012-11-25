unless ENV["TRAVIS"]
  require 'simplecov'
  SimpleCov.start do
    add_group "lib", "lib"
    add_group "spec", "spec"
  end
end

require 'js_module_transpiler'

module JsModuleTranspiler::TestHelpers
  def normalize(input, output, name, options={})
    input = input.gsub(/^ {6}/, '')
    output = output.gsub(/^ {6}/, '').sub(/\n*\z/, '')

    compiler = JsModuleTranspiler::Compiler.new(input, name, options)

    [ output, compiler ]
  end

  def should_compile_amd(input, output, options={})
    name = options[:anonymous] ? nil : "jquery"

    output, compiler = normalize(input, output, name)
    compiler.to_amd.sub(/\n*\z/, '').should == output
  end

  def should_compile_cjs(input, output, options={})
    name = options[:anonymous] ? nil : "jquery"

    output, compiler = normalize(input, output, name)
    compiler.to_cjs.sub(/\n*\z/, '').should == output
  end

  def should_compile_globals(input, output, options={})
    name = options.delete(:anonymous) ? nil : "jquery"

    output, compiler = normalize(input, output, name, options)
    compiler.to_globals.sub(/\n*\z/, '').should == output
  end

  def should_raise(input, message)
    compiler = JsModuleTranspiler::Compiler.new(input, 'jquery')

    lambda { compiler.to_amd }.should raise_error(JsModuleTranspiler::CompileError, message)
  end
end

RSpec.configure do |c|
  c.include JsModuleTranspiler::TestHelpers
end
