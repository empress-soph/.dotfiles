; TODO make this take a variable number of lists as arguments
(fn list-merge [a b]
	(vim.list_extend (vim.deepcopy a) b))

{: list-merge}
