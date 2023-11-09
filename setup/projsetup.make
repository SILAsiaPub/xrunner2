xrunnerpath := C:/programs/xrunner2
java := D:\programs\javafx\bin\java.exe
saxon := C:\programs\xrunner2\tools\saxon\saxon12he.jar
ccw := C:\programs\xrunner2\tools\cct\Ccw64.exe
green := [32m
reset := [0m
cyan := [36m


setup: tmp scripts $(CURDIR)\scripts $(CURDIR)/scripts/proj.cmd
	@echo $(green)Info: proj.cmd is up to date$(reset)


tmp: 
	mkdir %cd%\tmp

scripts :
	mkdir %cd%\scripts

$(CURDIR)/scripts/proj.cmd: project.txt $(xrunnerpath)/setup/xrun.ini $(xrunnerpath)/scripts/func.cmd $(xrunnerpath)\scripts\setup2.cct
	@echo $(cyan)Updating proj.cmd$(reset)
	@call "$(ccw)" -u -b -q -n -t "$(xrunnerpath)\scripts\setup2.cct" -o "scripts\proj.cmd" -i $(xrunnerpath)\setup\proj-cmd.txt

project.txt: ;

$(xrunnerpath)/setup/xrun.ini: ;

$(xrunnerpath)/scripts/func.cmd: ;
