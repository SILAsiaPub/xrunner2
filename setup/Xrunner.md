# Xrunner

Xrunner is a GUI to run projects that would be batch files that may be simple transformations or complex projects. It is setup to run XSLT transformations but can run any commandline tool. It is designed to have simpler and more consistent syntax than batch files.

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
[a]
button=Press this button to run this set of tasks
t=:inputfile "%sourcexml%"
t=:xslt transfom.xslt
t=:cct changetable.cct
t=:outputfile "%outxml%" start
```

* In the of the first task `t=:xslt transfom.xslt "%sourcexml%"` example has no output file specified because the file naming will happen automatically. In the second `t=:cct changetable.cct "" "%outxml%"` the empty double quotes use the output from the previous task.
* The second example demonstrates how you can just specify the start and end file and have the file passed to the next task without worrying about the naming. The output file can also be started by the relevant associated program by adding `start` as the second parameter.
* The number of sections for task groups is limited to `a-z` but if you adjust the `taskgroup=` variable in `setup\xrun.ini` you could add more groups by adding ` aa ab ac` etc to the end of the list.