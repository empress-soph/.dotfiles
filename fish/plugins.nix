{ pkgs, utils, ... }:

[
	{
		name = "bass";
		src = utils.fetchgit {
			url = "https://github.com/edc/bass.git";
			rev = "79b62958ecf4e87334f24d6743e5766475bcf4d0";
			hash = "sha256-3d/qL+hovNA4VMWZ0n1L+dSM1lcz7P5CQJyy+/8exTc=";
		};
	}

	{
		name = "async-prompt";
		src = utils.fetchgit {
			# url = "https://github.com/acomagu/fish-async-prompt.git";
			# rev = "316aa03c875b58e7c7f7d3bc9a78175aa47dbaa8";
			# hash = "sha256-J7y3BjqwuEH4zDQe4cWylLn+Vn2Q5pv0XwOSPwhw/Z0=";
			url = "https://github.com/infused-kim/fish-async-prompt.git";
			rev = "07e107635e693734652b0709dd34166820f1e6ff";
			hash = "sha256-rE80IuJEqnqCIE93IzeT2Nder9j4fnhFEKx58HJUTPk=";
		};
	}

	{
		name = "refresh-prompt-on-cmd";
		src = utils.fetchgit {
			url = "https://github.com/infused-kim/fish-refresh-prompt-on-cmd.git";
			rev = "main";
			hash = "sha256-y0fX+tpMSG6uOYS0J9fplbZKKyiebqgTgC130LVHZGw=";
		};
	}

	{
		name = "z";
		src = utils.fetchgit {
			url = "https://github.com/jethrokuan/z.git";
			rev = "067e867debee59aee231e789fc4631f80fa5788e";
			hash = "sha256-emmjTsqt8bdI5qpx1bAzhVACkg0MNB/uffaRjjeuFxU=";
		};
	}

	{
		name = "fish-ssh-agent";
		src = utils.fetchgit {
			url = "https://github.com/danhper/fish-ssh-agent.git";
			rev = "f10d95775352931796fd17f54e6bf2f910163d1b";
			hash = "sha256-cFroQ7PSBZ5BhXzZEKTKHnEAuEu8W9rFrGZAb8vTgIE=";
		};
	}

	{
		name = "autopair";
		src = utils.fetchgit {
			url = "https://github.com/jorgebucaran/autopair.fish.git";
			rev = "4d1752ff5b39819ab58d7337c69220342e9de0e2";
			hash = "sha256-qt3t1iKRRNuiLWiVoiAYOu+9E7jsyECyIqZJ/oRIT1A=";
		};
	}

	{
		name = "sponge";
		src = utils.fetchgit {
			url = "https://github.com/meaningful-ooo/sponge.git";
			rev = "384299545104d5256648cee9d8b117aaa9a6d7be";
			hash = "sha256-MdcZUDRtNJdiyo2l9o5ma7nAX84xEJbGFhAVhK+Zm1w=";
		};
	}

	{
		name = "puffer-fish";
		src = utils.fetchgit {
			url = "https://github.com/nickeb96/puffer-fish.git";
			rev = "12d062eae0ad24f4ec20593be845ac30cd4b5923";
			hash = "sha256-2niYj0NLfmVIQguuGTA7RrPIcorJEPkxhH6Dhcy+6Bk=";
		};
	}

	{
		name = "projectdo";
		src = utils.fetchgit {
			url = "https://github.com/paldepind/projectdo.git";
			rev = "d3747dd0a1da501f28cc6969d7509042eec4ef14";
			hash = "sha256-17rODM82pt8IdzBeRVQSGJqQo9DAJl1qO9RvFX6zRGA=";
		};
	}
]
