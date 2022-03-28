;; Sectioning
((chapter
  command: _
  text: (curly_group
          (_) @title-name)) @scope-root)

((part
  command: _
  text: (curly_group
          (_) @title-name)) @scope-root)

((section
  command: _
  text: (curly_group
          (_) @title-name)) @scope-root)

((subsection
  command: _
  text: (curly_group
          (_) @title-name)) @scope-root)

((subsubsection
  command: _
  text: (curly_group
          (_) @title-name)) @scope-root)

((paragraph
  command: _
  text: (curly_group
          (_) @title-name)) @scope-root)

((subparagraph
  command: _
  text: (curly_group
          (_) @title-name)) @scope-root)

;; Labeled environments
((generic_environment
  (label_definition
    name: (curly_group_text
            (_) @label-name))) @scope-root)
