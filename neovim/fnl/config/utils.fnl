(fn list_merge [...]
	(let [merged-list []]
		(for [i 1 (select :# ...)]
			(let [list (select i ...)]
					(each [_ item (ipairs list)]
						(table.insert merged-list item))))))
