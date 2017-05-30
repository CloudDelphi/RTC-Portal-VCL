call _clear

call ..\Bin\BuildPortalHelp.cmd
copy MyHelp\Docs.chm Help\RTCPortal_Help.chm

del ..\Bin\Help\*.* /Q
del MyHelp\Docs.* /Q
move MyHelp\*.* ..\Bin\Help
rd MyHelp

del ..\RTCPortal_Current.zip /Q

call "%ProgramFiles%\7-zip\7z.exe" a -r -x!.svn -tZIP ..\RTCPortal_Current.zip *.*

pause