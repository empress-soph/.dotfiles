;; [nfnl-macro]

(fn tx [& args]
  "Mixed sequential and associative tables at compile time. Because the Neovim ecosystem loves them but Fennel has no neat way to express them (which I think is fine, I don't like the idea of them in general)."
  (let [to-merge (when (table? (. args (length args)))
                   (table.remove args))]
    (if to-merge
      (do
        (each [key value (pairs to-merge)]
          (tset args key value))
        args)
      args)))

(fn if-let [[name value & rest] body1 ...]
  (assert body1 "expected body")
  (if (not name)
      `(do ,body1 ,...)
  `(let [,name (-?>> ,value)]
     (if ,name
          (if-let ,rest ,body1 ,...)))))

(fn if-let-else [assignments if-expr else-expr]
  (assert if-expr "expected expression")
  (assert else-expr "expected else expression")
  `(do
     (var eval-else?# true)
     (var return-value# nil)
     (if-let ,assignments
      (set eval-else?# false)
      (set return-value# (do ,if-expr)))
     (if eval-else?#
       (set return-value# (do ,else-expr)))
    return-value#))

{: tx : if-let : if-let-else}
