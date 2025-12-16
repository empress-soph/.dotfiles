(import-macros {: tx} :config.macros)

[(tx "saghen/blink.cmp"
	 {:opts
		{:signature {:enabled true}
		 :completion {:list {:selection {:preselect false :auto_insert true}}}
		 :keymap {:preset "enter"
		          :<Tab>   [:select_next :fallback]
		          :<S-Tab> [:select_prev :fallback]}}})]

