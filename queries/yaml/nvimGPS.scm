; Mapping
((block_mapping_pair
    key: (flow_node) @mapping-name
    value: (block_node (block_mapping))) @scope-root)

; Sequence
((block_mapping_pair
    key: (flow_node) @sequence-name
    value: (block_node (block_sequence))) @scope-root)

; Null
((block_mapping_pair
    key: (flow_node) @null-name
    value: (flow_node (plain_scalar (null_scalar)))) @scope-root)

; Boolean
((block_mapping_pair
    key: (flow_node) @boolean-name
    value: (flow_node (plain_scalar (boolean_scalar)))) @scope-root)

; Integer
((block_mapping_pair
    key: (flow_node) @integer-name
    value: (flow_node (plain_scalar (integer_scalar)))) @scope-root)

; Float
((block_mapping_pair
    key: (flow_node) @float-name
    value: (flow_node (plain_scalar (float_scalar)))) @scope-root)

; String
((block_mapping_pair
    key: (flow_node) @string-name
    value: (flow_node (double_quote_scalar))) @scope-root)

((block_mapping_pair
    key: (flow_node) @string-name
    value: (flow_node (single_quote_scalar))) @scope-root)

((block_mapping_pair
    key: (flow_node) @string-name
    value: (flow_node (plain_scalar (string_scalar)))) @scope-root)
