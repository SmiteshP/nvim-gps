(module [
  (scope_resolution)
  (constant)
] @container-name) @scope-root

(class
  (constant) @class-name) @scope-root

(class
  (scope_resolution (constant)) @class-name) @scope-root

(singleton_method
  (identifier) @function-name) @scope-root

(method
  (identifier) @method-name) @scope-root
