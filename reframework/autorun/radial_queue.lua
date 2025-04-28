-- @Author taakefyrsten
-- https://next.nexusmods.com/profile/taakefyrsten
-- https://github.com/jwlei/radial_queue
-- Version 1.5

-- INIT ------------------------------------
local instance = nil
local itemSuccess = nil
local cancelCount = 0
local shouldSkipPad = true
local resetTime = nil
local executing = false
local HunterCharacter = nil
local loadedTable = nil
local sourceInput = nil
local GUI020600_itemIndex_current = nil

--app.GUI020006.requestOpenItemSlider Item bar
--app.GUI020007 Radial M+KB
local type_GUI020008 = sdk.find_type_definition("app.GUI020008") -- Radial Menu
local type_GUI020600 = sdk.find_type_definition("app.GUI020600") -- M+KB item select
local type_GUI030208 = sdk.find_type_definition("app.GUI030208") -- Radial customization
local type_cGUIPartsShortcutFrameBase = sdk.find_type_definition("app.cGUIPartsShortcutFrameBase")
local type_HunterExtendBase = sdk.find_type_definition("app.HunterCharacter.cHunterExtendBase")
local type_PlayerManager = sdk.find_type_definition("app.PlayerManager")
local type_cHunterBadConditions = sdk.find_type_definition("app.HunterBadConditions.cHunterBadConditions")
local type_Weapon = sdk.find_type_definition("app.Weapon")
local type_PlayerUtil = sdk.find_type_definition("app.PlayerUtil")
local type_cGUIShortcutPadControl = sdk.find_type_definition("app.cGUIShortcutPadControl")
local type_HunterItemActionTable = sdk.find_type_definition("app.HunterItemActionTable")
local type_ChatManager = sdk.find_type_definition("app.ChatManager")
local type_HunterCharacter = sdk.find_type_definition("app.HunterCharacter")
local type_WpCommonSubAction = sdk.find_type_definition("app.WpCommonSubAction.cAimStart")
local type_PlayerCommonSubActionUseSlingerItem = sdk.find_type_definition("app.PlayerCommonSubAction.cUseSlingerItem")
local type_mcOtomoCommunicator = sdk.find_type_definition("app.mcOtomoCommunicator")
local type_cCallPorter = sdk.find_type_definition("app.PlayerCommonSubAction.cCallPorter")
local type_mcHunterBonfire = sdk.find_type_definition("app.mcHunterBonfire")
local type_mcHunterFishing = sdk.find_type_definition("app.mcHunterFishing")
local type_PauseManagerBase = sdk.find_type_definition("ace.PauseManagerBase")
local type_PhotoCameraController = sdk.find_type_definition("app.PhotoCameraController")
local type_cGUIMapController = sdk.find_type_definition("app.cGUIMapController")
local type_cSougankyo = sdk.find_type_definition("app.CameraSubAction.cSougankyo")
local type_cGUIItemCraft = sdk.find_type_definition("app.cGUIItemCraft")

-- SETTINGS --------------------------------

local config = {
    Enable = true,  -- Toggle mod
    EnableNoCombatTimer = true,
    ResetTimerNoCombat = 1, -- Time in seconds to reset item use
    EnableCombatTimer = false,
    ResetTimerCombat = 15
}

local function debug(msg)
    local timestamp = os.date("%H:%M:%S")
    print('[RQ]' .. '[' .. timestamp .. ']'.. '[DEBUG] ' .. tostring(msg))
end


local function save_config()
    json.dump_file("radial_queue.json", config)
end

local function load_config()
    if loadedTable == nil then
        loadedTable= json.load_file("radial_queue.json")
    end 
    if loadedTable then
        config = loadedTable
        if config.Enable == nil then
            config.Enable = 1
        end

        if config.EnableNoCombatTimer == nil then
            config.EnableNoCombatTimer = 1
        end

        if config.ResetTimerNoCombat == nil then
            config.ResetTimerNoCombat = 1
        end

        if config.EnableCombatTimer == nil then
            config.EnableCombatTimer = 0
        end

        if config.ResetTimerCombat == nil then
            config.ResetTimerCombat = 15
        end
    else
        save_config()
    end
end

load_config()



-- Core functions ------------------------
local function setInputSource(args)
    if args == nil then
        return
    end
    --ID 100 for M+KB, 55 for Radial
    sourceInput = args:get_field("_PartsOwnerAccessor"):get_field("_Owner"):get_ID()
    if sourceInput == nil then
        return
    end
end

local function saveItem(args)
    if config.Enable == false then 
        return 
    end
    instance = sdk.to_managed_object(args[2])
    setInputSource(instance)

    if sourceInput == 100 then
        GUI020600_itemIndex_current = tonumber(string.sub(string.gsub(tostring(args[3]), "userdata: ", ""), -2))
    end
    
    if executing == false then
        debug("Action saved")
    end

    itemSuccess = false
    shouldSkipPad = true
    executing = true
end

local function setItemSuccess()
       debug("Action cancelled or finished")
       itemSuccess = true
       resetTime = nil
       executing = false
       cancelCount = 0
       sourceInput = nil 
       GUI020600_itemIndex_current = nil
end

local function cancelUseItem(args)
    if itemSuccess == false then
        setItemSuccess()
    end
end

local function getHunterCharacter() 
    local Player = sdk.get_managed_singleton("app.PlayerManager"):get_field("_PlayerList")[0]

    --local MasterPlayer = Player:call("getMasterPlayer")
    --debug(MasterPlayer)
	if Player == nil then 
		return 
	end

	HunterCharacter = Player:get_field("_PlayerInfo"):get_field("<Character>k__BackingField")
	if HunterCharacter == nil then
		return
    end

    return HunterCharacter
end

-- Misc
local function getHunterCharacterCombat()
    HunterCharacter = getHunterCharacter()

    if HunterCharacter:call("get_IsCombat()") == true 
        or HunterCharacter:call("get_IsCombatBoss()") == true then
        --HunterCharacter:call("get_IsHalfCombat()")
        return true
    else
        return false
	end
end

local function startTimer()
    if resetTime == nil then
        if config.ResetTimerNoCombat == nil then 
                   resetTime = os.time() + 1
        elseif config.ResetTimerCombat == nil then
                   resetTime = os.time() + 15
        end

        if getHunterCharacterCombat() == true and config.EnableCombatTimer == true then
            resetTime = os.time() + config.ResetTimerCombat
            debug("Timer COMBAT started, " .. config.ResetTimerCombat .. "s")

        elseif getHunterCharacterCombat() == false and config.EnableNoCombatTimer == true then
            resetTime = os.time() + config.ResetTimerNoCombat
            debug("Timer NO COMBAT started, " .. config.ResetTimerNoCombat .. "s")
        else
            return
        end
    end
end

local function checkIfTimerCancel()
    if config.EnableCombatTimer == true or config.EnableNoCombatTimer == true then
        if resetTime == nil and itemSuccess == false then
        startTimer()
    end

       local currentTime = os.time()
       if resetTime ~= nil and currentTime >= resetTime then
           debug("Timer expired")
           setItemSuccess()
           resetTime = nil
       end
    end
end

local function skipPadInput(args)
    if instance == nil then
        return
    end

    if shouldSkipPad == true then 
        if instance:call('checkClose()') then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

local function checkItemIDforCancel(args)
    if args == nil then
        return
    end

    local itemId = string.gsub(tostring(args[2]), "userdata: ", "") -- remove the prefix
   
    if     itemId == "0000000000000001" --Potion
        or itemId == "0000000000000002" --Mega Potion
    then
        cancelCount = cancelCount + 1
    end

    if cancelCount >= 1 then
        setItemSuccess()
    end
end

local function tryUseItem(args)
    if instance == nil then
        return
    end

    checkIfTimerCancel()
    
    --debug(itemSuccess)
    if itemSuccess == false then
        if sourceInput == 100 then
            instance:call('execute(System.Int32)', GUI020600_itemIndex_current)
        elseif sourceInput == 55 then
            instance:call('useActiveItem(System.Boolean)', nil)
        else
            return
        end
    else 
        return
    end 
end

local function cancelTriggerAttack(args) 
    local obj_weapon = sdk.to_managed_object(args[2])
    
    if obj_weapon:get_IsMaster() == true then
        --debug("CANCELLED BY MASTERPLAYER ATTACK")
        setItemSuccess()
    end
    
end

local function cancelTriggerDodge(args)
    local obj_hunterBadconditionsHunterCharacter = sdk.to_managed_object(args[3])
    
    if obj_hunterBadconditionsHunterCharacter:get_IsMaster() == true then
        --debug("CANCELLED BY  MASTERPLAYER DODGE")
        setItemSuccess()
    end
end

local function cancelTriggerSeikret(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("_Character")

    if isMasterPlayer:get_IsMaster() == true then
        --debug("CANCELLED BY MASTERPLAYER SEIKRET")
        setItemSuccess()
    end
end


local function cancelTriggerWpAction(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("_Character")
    
    if isMasterPlayer:get_IsMaster() == true then
        --debug("CANCELLED BY MASTERPLAYER WPXX")
        setItemSuccess()
    end
end

local function cancelTriggerSlingerLoad(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("_Character")
    
    if isMasterPlayer:get_IsMaster() == true then
        --debug("CANCELLED BY MASTERPLAYER SLINGER LOAD")
        setItemSuccess()
    end
end

--[[
local function cancelTriggerItemCraft(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("_Owner"):get_field("")
    if isMasterPlayer:get_IsMaster() == true then
        --debug("CANCELLED BY MASTERPLAYER ITEM CRAFT")
        setItemSuccess()
    end
end
]]

local function cancelTriggerOtomo(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("_OwnerHunter")

    if isMasterPlayer:get_IsMaster() == true then
        --debug("CANCELLED BY MASTERPLAYER OTOMO")
        setItemSuccess()
    end
end

local function cancelTriggerBonfire(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("_Chara")
    if isMasterPlayer:get_IsMaster() == true then
        --debug("CANCELLED BY MASTERPLAYER BONFIRE")
        setItemSuccess()
    end
end

local function cancelTriggerFishing(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("Chara")
    if isMasterPlayer:get_IsMaster() == true then
        --debug("CANCELLED BY MASTERPLAYER FISHING")
        setItemSuccess()
    end
end

local function cancelTriggerMisc(args)
    itemSuccess = false
    setItemSuccess()
end

--[[
local function closeGUI020600(retval)
    if executing == true and sourceInput == 100 then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end
]]





if config.Enable == true then
    -- HOOKS --------------------------------
    -- Item used call and save
    if type_GUI020008 then
        sdk.hook(type_GUI020008:get_method('onOpenApp'), cancelUseItem, function(retval) debug("Canceled by type_GUI020008") end)
        sdk.hook(type_GUI020008:get_method("useActiveItem"), saveItem, nil)
    end

    -- Save item from M+KB
    if type_GUI020600 then
        sdk.hook(type_GUI020600:get_method("execute"), saveItem, nil)
    end

    -- Item used successfully
    if type_HunterExtendBase then
        sdk.hook(type_HunterExtendBase:get_method("successItem(app.ItemDef.ID, System.Int32, System.Boolean, ace.ShellBase, System.Single, System.Boolean, app.ItemDef.ID, System.Boolean)"), cancelUseItem, nil)
    end

    -- Retry item Use
    if type_PlayerManager then
        sdk.hook(type_PlayerManager:get_method("update"), tryUseItem, nil)
    end

    -- Skip pad control if HUD is closed
    if type_cGUIShortcutPadControl then
        sdk.hook(type_cGUIShortcutPadControl:get_method("move(System.Single, via.vec2)"), skipPadInput, nil)
    end

    -- Dont skip pad in customize radial menu
    if type_GUI030208 then
        sdk.hook(
            type_GUI030208:get_method("guiVisibleUpdate"),
            function(args)
                shouldSkipPad = false
            end,
            nil
        )
    end

    -- Get ItemID for radial
    if type_HunterItemActionTable then
        sdk.hook(type_HunterItemActionTable:get_method("getItemActionTypeFromItemID"), checkItemIDforCancel, nil)
    end

    -- Cancels
    if itemSuccess == false or itemSuccess == nil then
        -- Dodge
        if type_cHunterBadConditions then
            sdk.hook(type_cHunterBadConditions:get_method("onDodgeAction(app.HunterCharacter, System.Boolean)"), cancelTriggerDodge, nil)
        end

        -- Attack
        if type_Weapon then
            sdk.hook(type_Weapon:get_method("evAttackCollisionActive"), cancelTriggerAttack, nil)
        end

        -- Seikret
        if type_cCallPorter then
            sdk.hook(type_cCallPorter:get_method("doCall"), cancelTriggerSeikret, nil)
        end

        -- Guarding
        local type_Wp00 = sdk.find_type_definition("app.Wp00Action.cGuard")
        if type_Wp00 then
            sdk.hook(type_Wp00:get_method("doEnter"), cancelTriggerWpAction, nil)
        end

        local type_Wp01 = sdk.find_type_definition("app.Wp01Action.cGuard")
        if type_Wp01 then
            sdk.hook(type_Wp01:get_method("doEnter"), cancelTriggerWpAction, nil)
        end

        local type_Wp06 = sdk.find_type_definition("app.Wp06Action.cGuard")
        if type_Wp06 then
            sdk.hook(type_Wp06:get_method("doEnter"), cancelTriggerWpAction, nil)
        end

        local type_Wp07 = sdk.find_type_definition("app.Wp07Action.cGuard")
        if type_Wp07 then
            sdk.hook(type_Wp07:get_method("doEnter"), cancelTriggerWpAction, nil)
        end

        local type_Wp09 = sdk.find_type_definition("app.Wp09Action.cGuard")
        if type_Wp09 then
            sdk.hook(type_Wp09:get_method("doEnter"), cancelTriggerWpAction, nil)
        end
    end

    -- Stamp
    if type_ChatManager then
        sdk.hook(type_ChatManager:get_method("sendStamp"), cancelUseItem, function(retval) debug("Canceled by type_ChatManager") end)
    end

    -- Slinger reload
    if type_PlayerCommonSubActionUseSlingerItem then
        --sdk.hook(type_PlayerCommonSubActionUseSlingerItem:get_method("doItemLoad"), cancelUseItem, nil)
        sdk.hook(type_PlayerCommonSubActionUseSlingerItem:get_method("doEnter"), cancelTriggerSlingerLoad, nil)
    end

    -- Pause
    if type_PauseManagerBase then
        sdk.hook(type_PauseManagerBase:get_method("requestPause"), cancelTriggerMisc, nil)
    end

    -- Photo mode
    if type_PhotoCameraController then
        sdk.hook(type_PhotoCameraController:get_method("enable"), cancelTriggerMisc, nil)
    end

    -- Map
    if type_cGUIMapController then
        sdk.hook(type_cGUIMapController:get_method("requestOpen"), cancelTriggerMisc, nil)
    end

    -- Binoculars
    if type_cSougankyo then
        sdk.hook(type_cSougankyo:get_method("enter"), cancelTriggerMisc, nil)
    end

    -- Item craft
    if type_cGUIItemCraft then
        sdk.hook(type_cGUIItemCraft:get_method("open"), cancelTriggerMisc, function(retval) debug("Cancelled by type_cGUIItemCraft") end)
    end

    -- Emote
    if type_mcOtomoCommunicator then
        sdk.hook(type_mcOtomoCommunicator:get_method("requestEmote"), cancelTriggerOtomo, nil)
    end

    -- Grill
    if type_mcHunterBonfire then
        sdk.hook(type_mcHunterBonfire:get_method("updateMain"), cancelTriggerBonfire, nil)
    end

    -- Fishing
    if type_mcHunterFishing then
        sdk.hook(type_mcHunterFishing:get_method("updateMain"), cancelTriggerFishing, nil)
    end
end


-- reFramework config ----------------------------
re.on_draw_ui(function()

    if imgui.tree_node("Radial queue") then
        if imgui.checkbox("Enable", config.Enable) then
            config.Enable = not config.Enable
            save_config()
            load_config()
        end

        if config.Enable then
            if imgui.checkbox("Enable combat reset timer", config.EnableCombatTimer) then
                config.EnableCombatTimer = not config.EnableCombatTimer
                save_config()
                load_config()
            end
            
            if config.EnableCombatTimer then
                local changed, new_value_ResetTimerCombat = imgui.slider_int("Combat reset timer (s)", config.ResetTimerCombat, 1, 30)
                if changed then
                    config.ResetTimerCombat = new_value_ResetTimerCombat
                    save_config()
                    load_config()
                end
                if imgui.is_item_hovered() then
                    imgui.set_tooltip("Reset all action executions after X seconds regardless while in combat with a monster")
                end
            end

            if imgui.checkbox("Enable out of combat reset timer", config.EnableNoCombatTimer) then
                config.EnableNoCombatTimer = not config.EnableNoCombatTimer
                save_config()
                load_config()
            end

            if config.EnableNoCombatTimer then
                local changed, new_value_ResetTimerNoCombat = imgui.slider_int("Out of combat reset timer (s)", config.ResetTimerNoCombat, 0, 30)
                if changed then
                    config.ResetTimerNoCombat = new_value_ResetTimerNoCombat
                    save_config()
                    load_config()
                end
                if imgui.is_item_hovered() then
                    imgui.set_tooltip("Reset all action executions after X seconds regardless while not in combat with a monster")
                end
            end
        end
        imgui.tree_pop()
    end
end)


--[[
--Todo
local function cancelUseItemFocus(retval)
    if retval == nil then return end
    local isAim = (sdk.to_int64(retval) & 1)
  
    if isAim == 1 then
        setItemSuccess()
    end
end

-- Focus
if type_HunterCharacter then
    sdk.hook(type_HunterCharacter:get_method("changeActionRequest(app.AppActionDef.LAYER, ace.ACTION_ID, System.Boolean)"), cancelUseItemFocus, nil)
end

local function get_IsAim(retval)
    local hunter = sdk.get_managed_singleton("app.PlayerManager"):getMasterPlayer():get_ContextHolder():get_Hunter()
    is_aim = hunter:get_IsAim()
    if is_aim == true then
        setItemSuccess()
    end
end

local function cancelUseItemFocus(args)
    local actionID = sdk.to_int64(args[4])
    -- 4835046936 focus
    if actionID == 4835046936 then
        setItemSuccess()
    end
end

]]
