(fn list-find-index [list value]
	(each [i v (ipairs list)]
		(when (= v (if (= (type value) "function") (value v)
		                                           value))
			(lua "return i")))
	false)

(fn list-contains? [list value]
	(~= (list-find-index list value) false))

(fn list-find [list value]
	(let [index (list-find-index list value)]
		(if index (. list index))))

(fn list-merge [list-1 list-2]
	(vim.list_extend (vim.deepcopy list-1) list-2))

(fn list-slice [list start end]
	[(unpack list start end)])

(fn list-unique [list]
	(local deduped [])

	(each [_ entry (ipairs list)]
		(when (not (list-contains? deduped entry))
			(table.insert deduped entry)))

	deduped)

(fn str-split [str pattern]
	(local strs [])

	(each [substr (str:gmatch pattern)]
		(table.insert strs substr))

	(if (> (length strs) 0) strs
	                        [str]))

(fn str-trim [str patterns]
	(let [patterns (if (and patterns (= (type patterns) :table)) patterns
	                  patterns [patterns]
	                  ["%s"])]
		(var ret str)
		(each [_ pattern (ipairs patterns)]
			(set ret (ret:match (.. "^" pattern "*(.-)" pattern "*$"))))

		ret))

(fn str-lcfirst [str]
	(str:gsub "^%s*%a" string.lower))

(fn str-ucfirst [str]
	(str:gsub "^%s*%a" string.upper))

(fn is-subdir? [parent child]
	(let [relpath (vim.fs.relpath parent child)]
		(and (not (= relpath nil))
			(not (= relpath ".")))))

{:list
	{:find-index list-find-index
	 :contains? list-contains?
	 :find list-find
	 :merge list-merge
	 :slice list-slice
	 :unique list-unique}
 :string
	{:split str-split
	 :trim str-trim
	 :lcfirst str-lcfirst
	 :ucfirst str-ucfirst}
 :fs {: is-subdir?}}
