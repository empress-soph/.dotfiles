(fn contains? [tbl value]
	(each [_ v (ipairs tbl)]
		(when (= value v)
			(lua "return true")))
	false)

(fn list-merge [a b]
	(vim.list_extend (vim.deepcopy a) b))

(fn is-subdir? [parent child]
	(let [relpath (vim.fs.relpath parent child)]
		(and (not (= relpath nil))
			(not (= relpath ".")))))

{: contains?
 : list-merge
 : is-subdir?}
