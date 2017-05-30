@echo off

rd __history /S /Q

del *.bdsgroup
del *.groupproj*
del *.rsm
del *.map
del *.local
del *.identcache
del *.tgs
del *.tgw
del *.dcu
del *.~*
del *.log
del *.stat
del *.mps
del *.mpt
del *.dsk
del *.obj
del *.hpp
del *.tds
del *.dsk
del *.groupproj
del *.exe
del *.tvsconfig

cd Clients
call _clear
cd ..

cd Gateway
call _clear
cd ..

cd Modules
call _clear
cd ..