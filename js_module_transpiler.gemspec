# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'js_module_transpiler/version'

Gem::Specification.new do |gem|
  gem.name          = "js_module_transpiler"
  gem.version       = JsModuleTranspiler::VERSION
  gem.authors       = ["Yehuda Katz"]
  gem.email         = ["wycats@gmail.com"]
  gem.description   = %q{Transpiles in-progress ES6 module syntax to AMD and CommonJS modules}
  gem.summary       = %q{The next version of JavaScript, ES6, will have modules built in. This gem transpiles a subset of the in-progress module syntax into AMD and CommonJS modules. AMD modules are somewhat popular for browser JavaScript, and CommonJS packages are the format used by Node.js.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "thor"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "simplecov"
end
