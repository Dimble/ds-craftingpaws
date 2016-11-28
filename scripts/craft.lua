-- pausing while crafting
return function(mod)

-- Using CraftTabs:OnUpdate to determine when to pause rather than trying to track the opening and closing of crafting panels as some pause mods do.
-- Unpausing is done in specific locations: when crafting closes, a recipe is made, an item is placed, etc.
-- TODO  try using a DoPeriodicTask to check less often, it doesn't need to pause RIGHT NOW.

mod.AddClassPostConstruct("widgets/crafttabs",
 function(crafttabs)
    local player = crafttabs.owner

    local base_OnUpdate = crafttabs.OnUpdate
    function crafttabs:OnUpdate(dt)
        base_OnUpdate(crafttabs, dt)
--print("ctou: " .. tostring(IsPaused()) .. " " ..
--      tostring(player.components.locomotor.bufferedaction) .. " " ..
--      tostring(not player.components.playercontroller.inst.sg:HasStateTag("idle")) .. " " ..
--      tostring((crafttabs.crafting.open and paws.crafting)) .. " " ..
--      tostring((crafttabs.controllercraftingopen and paws.controllercrafting)))

        local pcon = GetPlayer().components.playercontroller
        if ( not paws.placement_handler and
             ((pcon.placer and pcon.placer_recipe) or
              (pcon.deployplacer and pcon.deployplacer.components.placer)) ) then
            paws.placement_handler = TheInput:AddMoveHandler(paws.UpdatePlacer)
        end

        if ( not paws.active and
             ((crafttabs.crafting.open and paws.crafting) or
              (crafttabs.controllercraftingopen and paws.controllercrafting)) ) then
            paws.active = true
        end

        if ( paws.active and not IsPaused() ) then
            if not player.components.locomotor.bufferedaction and
               player.components.playercontroller.inst.sg:HasStateTag("idle") then
                SetPause(true, "Paws mod")
            end
        end
    end
 end
)

mod.AddClassPostConstruct("widgets/crafting",
 function(crafting)
    local player = crafting.owner

    local baseClose = crafting.Close
    function crafting:Close(fn)
        baseClose(crafting, fn)
        if ( not GetWorld().minimap.MiniMap:IsVisible() and
             not (paws.placement and player.components.playercontroller.placer) ) then
            SetPause(false);
            paws.active = false;
        end
    end

    local function doScrollWorkaround(fn)
        if paws.active and IsPaused() then
            SetPause(false)
            fn(crafting)
            SetPause(true, "Paws mod")
        else
            fn(crafting)
        end
    end

    local baseScrollUp   = crafting.ScrollUp
    local baseScrollDown = crafting.ScrollDown
    function crafting:ScrollUp()   doScrollWorkaround(baseScrollUp) end
    function crafting:ScrollDown() doScrollWorkaround(baseScrollDown) end
 end
)

end
-- vim: ts=4:sw=4:et
