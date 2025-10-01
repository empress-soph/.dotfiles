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

(fn parse-text-table [header body]
	(local columns [])
	(var i 1)
	(while (< i (length header))
		(local (start end) (header:find "[^%s]+ *" i))
		(when (and start end)
			(local name (-> (header:sub start end)
				(str-trim)
				(str-lcfirst)))
			(table.insert columns {:name name :start start :end end}))
		(set i (+ (or end i) 1)))

	(local tbl [])
	(each [_ line (ipairs body)]
		(local row {})
		(each [_ column (ipairs columns)]
			(local value (str-trim (line:sub column.start column.end)))
			(tset row column.name value))
		(table.insert tbl row))

	tbl)

(fn get-digit-range-regexp [lower-bound upper-bound]
	(let [lower (math.max 0 (math.min 9 (tonumber (or lower-bound 0))))
		  upper (math.max 0 (math.min 9 (tonumber (or upper-bound 9))))]

		(if (= lower upper) (tostring lower)
			(.. "[" lower "-" upper "]"))))

(fn generate-number-upper-bound-regexp [number]
	(local regexps [])
	(local number-str (tostring number))
	(local reversed (number-str:reverse))

	(for [i 1 (length number-str)]
		(when (or (not (= (reversed:sub i i) "0")))
		          (= i 1)
			(for [j 1 (length number-str)]
				(local digit (reversed:sub j j))

				(let [regexp (if (and (= i 1) (= j 1)) (get-digit-range-regexp 0 digit)
				                 (= j i) (get-digit-range-regexp 0 (- digit 1))
				                 (< j i) (get-digit-range-regexp 0 9)
				                 digit)]
						(tset regexps i (.. regexp (or (?. regexps i) "")))))))

	(table.concat (icollect [_ regexp (pairs regexps)] regexp) "|"))

(fn generate-number-lower-bound-regexp [number]
	(local regexps [])
	(local number-str (tostring number))
	(local reversed (number-str:reverse))

	(for [i 1 (length number-str)]
		(when (or (not (= (reversed:sub i i) "0")))
		          (= i 1)
			(for [j 1 (length number-str)]
				(local digit (reversed:sub j j))

				(let [regexp (if (and (= i 1) (= j 1)) (get-digit-range-regexp digit 9)
				                 (= j i) (get-digit-range-regexp (- digit 1) 9)
				                 (< j i) (get-digit-range-regexp 0 9)
				                 digit)]
						(tset regexps i (.. regexp (or (?. regexps i) "")))))))

	(table.concat (icollect [_ regexp (pairs regexps)] regexp) "|"))

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
 :regexp
	{: generate-number-lower-bound-regexp
	 : generate-number-upper-bound-regexp}
 :fs
	{: is-subdir?}
 :misc
	{: parse-text-table}}
