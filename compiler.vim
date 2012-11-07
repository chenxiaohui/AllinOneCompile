" Plugin: AllinOneCompile.vim
" a plugin to config the compile options of several kinds of file

"/* Copyright(C)
"* Chen Xiaohui (www.roybit.com)
"* mail:sdqxcxh@gmail.com
"* Thanks to Vimer, his blog(http://www.vimer.cn/?p=11) inspire me to write
"* this plugin and some codes are also from his blog
"* All rights reserved
"* version:1.0
"*/


"==========================================================================
"option	 	default	suboption	  	meaning
"			value				
"==========================================================================
"compile    'make'	win,unix..			the default compile command 
"ucompile	'make'	win,unix..			compile command when file encoding is utf8
"clean      'make'	win,unix..			the clean command 
"out		''		win,unix..			the output file type eg:png,pdf,this is
"											needed if symbol %> is used
"efm        ''		win,unix..			errorformat string
"inshell    0		win,unix..			whether the command is run in shell or via makeprg
"before		''		win,unix..			command before compile
"run		''		win,unix..			command run after compile
"arg		''		compile,run,debug	the parameters for run or compile
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

if (!exists('g:types'))
	let g:types={ 
				\'c':{'compile':'gcc -o %<.%> %','arg':{'compile':'-g'},'out':{'win':'exe','unix':'out'},
				\'run':{'win':'%<','unix':'./%<.%>'}},
				\'cpp':{'compile':'g++ -o %<.%> %','arg':{'compile':'-g'},'out':{'win':'exe','unix':'out'},
				\'run':{'win':'%<','unix':'./%<.%>'}},
				\'tex':{'compile':{'win':'pdflatexgbk.bat %<','unix':'pdflatex %<'},
				\'inshell':1, 'clean':'clear.bat %<','out':'pdf',
				\'ucompile':{'win':'pdflatexutf.bat %<','unix':'pdflatex %<'}}, 
				\'cs':{'compile':'csc /nologo /out:%<.%> %','efm':'%A%f(%l\\,%c):%m','out':'exe'},
				\'python':{'compile':{'win':'python %','unix':'python3 %'},'inshell':1},
				\'dot':{'compile':{'win':'dot.bat %< %>','unix':'dot -T%> % -o %<.%>'},'out':'png',
				\'run':{'win':'%<.%>','unix':'eog %<.%>'},'inshell':1},
				\'php':{'compile':'php %','inshell':1},
				\'java':{'compile':{'win':'java.bat %<'},'inshell':1},
				\'dosbatch':{'compile':'%','inshell':1},
				\}
endif 

if g:iswindows
	let s:os='win'
else 
	let s:os='unix'
endif

"Get(arg,default)
"if has the corresponding os option,return it
"else return the option string
"if cannot find the option,return default,no default return 0
"it's the same as GetEx(arg,s:os,default)
function! Get(...)
	let option=get(s:t,a:1) 

	if !empty(option)
		"exists the option
		if type(option)!=4
			"just a string	
			return option
		endif
		return get(option,s:os,get(a:000,1,0))
	else 
		return get(a:000,1,0)
	endif
endfunction

"GetEx(arg,suboption,default)
"if has the corresponding suboption ,return it
"else return the option string
"if cannot find the option,return default,no default return 0
function! GetEx(...)
	let option=get(s:t,a:1) 

	if !empty(option)
		"exists the option
		if type(option)!=4
			"just a string	
			return option
		endif
		return get(option,get(a:000,1,0),get(a:000,2,0))
	else 
		return get(a:000,2,0)
	endif
endfunction

function! CheckFile()
	execute "ccl"
	"if it's in current directory
	if expand("%:p:h")!=getcwd()
		echohl WarningMsg | echo "Fail to make! This file is not in the current dir! Press <F7> to redirect to the dir of this file." | echohl None
		return 0 
	endif
	"get source file name
	let g:sourcefileename=expand("%:t")
	"delete blanks
	let deletedspacefilename=substitute(g:sourcefileename,' ','','g')
	if strlen(deletedspacefilename)!=strlen(g:sourcefileename)
		echohl WarningMsg | echo "Fail to make! Please delete the spaces in the filename!" | echohl None
		return 0 
	endif
	"if the filetype of this file is in the support filetype list
	if (g:sourcefileename=="" || !count(keys(g:types),&ft))
		echohl WarningMsg | echo "Fail to make! Please select the right file!" | echohl None
		return 0
	endif
	return 1
endfunction

"compile one file
map <F5> :call Do_OneFileMake()<CR>
function! Do_OneFileMake()
	"check file
	if !CheckFile()
		return 
	endif

	"get the config of this filetype
	let s:t=get(g:types,&ft)

	"makeprg
	if !empty(Get('ucompile')) && &fileencoding=='utf-8'
		"has utfcmd and file type is utf-8
		let cmdtype='ucompile'
	else
		let cmdtype='compile'
	endif

	let cmd=substitute(Get(cmdtype,'make').' '.GetEx('arg','compile',''),'%<',expand('%<'),'g')
	let cmd=substitute(cmd,'%>',Get('out',''),'g')
	let cmd=substitute(cmd,'%',expand('%'),'g')

	"errorformat
	let &efm=&efm.','.Get('efm','')

	let outfilename=substitute(expand("%:t"),'\(\.[^.]*\)','.'.Get('out',''),'g')
	"delete existing file
	if !empty(Get('out','')) && filereadable(outfilename)
		let outdeletedsuccess=delete(outfilename)
		if outdeletedsuccess!=0
			echohl WarningMsg | echo "Fail to delete the existing output file ".outfilename."." | echohl None
			return
		endif
	endif

	"before compile command
	if !empty(Get('before',''))
		let beforecmd=substitute(Get('before',''),'%<',expand('%<'),'g')
		let beforecmd=substitute(beforecmd,'%>',Get('out',''),'g')
		let beforecmd=substitute(beforecmd,'%',expand('%'),'g')
		silent! execute "!".beforecmd
		if v:shell_error
			echohl WarningMsg | echo "Fail to execute before compile command. " | echohl None
			return
		endif
	endif


	"compile command 
	if Get('inshell',0)==1
		"in shell
		if !empty(Get('run',''))
			silent! execute "!".cmd
		else 
			execute "!".cmd
		endif
		if v:shell_error
			echohl WarningMsg | echo "Fail to compile." | echohl None
			return
		endif
	else
		"not in shell
		let &makeprg=cmd
		execute "silent make"
		set makeprg=make
		if len(getqflist())
			execute 'copen'
			execute "redraw!"
			return
		endif
	endif


	"debug
	"echo '********************************************'
	"if Get('inshell',0)==0
	"echo 'makeprg:'.&makeprg

	"else 
	"echo 'shellcmd:'.cmd
	"endif
	"let beforecmd=substitute(Get('before',''),'%<',expand('%<'),'g')
	"let beforecmd=substitute(beforecmd,'%>',Get('out',''),'g')
	"let beforecmd=substitute(beforecmd,'%',expand('%'),'g')
	"echo 'before:'.beforecmd
	"let runcmd=substitute(Get('run','').' '.GetEx('arg','run',''),'%<',expand('%<'),'g')
	"let runcmd=substitute(runcmd,'%>',Get('out',''),'g')
	"let runcmd=substitute(runcmd,'%',expand('%'),'g')
	"echo 'run:'.runcmd
	"if !empty(Get('out',''))
	"echo 'outfile:'.substitute(expand("%:t"),'\(\.[^.]*\)','.'.Get('out',''),'g')
	"endif
	"echo '********************************************'

	"has run command
	if !empty(Get('run',''))
		let runcmd=substitute(Get('run','').' '.GetEx('arg','run',''),'%<',expand('%<'),'g')
		let runcmd=substitute(runcmd,'%>',Get('out',''),'g')
		let runcmd=substitute(runcmd,'%',expand('%'),'g')
		execute "!".runcmd
	endif
	if !has("gui_running")
		silent! execute "redraw!"
	endif
endfunction


"execute the program
map <c-f5> :call Do_Execute()<CR>
function! Do_Execute()
	if !CheckFile()
		return 
	endif
	let s:t=get(g:types,&ft)
	if !empty(Get('run',''))
		let outfilename=substitute(expand("%:t"),'\(\.[^.]*\)','.'.Get('out',''),'g')
		if filereadable(outfilename)
			let runcmd=substitute(Get('run','').' '.GetEx('arg','run',''),'%<',expand('%<'),'g')
			let runcmd=substitute(runcmd,'%>',Get('out',''),'g')
			let runcmd=substitute(runcmd,'%',expand('%'),'g')
			execute "!".runcmd
		else 
			echohl WarningMsg | echo "Have no output file." | echohl None
		endif
	else 
			echohl WarningMsg | echo "Have no run command." | echohl None
	endif
endfunction

"clean 
map <c-F6> :call Do_Clean()<CR>
function! Do_Clean()
	if !CheckFile()
		return 
	endif
	let s:t=get(g:types,&ft)
	"has clean cmd
	if !empty(Get('clean','make clean'))
		let cleancmd=substitute(Get('clean',''),'%<',expand('%<'),'g')
		let cleancmd=substitute(cleancmd,'%>',Get('out',''),'g')
		let cleancmd=substitute(cleancmd,'%',expand('%'),'g')

		silent! execute "!".cleancmd
		if v:shell_error
			echohl WarningMsg | echo "Fail to clean." | echohl None
		else
			echo "Succeed in cleaning."		
		endif
	endif
endfunction


"make 
map <F6> :call Do_Make()<CR>
function! Do_Make()
	if !CheckFile()
		return 
	endif
	set makeprg=make
	silent! execute "silent make"
	if len(getqflist())
		execute 'copen'
		execute "redraw!"
		return
	endif
	echo 'Make succeed.'
endfunction

"调试
map <silent> <S-F5> :call Do_Debug()<cr> 
function! Do_Debug()
	if !CheckFile()
		return 
	endif

	let s:t=get(g:types,&ft)

	if !empty(Get('out',''))  
		let outfilename=substitute(expand("%:t"),'\(\.[^.]*\)','.'.Get('out',''),'g')
		if filereadable(outfilename)
			let debugcmd=substitute(Get('debug','gdb --args %<.%>').' '.GetEx('arg','debug',''),'%<',expand('%<'),'g')
			let debugcmd=substitute(debugcmd,'%>',Get('out',''),'g')
			let debugcmd=substitute(debugcmd,'%',expand('%'),'g')
			
			echohl WarningMsg | echo debugcmd | echohl None
			execute "!".debugcmd
		else
			echohl WarningMsg | echo "No output file to debug." | echohl None
		endif
	else
		let debugcmd=substitute(Get('debug','').' '.GetEx('arg','debug',''),'%<',expand('%<'),'g')
		let debugcmd=substitute(debugcmd,'%',expand('%'),'g')
		execute "!".debugcmd
	endif
endfunction

