(import-macros {: tx} :config.macros)

(local utils (require :config.utils))

[(tx "LazyVim/LazyVim" {:init (fn []
	(let [lazyroot (require :lazyvim.util.root)]

		(tset lazyroot.detectors "git" (fn [buf]
			(let [path (or (lazyroot.bufpath buf) (vim.uv.cwd))
				  git-roots (utils.get-git-toplevel-recursive path)]
				[ (. git-roots (length git-roots)) ])))

		(set vim.g.root_spec (utils.list-merge ["git"] vim.g.root_spec))))})]
