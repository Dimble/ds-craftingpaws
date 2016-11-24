name = "Crafting Paws"
description = "Pause while crafting or placing items.  (Mostly based on Relaxed Crafting)"
author = "Dimblemace"
forumthread = ""

version = "0.8"
api_version = 6
--priority = ?

icon_atlas = "modicon.xml"
icon = "modicon.tex"

dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true

--[[
configuration_options =
{
    {
        name = "controllercrafting",
        label = "Controller crafting",
        options =
        {
            { description = "paused", data = true },
            { description = "not paused", data = false },
        },
        default = true,
    },
    {
        name = "crafting",
        label = "Mouse crafting",
        options =
        {
            { description = "paused", data = true },
            { description = "not paused", data = false },
        },
        default = true,
    },
    {
        name = "placement",
        label = "Item Placement",
        options =
        {
            { description = "paused", data = true },
            { description = "not paused", data = false },
        },
        default = false,
    },
    {
        name = "collapse delay",
        label = "Seconds before the bar auto-collapses.",
        options =
        {
            however number range(s) work
        },
        default = 5,
    }
}
--]]

