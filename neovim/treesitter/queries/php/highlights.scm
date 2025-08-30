;; extends

; (variable_name (name "$") @variable.php.dollar) @operator

"$" @operator
"new" @keyword.new
"self" @special.self
"static" @special.self
((name) @name (#eq? @name "this")) @special.self

