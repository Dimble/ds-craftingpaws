set "DEST=C:\Steam\SteamApps\common\dont_starve\mods"
@echo off

echo rmdir /S /Q "$DEST\oldcraftingpaws"
rmdir /S /Q "%DEST%\oldcraftingpaws"

echo move "$DEST\craftingpaws" "$DEST\oldcraftingpaws"
move "%DEST%\craftingpaws" "%DEST%\oldcraftingpaws"

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

echo copy (bar.lua, craft.lua, otherpaw.lua, screen.lua)
FOR %%G IN (bar.lua, craft.lua, otherpaw.lua, screen.lua) DO copy scripts\%%G "%DEST%\craftingpaws\scripts"

echo Don't Crash!

