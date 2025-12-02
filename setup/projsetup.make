
ccw := $(xrunnerpath)\tools\cct\Ccw64.exe
green := [32m
reset := [0m
cyan := [36m


$(projpath)/setup: $(projpath)/tmp $(projpath)/scripts $(projpath)/scripts/proj.cmd $(projpath)/project-info.txt
	@echo $(green)Info: Project is up to date$(reset)


$(projpath)/tmp: 
	mkdir tmp

$(projpath)/scripts:
	mkdir scripts

# The following cct has three input files fed to the script: project.txt, xrun.ini, func.cmd

$(projpath)/scripts/proj.cmd: project.txt $(xrunnerpath)/setup/xrun.ini $(xrunnerpath)/scripts/func.cmd $(xrunnerpath)/scripts/setup-proj-cmd.cct
	@echo $(cyan)Updating proj.cmd$(reset)
	@call "$(ccw)" -u -b -q -n -t "$(xrunnerpath)\scripts\setup-proj-cmd.cct" -o $(projpath)/scripts/proj.cmd -i $(xrunnerpath)\setup\proj-cmd.txt

$(projpath)/project-info.txt:
	echo # Project Notes> project-info.txt

$(projpath)/project.txt: ;

$(xrunnerpath)/setup/xrun.ini: ;

$(xrunnerpath)/scripts/func.cmd: ;

$(xrunnerpath)/scripts/setup2.cct: ;
