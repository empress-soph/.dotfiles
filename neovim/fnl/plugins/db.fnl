(import-macros {: tx} :config.macros)

[(tx "kristijanhusak/vim-dadbod-ui"
	{:opts {}
	 :dependencies [(tx "tpope/vim-dadbod" {:lazy true})
	                (tx "kristijanhusak/vim-dadbod-completion" {:lazy true :ft ["sql" "mysql" "plsql"]})]
	 :cmd ["DBUI" "DBUIToggle" "DBUIAddConnection" "DBUIFindBuffer"]})]
