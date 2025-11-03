

java := java
saxon := $(xrunnerpath)\tools\saxon\saxon12he.jar
ccw := $(xrunnerpath)\tools\cct\Ccw64.exe
green := [32m
reset := [0m
cyan := [36m

files := $(projpath)/tmp/proj-var.xml $(projpath)/tmp/lists.xml $(projpath)/tmp/keyvalue.xml $(xrunnerpath)/scripts/projectvariables-v3.xslt $(projpath)/scripts/inc-lookup.xslt $(projpath)/scripts/inc-file2uri.xslt $(projpath)/scripts/inc-copy-anything.xslt $(projpath)/scripts/xrun.xslt

createxslt: $(projpath)/scripts/project.xslt
	@echo $(green)Info: project.xslt is up to date$(reset)
	@echo.

$(projpath)/scripts/project.xslt: $(files)
	@echo $(cyan)Rebuilding: project.xslt$(reset)
	@call "$(java)" -jar "$(saxon)" -o:"scripts\project.xslt" "$(projpath)\tmp\proj-var.xml" "$(xrunnerpath)\scripts\projectvariables-v3.xslt" projectpath=${projpath} USERPROFILE="$(USERPROFILE)"

$(projpath)/tmp/proj-var.xml: project.txt
	@if not exist "tmp\" md "tmp\"
	@echo $(cyan)Rebuilding: proj-var.xml$(reset)
	@call "$(ccw)" -u -b -q -n -t "$(xrunnerpath)\scripts\proj-var.cct" -o "$(projpath)\tmp\proj-var.xml" "$(projpath)\project.txt"

$(projpath)/scripts/inc-lookup.xslt: $(xrunnerpath)/scripts/inc-lookup.xslt
	@echo $(cyan)Adding: inc-lookup.xslt into project$(reset)
	@copy "$(xrunnerpath)\scripts\inc-lookup.xslt" "$(projpath)\scripts\" > nul

$(projpath)/scripts/inc-file2uri.xslt: $(xrunnerpath)/scripts/inc-file2uri.xslt
	@echo $(cyan)Adding: inc-file2uri.xslt into project$(reset)
	@copy "$(xrunnerpath)\scripts\inc-file2uri.xslt" "$(projpath)\scripts\" > nul

$(projpath)/scripts/inc-copy-anything.xslt: $(xrunnerpath)/scripts/inc-copy-anything.xslt
	@echo $(cyan)Adding: inc-copy-anything.xslt into project$(reset)
	@copy "$(xrunnerpath)\scripts\inc-copy-anything.xslt" "$(projpath)\scripts\" > nul

$(projpath)/scripts/xrun.xslt: $(xrunnerpath)\setup\xrun.ini
	@echo $(cyan)Updated: xrun.xslt$(reset)
	@call "$(ccw)" -u -b -q -n -t "$(xrunnerpath)\scripts\ini2xslt2.cct" -o "$(projpath)\scripts\xrun.xslt" "$(xrunnerpath)\setup\xrun.ini"

$(projpath)/tmp/lists.xml: $(projpath)/lists.tsv
	@echo $(cyan)Updated: list.xml$(reset)
	@if not exist lists.tsv type nul > lists.tsv
	@call "$(ccw)" -u -b -q -n -t "$(xrunnerpath)\scripts\lists2xml.cct" -o "$(projpath)\tmp\lists.xml" "$(projpath)\lists.tsv"

$(projpath)/tmp/keyvalue.xml: $(projpath)/keyvalue.tsv
	@echo $(cyan)Updated: keyvalue.xml$(reset)
	@if not exist keyvalue.tsv type nul > keyvalue.tsv
	@call "$(ccw)" -u -b -q -n -t "$(xrunnerpath)\scripts\keyvalue2xml.cct" -o "$(projpath)\tmp\keyvalue.xml" "$(projpath)\keyvalue.tsv"

$(xrunnerpath)/scripts/projectvariables-v3.xslt: ;

$(projpath)/lists.tsv: ;

$(projpath)/keyvalue.tsv: ;

$(xrunnerpath)/setup/xrun.ini: ;