xrunnerpath := C:/programs/xrunner2
java := D:\programs\javafx\bin\java.exe
saxon := C:\programs\xrunner2\tools\saxon\saxon12he.jar
ccw := C:\programs\xrunner2\tools\cct\Ccw64.exe
green := [32m
reset := [0m
cyan := [36m


setup: $(CURDIR)/tmp $(CURDIR)/scripts $(CURDIR)/scripts/proj.cmd project-info.txt $(CURDIR)/projpath.make
	@echo $(green)Info: proj.cmd is up to date$(reset)


$(CURDIR)/tmp: 
	mkdir tmp

$(CURDIR)/scripts :
	mkdir scripts

# The following cct has three input files fed to the script: project.txt, xrun.ini, func.cmd

$(CURDIR)/scripts/proj.cmd: project.txt $(xrunnerpath)/setup/xrun.ini $(xrunnerpath)/scripts/func.cmd $(xrunnerpath)/scripts/setup2.cct
	@echo $(cyan)Updating proj.cmd$(reset)
	@call "$(ccw)" -u -b -q -n -t "$(xrunnerpath)\scripts\setup4.cct" -o "scripts\proj.cmd" -i $(xrunnerpath)\setup\proj-cmd.txt

project-info.txt:
	echo # Project Notes> project-info.txt

$(CURDIR)/projpath.make:
	@echo $(cyan)Creating the ES make files for each stage.$(reset)
	@echo projpath := %cd%> projpath.make

project.txt: ;

$(xrunnerpath)/setup/xrun.ini: ;

$(xrunnerpath)/scripts/func.cmd: ;


