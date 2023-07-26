# Xrunner Documentation

## Index <a id="index"/>


[:appendfile](#appendfile)  
[:appendnumbparam](#appendnumbparam)  
[:calcnumbparam](#calcnumbparam)  
[:cct](#cct)  
[:checkdir](#checkdir)  
[:command](#command)  
[:command2file](#command2file)  
[:command2var](#command2var)  
[:copy](#copy)  
[:copy2usb](#copy2usb)  
[:date](#date)  
[:dec](#dec)  
[:detectdateformat](#detectdateformat)  
[:drivepath](#drivepath)  
[:echo](#echo)  
[:encoding](#encoding)  
[:fatal](#fatal)  
[:fb](#fb)  
[:funcend](#funcend)  
[:iconv](#iconv)  
[:ifexist](#ifexist)  
[:ifnotexist](#ifnotexist)  
[:inc](#inc)  
[:inccount](#inccount)  
[:infile](#infile)  
[:ini2xslt](#ini2xslt)  
[:iniline2var](#iniline2var)  
[:iniparse4xslt](#iniparse4xslt)  
[:inisection](#inisection)  
[:inputfile](#inputfile)  
[:jade](#jade)  
[:last](#last)  
[:loopfiles](#loopfiles)  
[:loopstring](#loopstring)  
[:main](#main)  
[:mergevar ](#mergevar )  
[:modelcheck](#modelcheck)  
[:name](#name)  
[:nameext](#nameext)  
[:outfile](#outfile)  
[:outputfile](#outputfile)  
[:paratextio](#paratextio)  
[:pause](#pause)  
[:prince](#prince)  
[:ptbook](#ptbook)  
[:regex](#regex)  
[:rho](#rho)  
[:setinfolevel](#setinfolevel)  
[:setup](#setup)  
[:spawnbat](#spawnbat)  
[:start](#start)  
[:start2](#start2)  
[:sub](#sub)  
[:taskgroup](#taskgroup)  
[:taskwritexrun](#taskwritexrun)  
[:test](#test)  
[:tidy](#tidy)  
[:time](#time)  
[:unittest](#unittest)  
[:unittestaccumulate](#unittestaccumulate)  
[:v2](#v2)  
[:validate](#validate)  
[:var](#var)  
[:variableset](#variableset)  
[:variableslist](#variableslist)  
[:xquery](#xquery)  
[:xslt](#xslt)  
## Function reference

- **_Initialize**
  - *Description:* xrun
  - *Project Usage:* `xrun C:\path\project.txt [group [infolevel [pauseatend [unittest]]]]`
  - *Internal Usage:* `xrun C:\path\project.txt [group [infolevel [pauseatend [unittest]]]]`
  - *Note:* Xrun requires a project file. The group parameter is normally a letter a-t but can be nothing. If nothing all groups are run.
- ** :appendfile**  <a id="appendfile" href="#top">index</a>
  - *Description:* Appends one file to the end of another file.
  - *Project Usage:* `t=: appendfile filetoadd filetoappendto`
  - *Internal Usage:* `call : appendfile filetoadd filetoappendto`
- ** :appendnumbparam**  <a id="appendnumbparam" href="#top">index</a>
  - *Description:* Append numbered parameters on the end of a given variable name. Used from a loop like :loopfiles.
  - *Project Usage:* `t=:appendnumbparam prepart-of-par-name seed-numb out_var_name`
  - *Internal Usage:* `call :appendnumbparam prepart-of-par-name seed-numb out_var_name`
- ** :calcnumbparam**  <a id="calcnumbparam" href="#top">index</a>
  - *Description:* Append numbered parameters on the end of a predefined %preaddnumbparam% string
  - *Project Usage:* `t=:calcnumbparam prepart-of-par-name seed-numb [value-to-add-or-subtract]`
  - *Internal Usage:* `call :calcnumbparam prepart-of-par-name seed-numb [value-to-add-or-subtract]`
  - *Note:* Default value to add or subtract is -0
- ** :cct**  <a id="cct" href="#top">index</a>
  - *Description:* Privides interface to CCW32.
  - *Project Usage:* `t=:cct script.cct ["infile.txt" ["outfile.txt"]]`
  - *Internal Usage:* `call :cct script.cct ["infile.txt" ["outfile.txt"]]`
  - *Depends on:* inccount, infile, outfile, funcend
  - *External program:* ccw32.exe https://software.sil.org/cc/
  - *Required variable:* ccw32
- ** :checkdir**  <a id="checkdir" href="#top">index</a>
  - *Description:* checks if dir exists if not it is created
  - *Project Usage:* `t=:checkdir C:\path\name.ext`
  - *Internal Usage:* `call :checkdir C:\path\name.ext`
- ** :command**  <a id="command" href="#top">index</a>
  - *Description:* A way of passing any commnand from a tasklist. It does not use infile and outfile.
  - *Project Usage:* `t=:usercommand "copy /y 'c:\patha\file.txt' 'c:\pathb\file.txt'" ["path to run command in" "output file to test for"]`
  - *Internal Usage:* `call :usercommand "copy /y 'c:\patha\file.txt' 'c:\pathb\file.txt'" ["path to run command in" "output file to test for"]`
  - *Depends on:* inccount, checkdir, funcend or any function
  - *External program:* May use any external program
  - *Note:* Single quotes get converted to double quotes before the command is used.
- ** :command2file**  <a id="command2file" href="#top">index</a>
  - *Description:* Used with commands that only give stdout, so they can be captued in a file.
  - *Project Usage:* `t=:command2file "command" "outfile" ["commandpath"]`
  - *Internal Usage:* `call :command2file "command" "outfile" ["commandpath"]`
  - *Depends on:* inccount, outfile, funcend or any function
  - *External program:* May call any external program
  - *Note:* This command does its own expansion of single quotes to double quotes so cannont be fed directly from a ifdefined or ifnotdefined. Instead define a task that is fired by the ifdefined.
- ** :command2var**  <a id="command2var" href="#top">index</a>
  - *Description:* creates a variable from the command line
  - *Project Usage:* `t=:command2var varname "command" "comment"`
  - *Internal Usage:* `call :command2var varname "command" "comment"`
- ** :copy**  <a id="copy" href="#top">index</a>
  - *Description:* Provides copying with exit on failure
  - *Project Usage:* `t=:copy infile outfile [append] [xcopy]`
  - *Internal Usage:* `call :copy infile outfile [append] [xcopy]`
  - *Depends on:* :infile, :outfile, :inccount :funcend
  - *Uddated:* 2018-11-03
- ** :copy2usb**  <a id="copy2usb" href="#top">index</a>
  - *Description:* Set up to cop files to USB drive and optionally format.
  - *Project Usage:* `t=:copy2usb source_path target_drive target_folder [format_first]`
  - *Internal Usage:* `call :copy2usb source_path target_drive target_folder [format_first]`
  - *Depends on:* external program xcopy (a part of Windows)
- ** :date**  <a id="date" href="#top">index</a>
  - *Description:* Returns multiple variables with date in three formats, the year in wo formats, month and day date.
  - *Required variables:* detectdateformat
  - *Created:* 2016-05-04
- ** :dec**  <a id="dec" href="#top">index</a>
  - *Description:* Decrease the number variable
  - *Project Usage:* `t=:dec varname`
  - *Internal Usage:* `call :dec varname`
- ** :detectdateformat**  <a id="detectdateformat" href="#top">index</a>
  - *Description:* Get the date format from the Registery: 0=US 1=AU 2=iso
  - *Project Usage:* `t=:detectdateformat`
  - *Internal Usage:* `call :detectdateformat`
- ** :drivepath**  <a id="drivepath" href="#top">index</a>
  - *Description:* returns the drive and path from a full drive:\path\filename
  - *Project Usage:* `t=:drivepath C:\path\name.ext|path\name.ext`
  - *Internal Usage:* `call :drivepath C:\path\name.ext|path\name.ext`
- ** :echo**  <a id="echo" href="#top">index</a>
  - *Description:* Echo a message
  - *Project Usage:* `t=:echo "message text"`
  - *Internal Usage:* `call :echo "message text"`
- ** :encoding**  <a id="encoding" href="#top">index</a>
  - *Description:* to check the encoding of a file
  - *Project Usage:* `t=:encoding file [validate-against]`
  - *Internal Usage:* `call :encoding file [validate-against]`
  - *Depends on:* :infile
  - *External program:* file.exe http://gnuwin32.sourceforge.net/
  - *Required variables:* encodingchecker
- ** :fatal**  <a id="fatal" href="#top">index</a>
  - *Description:* Used when fatal events occur
  - *Project Usage:* `t=:fatal %0 "message 1" "message 2"`
  - *Internal Usage:* `call :fatal %0 "message 1" "message 2"`
- ** :fb**  <a id="fb" href="#top">index</a>
  - *Description:* Used to give common feed back
- ** :funcend**  <a id="funcend" href="#top">index</a>
  - *Description:* Used with func that out put files. Like XSLT, cct, command2file
  - *Project Usage:* `t=:funcend %0`
  - *Internal Usage:* `call :funcend %0`
- ** :iconv**  <a id="iconv" href="#top">index</a>
  - *Description:* Converts files from CP1252 to UTF-8
  - *Project Usage:* `t=:iconv infile outfile OR t=:iconv file_nx inpath outpath`
  - *Internal Usage:* `call :iconv infile outfile OR call :iconv file_nx inpath outpath`
  - *Depends on:* infile, outfile, funcend
  - *External program:* iconv.exe http://gnuwin32.sourceforge.net/
- ** :ifexist**  <a id="ifexist" href="#top">index</a>
  - *Description:* 
  - *Project Usage:* `t=:ifexist testfile action`
  - *Internal Usage:* `call :ifexist testfile action`
  - *Depends on:* inccount
- ** :ifnotexist**  <a id="ifnotexist" href="#top">index</a>
  - *Description:* If a file or folder do not exist, then performs an action.
  - *Project Usage:* `t=:ifnotexist testfile action`
  - *Internal Usage:* `call :ifnotexist testfile action`
  - *Depends on:* inccount
- ** :inc**  <a id="inc" href="#top">index</a>
  - *Description:* Increase the number variable
  - *Project Usage:* `t=:inc varname`
  - *Internal Usage:* `call :inc varname`
- ** :inccount**  <a id="inccount" href="#top">index</a>
  - *Description:* Increments the count variable
  - *Project Usage:* `t=:inccount`
  - *Internal Usage:* `call :inccount`
- ** :infile**  <a id="infile" href="#top">index</a>
  - *Description:* If infile is specifically set then uses that else uses previous outfile.
  - *Project Usage:* `t=:infile "%file%" calling-func`
  - *Internal Usage:* `call :infile "%file%" calling-func`
  - *Depends on:* fatal
- ** :ini2xslt**  <a id="ini2xslt" href="#top">index</a>
  - *Description:* Convert ini file to xslt
  - *Project Usage:* `t=:ini2xslt file.ini output.xslt function sectionexit`
  - *Internal Usage:* `call :ini2xslt file.ini output.xslt function sectionexit`
  - *Depends on:* inccount, infile, outfile.
- ** :iniline2var**  <a id="iniline2var" href="#top">index</a>
  - *Description:* Sets variables from one section
  - *Project Usage:* `t=:variableset line sectionget`
  - *Internal Usage:* `call :variableset line sectionget`
  - *Unused:* 
- ** :iniparse4xslt**  <a id="iniparse4xslt" href="#top">index</a>
  - *Description:* Parse the = delimited data and write to xslt . Skips sections and can exit when
  - *Project Usage:* `t=:iniparse4xslt outfile sectionexit element att1name att1val att2name att2val`
  - *Internal Usage:* `call :iniparse4xslt outfile sectionexit element att1name att1val att2name att2val`
  - *Depends on:* inccount
- ** :inisection**  <a id="inisection" href="#top">index</a>
  - *Description:* Handles variables list supplied in a file.
  - *Project Usage:* `t=:variableslist inifile sectionget linefunc`
  - *Internal Usage:* `call :variableslist inifile sectionget linefunc`
  - *Unused:* 
- ** :inputfile**  <a id="inputfile" href="#top">index</a>
  - *Description:* Sets the starting file of a serial tasklist, by assigning it to the var outfile
  - *usage:* call :inputfile "drive:\path\file.ext"
- ** :jade**  <a id="jade" href="#top">index</a>
  - *Description:* Create html/xml from jade file (now pug) Still uses jade extension
  - *Project Usage:* `t=:jade "infile" "outfile"`
  - *Internal Usage:* `call :jade "infile" "outfile"`
  - *Depends on:* inccount, infile, outfile, nameext, name, funcend
  - *External program:* NodeJS npm program jade
- ** :last**  <a id="last" href="#top">index</a>
  - *Description:* Find the last parameter in a set of numbered params. Usually called by a loop.
  - *Project Usage:* `t=:last par_name number`
  - *Internal Usage:* `call :last par_name number`
- ** :loopfiles**  <a id="loopfiles" href="#top">index</a>
  - *Description:* Used to loop through a subset of files specified by the filespec from a single directory
  - *Project Usage:* `t=:loopfiles file_specs sub_name [param[3-9]]`
  - *Internal Usage:* `call :loopfiles file_specs sub_name [param[3-9]]`
  - *Depends on:* appendnumbparam, last, taskgroup. Can also use any other function.
- ** :loopstring**  <a id="loopstring" href="#top">index</a>
  - *Description:* Loops through a list supplied in a space separated string.
  - *Project Usage:* `t=:loopstring action "string" ["comment"]`
  - *Internal Usage:* `call :loopstring action "string" ["comment"]`
  - *Depends on:* appendnumbparam, last, taskgroup. Can also use any other function.
  - *Note:* action may have multiple parts
- ** :main**  <a id="main" href="#top">index</a>
  - *Description:* Main Loop, does setup and gets variables then runs group loops.
  - *Depends on:* :setup, :taskgroup and may use unittestaccumulate
- ** :mergevar **  <a id="mergevar " href="#top">index</a>
  - *Description:* Merge two numbered variable into one with a space between them
- ** :modelcheck**  <a id="modelcheck" href="#top">index</a>
  - *Description:* Copies in files from Model project
  - *Project Usage:* `t=:modelcheck "file.ext" "modelpath"`
  - *Internal Usage:* `call :modelcheck "file.ext" "modelpath"`
- ** :name**  <a id="name" href="#top">index</a>
  - *Description:* Returns a variable name containg just the name from the path.
- ** :nameext**  <a id="nameext" href="#top">index</a>
  - *Description:* Returns a variable nameext containg just the name and extension from the path.
- ** :outfile**  <a id="outfile" href="#top">index</a>
  - *Description:* If out file is specifically set then uses that else uses supplied name.
  - *Project Usage:* `t=:outfile "C:\path\file.ext" "%cd%\tmp\%script%.xml" nocheck`
  - *Internal Usage:* `call :outfile "C:\path\file.ext" "%cd%\tmp\%script%.xml" nocheck`
- ** :outputfile**  <a id="outputfile" href="#top">index</a>
  - *Description:* Copies last out file to new name. Used to make a static name other tasklists can use.
  - *Project Usage:* `:outputfile drive:\path\file.ext [start] [validate]`
  - *Internal Usage:* `:outputfile drive:\path\file.ext [start] [validate]`
  - *Depends on:* checkdir, funcend, validate
- ** :paratextio**  <a id="paratextio" href="#top">index</a>
  - *Description:* Loops through a list of books and extracts USX files.
  - *Project Usage:* `t=:paratextio project "book_list" [outpath] [write] [usfm]`
  - *Internal Usage:* `call :paratextio project "book_list" [outpath] [write] [usfm]`
  - *Depends on:* ptbook
- ** :pause**  <a id="pause" href="#top">index</a>
  - *Description:* Used in project.txt to pause the processing
- ** :prince**  <a id="prince" href="#top">index</a>
  - *Description:* Make PDF using PrinceXML
  - *Project Usage:* `t=:prince [infile [outfile [css]]]`
  - *Internal Usage:* `call :prince [infile [outfile [css]]]`
  - *Depends on:* infile, outfile, funcend
  - *External program:* prince.exe https://www.princexml.com/
  - *External program:* prince
- ** :ptbook**  <a id="ptbook" href="#top">index</a>
  - *Description:* Extract USX from Paratext
  - *Project Usage:* `t=:ptbook project book [outpath] [write] [usfm]`
  - *Internal Usage:* `call :ptbook project book [outpath] [write] [usfm]`
  - *Depends on:* outfile, funcend
  - *External program:* rdwrtp8.exe from https://pt8.paratext.org/
  - *Required variables:* rdwrtp8
- ** :regex**  <a id="regex" href="#top">index</a>
  - *Description:* Run a regex on a file
  - *Project Usage:* `t=:regex find replace infile outfile`
  - *Internal Usage:* `call :regex find replace infile outfile`
  - *Depends on:* inccount, infile, outfile, funcend
  - *External program:* rxrepl.exe https://sites.google.com/site/regexreplace/
- ** :rho**  <a id="rho" href="#top">index</a>
  - *Description:* Create xml from .rho file markup
  - *Project Usage:* `t=:rho infile outfile`
  - *Internal Usage:* `call :rho infile outfile`
  - *Depends on:* infile, outfile, funcend NodeJS NPM program Rho
  - *External program:* NodeJS npm program Rho
- ** :setinfolevel**  <a id="setinfolevel" href="#top">index</a>
  - *Description:* Used for initial setup and after xrun.ini and project.txt
  - *Project Usage:* `t=:setinfolevel numb-level`
  - *Internal Usage:* `call :setinfolevel numb-level`
  - *Note:* numb-level range 0-5
- ** :setup**  <a id="setup" href="#top">index</a>
  - *Description:* Sets up the variables and does some checking.
  - *Project Usage:* `t=:setup`
  - *Internal Usage:* `call :setup`
  - *Depends on:* variableslist, detectdateformat, ini2xslt, iniparse4xslt, setinfolevel, fatal
- ** :spawnbat**  <a id="spawnbat" href="#top">index</a>
  - *Depreciated:* 
- ** :start**  <a id="start" href="#top">index</a>
  - *Description:* Start a program but don't wait for it.
- ** :start2**  <a id="start2" href="#top">index</a>
  - *Description:* Start a program but don't wait for it.
- ** :sub**  <a id="sub" href="#top">index</a>
  - *Description:* Starts a sub loop, this is similar to taskgroup
  - *Project Usage:* `t=:sub "subname" ['param1' ['param2' ['param3' ['param4']]]]`
  - *Internal Usage:* `call :sub "subname" ['param1' ['param2' ['param3' ['param4']]]]`
  - *Depends on:* appendnumbparam and when unit testing: unittestaccumulate
- ** :taskgroup**  <a id="taskgroup" href="#top">index</a>
  - *Description:* Loop that triggers each task in the group.
  - *Project Usage:* `t=:taskgroup group`
  - *Internal Usage:* `call :taskgroup group`
  - *Depends on:* unittestaccumulate. Can depend on any procedure in the input task group.
- ** :taskwritexrun**  <a id="taskwritexrun" href="#top">index</a>
  - *Description:* Sets variables from one section
  - *Project Usage:* `t=:variableset line sectiontoexit`
  - *Internal Usage:* `call :variableset line sectiontoexit`
- ** :test**  <a id="test" href="#top">index</a>
  - *Description:* Used for unit testing
  - *Project Usage:* `t=:test val1 val2 valn report`
  - *Internal Usage:* `call :test val1 val2 valn report`
  - *Depends on:* calcnumbparam, last
- ** :tidy**  <a id="tidy" href="#top">index</a>
  - *Description:* Convert HTML to XHTML
  - *Project Usage:* `t=:tidy ["infile"] ["outfile"]`
  - *Internal Usage:* `call :tidy ["infile"] ["outfile"]`
  - *Depends on:* infile, outfile, inccount, funcend
  - *External program:* tidy.exe http://tidy.sourceforge.net/
  - *Required variables:* tidy
- ** :time**  <a id="time" href="#top">index</a>
  - *Description:* Retrieve time in several shorter formats than %time% provides
  - *Project Usage:* `t=:time`
  - *Internal Usage:* `call :time`
  - *Created:* 2016-05-05
- ** :unittest**  <a id="unittest" href="#top">index</a>
  - *Description:* Used for unit testing
  - *Project Usage:* `only used internally`
  - *Internal Usage:* `only used internally`
  - *Depends on:* setup,
- ** :unittestaccumulate**  <a id="unittestaccumulate" href="#top">index</a>
  - *Description:* Acumulate %utreturn% variables into a coma space separated list.
- ** :v2**  <a id="v2" href="#top">index</a>
  - *Depreciated:* no longer needed or used.
- ** :validate**  <a id="validate" href="#top">index</a>
  - *Description:* Validate an XML file
  - *Project Usage:* `t=:validate "xmlfile"`
  - *Internal Usage:* `call :validate "xmlfile"`
  - *Depends on:* External program 'xml.exe' from XMLstarlet http://xmlstar.sourceforge.net/
- ** :var**  <a id="var" href="#top">index</a>
  - *Description:* Set a variable within a taskgroup
  - *Project Usage:* `t=:var varname "varvalue"`
  - *Internal Usage:* `t=:var varname "varvalue"`
- ** :variableset**  <a id="variableset" href="#top">index</a>
  - *Description:* Sets variables sent from variableslist.
  - *Project Usage:* `t=:variableset line sectiontoexit`
  - *Internal Usage:* `call :variableset line sectiontoexit`
- ** :variableslist**  <a id="variableslist" href="#top">index</a>
  - *Description:* Handles variables list supplied in a file.
  - *Project Usage:* `t=:variableslist list varsetalt`
  - *Internal Usage:* `call :variableslist list varsetalt`
  - *Depends on:* :variableset
- ** :xquery**  <a id="xquery" href="#top">index</a>
  - *Description:* Provides interface to xquery by saxon9he.jar
  - *Project Usage:* `t=:xquery scriptname ["infile"] ["outfile"] [allparam]`
  - *Internal Usage:* `call :xquery scriptname ["infile"] ["outfile"] [allparam]`
  - *Depends on:* inccount, infile, outfile, funcend, fatal
  - *External program:* java.exe https://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html
  - *Java application:* saxon9he.jar https://sourceforge.net/projects/saxon/
  - *Required variables:* java saxon9
  - *created:* 2018-11-27
- ** :xslt**  <a id="xslt" href="#top">index</a>
  - *Description:* Runs Java with saxon to process XSLT transformations.
  - *Project Usage:* `t=:xslt script.xslt [input.xml [output.xml [parameters]]]`
  - *Internal Usage:* `call :xslt script.xslt [input.xml [output.xml [parameters]]]`
  - *Depends on:* inccount, infile, outfile, fatal, funcend
  - *External program:* java.exe https://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html
  - *Java application:* saxon9he.jar https://sourceforge.net/projects/saxon/
  - *Required variables:* java saxon9