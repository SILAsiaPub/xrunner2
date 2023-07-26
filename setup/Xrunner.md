# Xrunner2

Xrunner2 is a GUI to run projects that would be batch files that may be simple transformations or complex projects. It is designed to have simpler and more consistent syntax than batch files and command line tools. While is was originally created to run XSLT trnasformation using Saxon, it can also run any command line tool.

Xrunner2 differes from Xrunner in that it is much faster to start. The original Xrunner always built aproject.xslt file, even if no XSLT transformation was needed. Now Xrunner2 only builds a project.xslt if that file is needed and is either missing or out of date.

Xrunner2 is all scripts. It can be modified at many points. The GUI HTA file is basically a HTML file with CSS, some Javascript and mostly VBScript. The Xrunner.cmd file is just a small collection of batch file functions that does the setup, command and control and then runs func.cmd. The majority of the content is in the func.cmd file that is a library of functions. More functions can be added to that if you need them.

When you click a button on Xrunner2 GUI it runs xrunner.cmd with a number of parameters. 
1. The location of the project.txt file.
2. The button that was pressed. One of a-z.
3. The informatin feed back level. The default is 2. Higher levels give more debugging information.
4. The last option pause causes the command window to pause otherwise a countdown of 30 secondes is started that will close the window.

Xrunner2 allows you to have serial tasks run, without the need to specify the input and output file names. That is handled for you. You can just reorder two tasks without needing to update the input and output files. See the [Examples section](#Examples).

All the variable and tasks and groups of tasks are contained in one project.txt file. Other variables can be stored in the lists.tsv file or key value paits stored in the keyvalue.tsv file.

The project.txt file is an INI like file. The variabels are kept in the `[variables]` section. This is a variable name followed by = followed by the value.
```
sourcexml=%projectpath%\source\data.xml
```

One key variable does not need to be created and that is `%projectpath%`. It is created for you.



## Examples

As an example running a XSLT transformation with Java and the Saxon JAR file looks like this:

```
%java% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%
```

But in Xrunner it looks like this:

```
t=:xslt %script% "%infile%" "%outfile%" %params%
```

But it can be even simplier if the input file is the output of the last task:

```
t=:xslt %script%
```

The input as taken from the previous tasks output and the new output file is named based on the script and the sequence of the task. The advantiage of this system is that tasks can be quickly rearranged in the order without the need to change the input and output file.

## Setting up a simple project

* You create a folder in the Projects folder. 
* Within that folder create a plain text file called project.txt.
* Create a `[variables]` section.
* Define your variables.

``` 
[variables]
title=This is the title that show on the top of Xrunner
sourcexml=%projectpath%\source\data.xml
outxml=%projectpath%\output\new-data.xml
```
* Create a section for your tasks `[a]`
* Define your task to run starting with the t=
* Then a `:` and the task type i.e. `xslt` 
* Then the script name and extension that is located in the `scripts` folder of the project.

``` 
[a]
button=Press this button to run this set of tasks
t=:xslt transfom.xslt "%sourcexml%"
t=:cct changetable.cct "" "%outxml%"
```

or it can be written

``` 
[b]
button=Press this button to run this set of tasks
t=:inputfile "%sourcexml%"
t=:xslt transfom.xslt
t=:cct changetable.cct
t=:outputfile "%outxml%" start
```

* In the first example `[a]`, looking at the line: `t=:xslt transfom.xslt "%sourcexml%"` this has no output file specified because the file naming will happen automatically. In the second `t=:cct changetable.cct "" "%outxml%"` the empty double quotes use the output from the previous task.
* The second example `[b]` demonstrates how you can just specify the start and end file and have the file passed to the next task without worrying about the naming. The output file can also be started by the relevant associated program by adding `start` as the second parameter.
* The number of sections for task groups is limited to `a-z`.
* You can specify sub tasks groups by starting them with a name that is not one of the `a-z` single letters `[subtask]`. This is handy when running a loop and passing a file to the same set of tasks.
```
[c]
b=rename files
t=:loopfiles renamefile "%projectpath%\source\*.sfm"

[renamefile]
t=:name "%~1"
t=:cmd "ren '%~1' '%name%.newext'" "" "%projectpath%\source"
```
- Following the ':loopfiles' we specify the name of the sub task group to run, then we specify the files to to be passed one at a time to the `[renamefile]`.
- In the `[renamefile]` group, first we get the filename with out the extension.
- Then we rename that file defined by `%~1` to its name and the new extension.
- Note after the :cmd there are three sets of double quotes.
  - First is the command to be run, THe singel quotes are converted to double quotes incase the file names have spaces in them.
  - Second the empty double quotes are where you check if the file exists. As it is empty that checking is not done.
  - The third double quotes specify where the command is to be run. If this is absent and the pathe is not spedified before the `%~1` then it will look where Xrunner2 is installed.