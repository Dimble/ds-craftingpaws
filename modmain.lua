-- debugging stuffz, don't load a game you care about with these enabled
--GLOBAL.CHEATS_ENABLED = true
--GLOBAL.require("debugkeys")

--[[
Much inspiration came from:
    noobler - Relaxed Crafting
    hmaarrfk - Crafting Pause Staging
    hounds - Eternal hatred

Note: this mod might make the buggy tab selection with controller crafting worse. (where it skips over tabs)  You can increase REPEAT_TIME in data/scripts/controllercrafting.lua to slow down navigation until it stops doing that, though you might have to make it really slow.
    - I have noticed that the issue occurs with keystrokes but not with mouse input, so it's probably a game bug
    - I vaguely recall it being caused by some dodgy code for repeating keys, so it may be fixable via modding
--]]

local require = GLOBAL.require

Assets =
    {
    Asset("ATLAS", "images/smallpaw.xml"),
    Asset("ATLAS", "images/controlicon.xml"),
    Asset("ATLAS", "images/mouseicon1.xml"),
    Asset("ATLAS", "images/placeicon.xml"),
    }

GLOBAL.paws = { active                 = false,
                crafting               = true,
                controllercrafting     = true,
                placement              = true,
                STRING_TITLE           = "Paws Crafting for...",
                STRING_MOUSE           = "Mouse Bar",
                STRING_CONTROLLER      = "Crafting Bar",
                STRING_PLACEMENT       = "Placement",
                STRING_HELP_MOUSE      = "Pause crafting while using the mouse-activated crafting bar.  (the one on the left side of the screen)",
                STRING_HELP_CONTROLLER = "Pause crafting while using the keyboard or controller-activated crafting bar.  (the horizontal one that opens up top)",
                STRING_HELP_PLACEMENT  = "Pause the game while placing an item, whether crafted or items like berry bushes, pinecones, etc." }

local paws = GLOBAL.paws

function paws.SetPlacement(setting)
    paws.placement = setting
end

function paws.SetCrafting(setting)
    paws.crafting = setting
end

function paws.SetControllerCrafting(setting)
    paws.controllercrafting = setting
end

function paws.UpdateSettings()
    paws.bar:CheckSettings()
end

require("craft")(env)
require("screen")(env)
require("bar")(env)
require("otherpaw")(env)

--[[
TODO
    - mod config settings
    - save state to some file
    - add a dialog to exclude placement for some items, e.g. seedlings, hound traps, etc
    - clean up which paused actions should work during crafting
    ? translation strings work how?  if any are submitted
    - configurable keys to open the paws screen or toggle options
        ? look into copying the way the main control screen assigns keys
    - file organization isn't as clean as it could be
        - define bar and screen in files and return them to be assigned
        - single AddSimPostInit instead of one in bar and otherpaw
        - group the placement stuff together

FIXME
    - any remaining bugs that unpause during the pause screen, map screen, etc.
    - failure to unpause if the paws screen was opened while crafting is paused
    - does not pause if controller crafting is opened while moving
        - might not be easily fixable, this seems to be a result of the bufferedaction state not getting cleared when the player stops
    - unknown unknowns
--]]

-- vim: ts=4:sw=4:et
