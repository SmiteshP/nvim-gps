; Function Definition
((signature
  name: (variable) @function-name) @scope-root)

; Function 
((function
   name: (variable) @function-name) @scope-root)

; Operator Definition
((signature
  name: (operator) @operator-name) @scope-root)

; Operator 
((function
   infix: (infix op: (varop) @operator-name)) @scope-root)

; Operator in Where Clause
((function
   name: (operator) @operator-name) @scope-root)

; Data 
((adt 
   name: (type) @class-name) @scope-root)

; Constructors
((data_constructor
   (constructor) @method-name) @scope-root)

; Record Field
((field 
   (variable) @method-name) @scope-root)

; Newtype
((newtype
   name: (type) @class-name) @scope-root)

; Instance
((instance 
   (instance_head) @class-name) @scope-root)

; TypeClass
((class
   (class_head
     class: (class_name) @class-name)) @scope-root)
    
   
