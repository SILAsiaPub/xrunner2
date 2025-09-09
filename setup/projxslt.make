include := xrunnerpath.make

java := java
saxon := $(xrunnerpath)\tools\saxon\saxon12he.jar
ccw := $(xrunnerpath)\tools\cct\Ccw64.exe
green := [32m
reset := [0m
cyan := [36m

files := tmp/proj-var.xml tmp/lists.xml tmp/keyvalue.xml $(xrunnerpath)/scripts/projectvariables-v3.xslt scripts/inc-lookup.xslt scripts/inc-file2uri.xslt scripts/inc-copy-anything.xslt scripts/xrun.xslt

createxslt: scripts/project.xslt
	@echo $(green)Info: project.xslt is up to date$(reset)
	@echo.

scripts/project.xslt: $(files)
	@echo $(cyan)Rebuilding: project.xslt$(reset)
	@call "$(java)" -jar "$(saxon)" -o:"scripts\project.xslt" "tmp\proj-var.xml" "$(xrunnerpath)\scripts\projectvariables-v3.xslt" projectpath=${CURDIR} USERPROFILE="$(USERPROFILE)"

tmp/proj-var.xml: project.txt
	@if not exist "tmp\" md "tmp\"
	@echo $(cyan)Rebuilding: proj-var.xml$(reset)
	@call "$(ccw)" -u -b -q -n -t "$(xrunnerpath)\scripts\proj-var.cct" -o "tmp\proj-var.xml" "project.txt"

scripts/inc-lookup.xslt: $(xrunnerpath)/scripts/inc-lookup.xslt
	@echo $(cyan)Adding: inc-lookup.xslt into project$(reset)
	@copy "$(xrunnerpath)\scripts\inc-lookup.xslt" "scripts\" > nul

scripts/inc-file2uri.xslt: $(xrunnerpath)/scripts/inc-file2uri.xslt
	@echo $(cyan)Adding: inc-file2uri.xslt into project$(reset)
	@copy "$(xrunnerpath)\scripts\inc-file2uri.xslt" "scripts\" > nul

scripts/inc-copy-anything.xslt: $(xrunnerpath)/scripts/inc-copy-anything.xslt
	@echo $(cyan)Adding: inc-copy-anything.xslt into project$(reset)
	@copy "$(xrunnerpath)\scripts\inc-copy-anything.xslt" "scripts\" > nul

scripts/xrun.xslt: $(xrunnerpath)\setup\xrun.ini
	@echo $(cyan)Updated: xrun.xslt$(reset)
	@call "$(ccw)" -u -b -q -n -t "$(xrunnerpath)\scripts\ini2xslt2.cct" -o "scripts\xrun.xslt" "$(xrunnerpath)\setup\xrun.ini"

tmp/lists.xml: lists.tsv
	@echo $(cyan)Updated: list.xml$(reset)
	@if not exist lists.tsv type nul > lists.tsv
	@call "$(ccw)" -u -b -q -n -t "$(xrunnerpath)\scripts\lists2xml.cct" -o "tmp\lists.xml" "lists.tsv"

tmp/keyvalue.xml: keyvalue.tsv
	@echo $(cyan)Updated: keyvalue.xml$(reset)
	@if not exist keyvalue.tsv type nul > keyvalue.tsv
	@call "$(ccw)" -u -b -q -n -t "$(xrunnerpath)\scripts\keyvalue2xml.cct" -o "tmp\keyvalue.xml" "keyvalue.tsv"

$(xrunnerpath)/scripts/projectvariables-v3.xslt: ;

lists.tsv: ;

keyvalue.tsv: ;

$(xrunnerpath)\setup\xrun.ini: ;