AllinOneCompile
===============

 A vim plugin to config the compile options of all kinds of file. 
 You can fill a sturct and tell vim which command to use when deal with this kind of file,
 and vim will use this command to compile/run/debug it.Default key bind is F5/F6

##Copyright(C)

 Chen Xiaohui (www.roybit.com)

 mail:sdqxcxh@gmail.com

 Thanks to Vimer, his blog<http://www.vimer.cn/?p=11> inspire me to write

 this plugin and some codes are also from his blog

 All rights reserved

 version:1.1

##Option Meanings:

	==========================================================================
	option	 	default	suboption	  	meaning
				value				
	==========================================================================
	compile    'make'	win,unix..			the default compile command 
	ucompile	'make'	win,unix..			compile command when file encoding is utf8
	clean      'make'	win,unix..			the clean command 
	out		''		win,unix..			the output file type eg:png,pdf,this is
												needed if symbol %> is used
	efm        ''		win,unix..			errorformat string
	inshell    0		win,unix..			whether the command is run in shell or via makeprg
	before		''		win,unix..			command before compile
	run		''		win,unix..			command run after compile
	arg		''		compile,run,debug	the parameters for run or compile
	==========================================================================

##Attention: 

the args should be write like This `{'arg':{'win':'xx','linux':'xx'}}` or `{'arg':'xx'`}

the former means set options for each kind of operation system, while the later means the option for each operation system is the same.

You can omit any option, which means use default value for this option.
			
##Note:		
In command option(compile,ucompile,clean,before,run) you can use symbol %  which means filename with extension, eg:test.pdf

> symbol %< which means filename without extension, eg:test

> symbol %> which means output file type, eg:png,pdf

> if symbol %> is used you should assign the option "out"

##Samples:

	let g:types={
				\'c':{'compile':'gcc -o %<.%> %','arg':{'compile':'-g'},'out':{'win':'exe','unix':'out'},
				\'run':{'win':'%<','unix':'./%<.%>'},'clean':'rm %<.%>'},
				\'cpp':{'compile':'g++ -o %<.%> %','arg':{'compile':'-g'},'out':{'win':'exe','unix':'out'},
				\'run':{'win':'%<','unix':'./%<.%>'},'clean':'rm %<.%>'},
				\'tex':{'compile':'xelatex %','inshell':1, 'clean':'rm *.aux *.log *.out','out':'pdf'},
				\'cs':{'compile':'csc /nologo /out:%<.%> %','efm':'%A%f(%l\\,%c):%m','out':'exe'},
				\'python':{'compile':'python %','inshell':1,'debug':'python -m pdb %','arg':'file.tst'},
				\'dot':{'compile':{'win':'dot.bat %< %>','unix':'dot -T%> % -o %<.%>'},'out':'png',
				\'run':{'unix':'eog %<.%>'},'inshell':1},
				\'php':{'compile':'php %','inshell':1},
				\'java':{'compile':{'win':'java.bat %<'},'inshell':1},
				\'dosbatch':{'compile':'%','inshell':1},
				\'sh':{'compile':'./%','inshell':1},
				\'xhtml':{'compile':'%','inshell':1},
				\}

	
