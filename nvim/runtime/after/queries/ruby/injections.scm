; extends

(
  (call
    receiver: (identifier) @receiver
    method: (identifier) @method
    arguments: (argument_list
      (pair
        key: (hash_key_symbol)
        value: (string (string_content) @injection.content))))
  (#eq? @receiver "binding")
  (#eq? @method "b")
  (#set! injection.language "ruby")
)
