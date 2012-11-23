unless ENV["TRAVIS"]
  require 'simplecov'
  SimpleCov.start do
    add_group "lib", "lib"
    add_group "spec", "spec"
  end
end

require 'js_module_transpiler'
