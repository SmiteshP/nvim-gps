## How does the nvim-gps work?

From the current node under our cursor, it travels up the tree towards its root. On the way up, it looks for a hint whether the current node has a "name" to be captured. That hint is provided by the scope-root capture.
When it sees that the current node is captured as a scope-root, it looks at the next capture (class-name, function-name or method-name) and then outputs the text of that next captured node.

To better understand this, lets look at the following example query for C++.

```scm
((class_specifier
	name: (type_identifier) @class-name
	body: (field_declaration_list)) @scope-root)
```
Here, the top level node ("class_specifier") is captured as a "scope-root". This indicates that, we have to look for some name under this node. So the next node captured is the "type_identifier" which actually has the text of class name. It gets captured as class-name, and thus accordingly the suitable icon is appended to the name of the node before outputting it.

You can learn more about how to write a tree-sitter query over [here](https://tree-sitter.github.io/tree-sitter/using-parsers#query-syntax).
Also, you may find using [playground](https://github.com/nvim-treesitter/playground) very helpful.
