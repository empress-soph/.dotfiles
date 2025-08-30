" Highlight trailing whitespace, spaces before a tab, and tabs not at the
" start of a line
highlight ExtraWhitespace guifg=red ctermfg=red guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
autocmd User Syntax syntax match ExtraWhitespace '\s\+$\|\ \+\ze\t\|[^\t]\zs\t\+'

" highlight Conceal ctermbg=none ctermfg=none guibg=none guifg=none
augroup conceal_symbols
	autocmd!
	autocmd User Syntax syntax keyword Greek alpha ALPHA conceal cchar=α containedin=ALL
	autocmd User Syntax syntax keyword Greek beta BETA conceal cchar=β containedin=ALL
	autocmd User Syntax syntax keyword Greek Gamma conceal cchar=Γ containedin=ALL
	autocmd User Syntax syntax keyword Greek gamma GAMMA conceal cchar=γ containedin=ALL
	autocmd User Syntax syntax keyword Greek Delta conceal cchar=Δ containedin=ALL
	autocmd User Syntax syntax keyword Greek delta DELTA conceal cchar=δ containedin=ALL
	autocmd User Syntax syntax keyword Greek epsilon EPSILON conceal cchar=ε containedin=ALL
	autocmd User Syntax syntax keyword Greek zeta ZETA conceal cchar=ζ containedin=ALL
	autocmd User Syntax syntax keyword Greek eta ETA conceal cchar=η containedin=ALL
	autocmd User Syntax syntax keyword Greek Theta conceal cchar=ϴ containedin=ALL
	autocmd User Syntax syntax keyword Greek theta THETA conceal cchar=θ containedin=ALL
	autocmd User Syntax syntax keyword Greek kappa KAPPA conceal cchar=κ containedin=ALL
	autocmd User Syntax syntax keyword Greek lambda LAMBDA lambda_ _lambda conceal cchar=λ containedin=ALL
	autocmd User Syntax syntax keyword Greek mu MU conceal cchar=μ containedin=ALL
	autocmd User Syntax syntax keyword Greek nu NU conceal cchar=ν containedin=ALL
	autocmd User Syntax syntax keyword Greek Xi conceal cchar=Ξ containedin=ALL
	autocmd User Syntax syntax keyword Greek xi XI conceal cchar=ξ containedin=ALL
	autocmd User Syntax syntax keyword Greek Pi conceal cchar=Π containedin=ALL
	autocmd User Syntax syntax keyword Greek rho RHO conceal cchar=ρ containedin=ALL
	autocmd User Syntax syntax keyword Greek sigma SIGMA conceal cchar=σ containedin=ALL
	autocmd User Syntax syntax keyword Greek tau TAU conceal cchar=τ containedin=ALL
	autocmd User Syntax syntax keyword Greek upsilon UPSILON conceal cchar=υ containedin=ALL
	autocmd User Syntax syntax keyword Greek Phi conceal cchar=Φ containedin=ALL
	autocmd User Syntax syntax keyword Greek phi PHI conceal cchar=φ containedin=ALL
	autocmd User Syntax syntax keyword Greek chi CHI conceal cchar=χ containedin=ALL
	autocmd User Syntax syntax keyword Greek Psi conceal cchar=Ψ containedin=ALL
	autocmd User Syntax syntax keyword Greek psi PSI conceal cchar=ψ containedin=ALL
	autocmd User Syntax syntax keyword Greek Omega conceal cchar=Ω containedin=ALL
	autocmd User Syntax syntax keyword Greek omega OMEGA conceal cchar=ω containedin=ALL
	autocmd User Syntax syntax keyword Greek nabla NABLA conceal cchar=∇ containedin=ALL
	autocmd User Syntax syntax keyword Greek nabla NABLA conceal cchar=∇ containedin=ALL

	autocmd User Syntax syntax match Type '\v<int(eger)?(\(|[^\s)\],:])@!' conceal cchar=ℤ containedin=ALL
	autocmd User Syntax syntax match Type '\v<float(\(|[^\s)\],:])@!' conceal cchar=ℝ containedin=ALL
	autocmd User Syntax syntax match Type '\v<complex(\(|[^\s)\],:])@!' conceal cchar=ℂ containedin=ALL
	autocmd User Syntax syntax match Type '\v<str(ing)?(\(|[^\s)\],:])@!' conceal cchar=𝐒 containedin=ALL
	autocmd User Syntax syntax match Type '\v<bool(ean)?(\(|[^\s)\],:])@!' conceal cchar=𝔹 containedin=ALL
augroup END
