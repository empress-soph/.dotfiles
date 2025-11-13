{
	lso = {
		description = "ls -la but with octal file permissions";
		body = "ls -lA $argv | awk '{k=0;for(i=0;i<=8;i++)k+=((substr($1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(\" %0o \",k);print}'";
	};

	md5sum = { body = "md5 -r \"$argv\""; };

	fish_title = { body = builtins.readFile ./fish_title.fish; };

	update_cwd_git_variables = {
		body = builtins.readFile ./update_cwd_git_variables.fish;
	};
}
