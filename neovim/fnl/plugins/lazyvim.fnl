(import-macros {: tx} :config.macros)

(local utils (require :lib.utils))
(local git (require :lib.git))

[(tx "LazyVim/LazyVim" {:init (fn []
	(let [lazyroot (require :lazyvim.util.root)]

		(tset lazyroot.detectors "git" (fn [buf]
			(let [path (or (lazyroot.bufpath buf) (vim.uv.cwd))
				  git-roots (git.get-repo-dir-from-path-recursive path)]
				[ (. git-roots (length git-roots)) ])))

		(set vim.g.root_spec (utils.list.merge ["git"] vim.g.root_spec))))})]
