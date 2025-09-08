(import-macros {: tx} :config.macros)

(fn list-merge [...]
	(let [merged-list []]
		(for [i 1 (select :# ...)]
			(let [list (select i ...)]
					(each [_ item (ipairs list)]
						(table.insert merged-list item))))))

[(tx "saghen/blink.cmp"
	 {:opts
		{:signature {:enabled true}
		 :keymap {:preset "enter"
		          :<Tab>   [:select_next :fallback]
		          :<S-Tab> [:select_prev :fallback]}}})]

