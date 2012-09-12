AllinOneCompile
===============

A vim plugin to config the compile options of all kinds of file

"==========================================================================
"option	 	default	suboption	  	meaning
"			value
"==========================================================================
"compile    'make'	win,unix..		the default compile command
"ucompile	'make'	win,unix..		compile command when file encoding is utf8
"clean      'make'	win,unix..		the clean command
"out		''		win,unix..		the output file type eg:png,pdf. This is
"										needed if symbol %> is used
"efm        ''		win,unix..		errorformat string
"inshell    0		win,unix..		whether the command is run in shell or via makeprg.
"before		''		win,unix..		command before compile
"run		''		win,unix..		command run after compile
"arg		''		compile,run		the parameters for run or compile
"debug		''		win,unix
"==========================================================================

"Attention: the args should be write like This
"			{'arg':{'win':'xx','linux':'xx'}} or {'arg':'xx'}
"			the former means set options for each kind of operation system,
"			while the later means the option for each operation system is the
"			same.You can omit any option, which means use default value for
"			this option.
"			
"Note:		In command option(compile,ucompile,clean,before,run) you can use
"			symbol %  which means filename with extension, eg:test.pdf
"			symbol %< which means filename without extension, eg:test
"			symbol %> which means output file type, eg:png,pdf
"			if symbol %> is used you should assign the option "out"


