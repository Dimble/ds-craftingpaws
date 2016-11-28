-- Anything that doesn't belong in a specific file
--     . placement handling
--     . unpausing for movement during placement or crafting
--     . miscellaneous

-- TODO controller commands

-- make sure the image of the placed item follows the pointer while paused
function paws.UpdatePlacer()
    if not IsPaused() then return end
    local pcompcon = GetPlayer().components.playercontroller
    if not pcompcon then return end

    if ( pcompcon.placer ) then
        if ( pcompcon.placer.components.placer ) then
            pcompcon.placer.components.placer:OnUpdate(0)
            --pcompcon:OnUpdate(0)
        end
    elseif ( pcompcon.deployplacer ) then
        if ( pcompcon.deployplacer.components.placer ) then
            pcompcon.deployplacer.components.placer:OnUpdate(0)
            pcompcon:OnUpdate(0)  -- FIXME try without, note why this is here
        end
    else
        TheInput.position:RemoveHandler(paws.placement_handler)
        paws.placement_handler = nil
    end
end

return function(mod)
 mod.AddSimPostInit(
 function(player)
    local pcomp = player.components

--[[
    -- icky.  But may be useful.
    TheInput:AddKeyDownHandler(KEY_P,
        function()
            if not paws.menu_active then
                TheFrontEnd:PushScreen(paws.Screen())
            end
        end)
--]]
    pcomp.builder.inst:ListenForEvent("makerecipe",
        function()
            SetPause(false)
            paws.active = false
        end)

    local base_SetActiveItem = pcomp.inventory.SetActiveItem
    pcomp.inventory.SetActiveItem =
        function(inv, item)
--print("SetActiveItem(" .. tostring(item) .. ")")
            base_SetActiveItem(inv, item)
            if ( paws.active and
                 not (item and item ~= inv.activeitem and item.components.deployable) ) then
                SetPause(false)
                paws.active = false
            end
        end

    local base_CancelPlacement = pcomp.playercontroller.CancelPlacement
    pcomp.playercontroller.CancelPlacement =
        function(pcon)
            base_CancelPlacement(pcon)
            if ( paws.active ) then
                SetPause(false)
                paws.active = false
            end
        end

    local base_OnUpdate = pcomp.playercontroller.OnUpdate
    pcomp.playercontroller.OnUpdate =
        function(pcon, dt)
            base_OnUpdate(pcon, dt)
            if ( not paws.placement ) then return end

            if ( not paws.placement_handler and
                 ((pcon.placer and pcon.placer_recipe) or
                  (pcon.deployplacer and pcon.deployplacer.components.placer)) ) then
                paws.placement_handler = TheInput:AddMoveHandler(paws.UpdatePlacer)
            end

            if ( IsPaused() ) then
                if ( paws.active and
                     pcon.deployplacer and pcon.deployplacer.components.placer ) then
                    pcon.LMBaction, pcon.RMBaction = pcon.inst.components.playeractionpicker:DoGetMouseActions()
                end
            else
                if ( pcon.inst.sg:HasStateTag("idle") and
                     not pcon.inst.components.locomotor.bufferedaction ) then
                    if ( (pcon.placer and pcon.placer_recipe) or
                         (pcon.deployplacer and pcon.deployplacer.components.placer) ) then
                        SetPause(true, "Paws mod")
                        paws.active = true
                    end
                end
            end
        end

    local base_OnControl = pcomp.playercontroller.OnControl
    pcomp.playercontroller.OnControl =
    function(pcon, control, down)
        if ( not paws.active or not IsPaused() or
             -- Hopefully anything that might pause and appear over the main screen is caught by this.  We must not unpause if the map screen or some options screen is currently active.
             TheFrontEnd:GetActiveScreen().name ~= "HUD" ) then
            base_OnControl(pcon, control, down)
            return
        end

        -- cancel pause temporarily for these
        if ( control == CONTROL_CANCEL or
             control == CONTROL_PRIMARY or
             control == CONTROL_SECONDARY or 
-- ???           control == CONTROL_CONTROLLER_ACTION or
-- ???           control == CONTROL_CONTROLLER_ALTACTION or
             control == CONTROL_ACTION ) then
            SetPause(false)
        elseif ( down and (control == CONTROL_MOVE_UP or control == CONTROL_MOVE_DOWN or control == CONTROL_MOVE_LEFT or control == CONTROL_MOVE_RIGHT) ) then
            -- controller crafting uses these controls
            if ( not GetPlayer().HUD.controls.crafttabs.controllercraftingopen ) then
                -- FIXME  we should not remove this directly: there may be a better function to override to allow movement
                pcon.inst.sg:RemoveStateTag("idle")
                SetPause(false)
            end
        end

        base_OnControl(pcon, control, down)
    
        if ( down ) then
            if ( control == CONTROL_ROTATE_LEFT or control == CONTROL_ROTATE_RIGHT ) then
                TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() +
                    (control == CONTROL_ROTATE_LEFT and  -45 or 45))
                TheCamera:Snap()
                if ( paws.placement_handler ) then
                    paws.UpdatePlacer()  -- not a big deal, but looks funny until moved
                end
            elseif ( (pcon.placer and pcon.placer_recipe) or
                     (pcon.deployplacer and pcon.deployplacer.components.placer) ) then
                -- The normal zoom is animated over time
                if ( control == CONTROL_ZOOM_IN ) then
                    TheCamera:ZoomIn()
                    TheCamera:Update(1)
                elseif ( control == CONTROL_ZOOM_OUT ) then
                    TheCamera:ZoomOut()
                    TheCamera:Update(1)
                elseif ( pcon.inst.components.locomotor.bufferedaction ) then
                    -- character is now moving to place something
                    SetPause(false)
                end
            end
        end
    end
 end)
end

--[[
--print("paws.active:"..tostring(paws.active)
--      .." control:"..tostring(control)..
--      .." down:"..tostring(down)..
--      .." bufferedaction:"..tostring(not not self.inst.components.locomotor.bufferedaction)
--)
        if not (paws.active and paws.placement) then return end
        if not self:IsEnabled() or not IsPaused() or not down then return end
        -- suggested by squeek to be compatible with HUD minimap et al.
        -- I am guessing that using o.name ~= "HUD" fails with some hud-related mods?
        local o = TheFrontEnd:GetActiveScreen()
        if o and (o:is_a(require "screens/mapscreen") or
                  o.name == "ConsoleScreen") then return
        end

        -- These are duplicated from and must match the base OnControl function
        if control == CONTROL_CANCEL then
            self:CancelPlacement()
        elseif control == CONTROL_PRIMARY then
            self:OnLeftClick(down)
        elseif control == CONTROL_SECONDARY then
            self:OnRightClick(down)
        elseif control == CONTROL_ACTION then
            self:DoActionButton()
        elseif control == CONTROL_ROTATE_LEFT then
--            TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() + 45)
            TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() + 22.75)
            TheCamera:Update(1)
        elseif control == CONTROL_ROTATE_RIGHT then
--            TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() - 45)
            TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() - 22.75)
            TheCamera:Update(1)
        elseif control == CONTROL_ZOOM_IN or control == CONTROL_ZOOM_OUT then
            -- Allow zooming during placement
            if (self.placer and self.placer_recipe) or
               (self.deployplacer and self.deployplacer.components.placer) then
                if control == CONTROL_ZOOM_IN then
                    TheCamera:ZoomIn()
                else
                    TheCamera:ZoomOut()
                end
                TheCamera:Update(1)
            end
        end
        if control == CONTROL_MOVE_UP or control == CONTROL_MOVE_DOWN or control == CONTROL_MOVE_LEFT or control == CONTROL_MOVE_RIGHT then
            -- Allow movement during placement
            if (self.placer and self.placer_recipe) or
               (self.deployplacer and self.deployplacer.components.placer) then
--print("unpause - direct walking")
                SetPause(false)
                self.inst.sg:RemoveStateTag("idle")
            end
        elseif self.inst.components.locomotor.bufferedaction then
--print("loco buffered")
            -- Unpause to drop or place deployable
            if (self.placer and self.placer_recipe) or
               (self.deployplacer and self.deployplacer.components.placer) then
                SetPause(false)
--else print("loco buffered - no unpause (no placer)")
            end
        end
    end
--]]

--[[
    Listening for the makerecipe now instead.
    If the crafting tab is still open or an item is being placed, those re-trigger a pause anyway.
    Also, the event is way simpler.

    pcomp.builder.paws_baseMakeRecipe = pcomp.builder.MakeRecipe
    -- MakeRecipe in Shipwrecked! has an additional parameter, or something
    if IsDLCEnabled(CAPY_DLC) then
        pcomp.builder.MakeRecipe =
            function(self, recipe, pt, rot, onsuccess)
print("capy MakeRecipe")
                local result = pcomp.builder.paws_baseMakeRecipe(self, recipe, pt, rot, onsuccess)
                if result then
print("-- result, should unpause..")
                    SetPause(false)
                    paws.active = false
                end
                return result
            end
    else
        pcomp.builder.MakeRecipe =
            function(self, recipe, pt, onsuccess)
print("not capy MakeRecipe")
                local result = pcomp.builder.paws_baseMakeRecipe(self, recipe, pt, onsuccess)
                if result then
                    SetPause(false)
                    paws.active = false
                end
                return result
            end
    end
--]]

-- vim: ts=4:sw=4:et
