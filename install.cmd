set "DEST=C:\Steam\SteamApps\common\dont_starve\mods"
@echo off

rem echo rmdir /S /Q "$DEST\oldcraftingpaws"
rem rmdir /S /Q "%DEST%\oldcraftingpaws"

rem echo move "$DEST\craftingpaws" "$DEST\oldcraftingpaws"
rem move "%DEST%\craftingpaws" "%DEST%\oldcraftingpaws"

if not exist "%DEST%" goto NODIR

echo rmdir /S /Q "$DEST\craftingpaws"
rmdir /S /Q "%DEST%\craftingpaws"

echo mkdir "$DEST\craftingpaws"
mkdir "%DEST%\craftingpaws"
echo mkdir "$DEST\craftingpaws\images"
mkdir "%DEST%\craftingpaws\images"
echo mkdir "$DEST\craftingpaws\scripts"
mkdir "%DEST%\craftingpaws\scripts"

echo copy (modicon.tex, modicon.xml, modinfo.lua, modmain.lua)
FOR %%G IN (modicon.tex, modicon.xml, modinfo.lua, modmain.lua) DO copy %%G "%DEST%\craftingpaws"

echo copy (controlicon.tex, controlicon.xml, mouseicon1.tex, mouseicon1.xml, placeicon.tex, placeicon.xml, smallpaw.tex, smallpaw.xml)
FOR %%G IN (controlicon.tex, controlicon.xml, mouseicon1.tex, mouseicon1.xml, placeicon.tex, placeicon.xml, smallpaw.tex, smallpaw.xml) DO copy images\%%G "%DEST%\craftingpaws\images"

echo copy (bar.lua, paws.lua, screen.lua)
FOR %%G IN (bar.lua, paws.lua, screen.lua) DO copy scripts\%%G "%DEST%\craftingpaws\scripts"

echo Don't Crash!
exit /b 0

:NODIR
echo %DEST% does not seem to exist.  Ask Maxwell where it went.
exit /b 1
