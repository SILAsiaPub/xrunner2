xrunnerpath := C:/programs/xrunner2
java := D:\programs\javafx\bin\java.exe
saxon := C:\programs\xrunner2\tools\saxon\saxon12he.jar
ccw := C:\programs\xrunner2\tools\cct\Ccw64.exe
green := [32m
reset := [0m
cyan := [36m

files := tmp/proj-var.xml lists.tsv keyvalue.tsv $(xrunnerpath)/scripts/projectvariables-v2.xslt scripts/inc-lookup.xslt scripts/inc-file2uri.xslt scripts/inc-copy-anything.xslt scripts/xrun.xslt

createxslt: scripts/project.xslt
	@echo $(green)Info: project.xslt is up to date$(reset)
	@echo.

scripts/project.xslt: $(files)
	@echo $(cyan)Rebuilding: project.xslt$(reset)
	@call "$(java)" -jar "$(saxon)" -o:"scripts\project.xslt" "tmp\proj-var.xml" "$(xrunnerpath)\scripts\projectvariables-v2.xslt" projectpath=${CURDIR} USERPROFILE="$(USERPROFILE)"

tmp/proj-var.xml: project.txt
	@if not exist "tmp\" md "tmp\"
	@echo $(cyan)Rebuilding: proj-var.xml$(reset)
	@call "$(ccw)" -u -b -q -n -t "$(xrunnerpath)\scripts\proj-var.cct" -o "tmp\proj-var.xml" "project.txt"

scripts/inc-lookup.xslt: $(xrunnerpath)/scripts/inc-lookup.xslt
	@echo $(cyan)Adding: inc-lookup.xslt into project$(reset)
	@copy "$(xrunnerpath)\scripts\inc-lookup.xslt" "${CURDIR}\scripts\" > nul

scripts/inc-file2uri.xslt: $(xrunnerpath)/scripts/inc-file2uri.xslt
	@echo $(cyan)Adding: inc-file2uri.xslt into project$(reset)
	@copy "$(xrunnerpath)\scripts\inc-file2uri.xslt" "${CURDIR}\scripts\" > nul

scripts/inc-copy-anything.xslt: $(xrunnerpath)/scripts/inc-copy-anything.xslt
	@echo $(cyan)Adding: inc-copy-anything.xslt into project$(reset)
	@copy "$(xrunnerpath)\scripts\inc-copy-anything.xslt" "${CURDIR}\scripts\" > nul

scripts/xrun.xslt: $(xrunnerpath)\scripts\xrun.xslt
	@echo $(cyan)Adding: xrun.xslt into project$(reset)
	@copy "$(xrunnerpath)\scripts\xrun.xslt" "${CURDIR}\scripts\" > nul

$(xrunnerpath)\scripts\xrun.xslt: $(xrunnerpath)\setup\xrun.ini
	@echo $(cyan)Updated: xrun.xslt$(reset)
	@call "$(ccw)" -u -b -q -n -t "$(xrunnerpath)\scripts\ini2xslt2.cct" -o "$(xrunnerpath)\scripts\xrun.xslt" "$(xrunnerpath)\setup\xrun.ini"

lists.tsv: ;

keyvalue.tsv: ;