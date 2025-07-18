-- @Author taakefyrsten
-- https://next.nexusmods.com/profile/taakefyrsten
-- https://github.com/jwlei/radial_queue
-- Version 2.7

local VERSION = "2.7"
local CONFIG_PATH = "radial_queue.json"
local SOURCE_MKB = 101
local SOURCE_RADIAL = 55

--= Configuration =============================================================================--
local config = {
    Enable                              = true,  -- Toggle mod
    EnableNoCombatTimer                 = false,
    ResetTimerNoCombat                  = 1, -- Time in seconds to reset item use
    EnableCombatTimer                   = false,
    ResetTimerCombat                    = 15,
    EnableCancelControl                 = false,
    DisableCancelHitReceived            = false,
    DisableCancelForXDodge              = false,
    DodgePersistCount                   = 0,
    IgnoreDisabledShortcut              = false,
    IndicatorEnable                     = false,
    IndicatorPosX                       = 720,
    IndicatorPosY                       = 100,
    IndicatorBaseRadius                 = 15,
    IndicatorColorPending               = 3356920024, 
    IndicatorColorSuccess               = 3355508539,
    IndicatorShouldFade                 = true,
    IndicatorFadeDuration               = 0.5,
    IndicatorShouldPulse                = true,
    IndicatorPulseSpeed                 = 1.0,
    IndicatorPulseGrowth                = 10,
    IndicatorShowInMenu                 = true,
    IndicatorMinimumPulseAlpha          = 0.5,
    IndicatorMaxPulseAlpha              = 1.0,
    debug_flag                          = true,
    debug_forceMsg                      = false
}

local function save_config()
    json.dump_file(CONFIG_PATH, config)
end

local function load_config()
    local loadedConfig = json.load_file(CONFIG_PATH)

    if loadedConfig then
        config = loadedConfig
    else
        save_config()
    end
end

load_config()

re.on_config_save(function()
	save_config()
    load_config()
end)


--= reFramework config =======================================================================--
re.on_draw_ui(function()
    if imgui.tree_node("Radial queue") then
        if imgui.checkbox("Enable", config.Enable) then
            config.Enable = not config.Enable
        end

        if config.Enable then
            
            imgui.text(" ")

            if imgui.checkbox("Enable Indicator", config.IndicatorEnable) then
                config.IndicatorEnable = not config.IndicatorEnable
            end

            if config.IndicatorEnable then
                imgui.indent(20)
                if imgui.collapsing_header("Visual indicator settings") then
                
                    if imgui.checkbox("Show preview in REFramework menu", config.IndicatorShowInMenu) then
                        config.IndicatorShowInMenu = not config.IndicatorShowInMenu
                    end

                    local changedX, newX = imgui.slider_int("Position X", config.IndicatorPosX or 720, 0, 3840)
                    if changedX then
                        config.IndicatorPosX = newX
                    end

                    local changedY, newY = imgui.slider_int("Position Y", config.IndicatorPosY or 100, 0, 2160)
                    if changedY then
                        config.IndicatorPosY = newY
                    end

                    local changedRadius, newRadius = imgui.slider_int("Base Radius", config.IndicatorBaseRadius or 20, 1, 50)
                    if changedRadius then
                        config.IndicatorBaseRadius = newRadius
                    end

                    if imgui.checkbox("Pulse Radius", config.IndicatorShouldPulse) then
                        config.IndicatorShouldPulse = not config.IndicatorShouldPulse
                    end

                    if config.IndicatorShouldPulse then
                        local changedPulseSpeed, newPulseSpeed = imgui.slider_float("Pulse Speed", config.IndicatorPulseSpeed or 1.0, 0.1, 5.0)
                        if changedPulseSpeed then
                            config.IndicatorPulseSpeed = newPulseSpeed
                        end

                        local changedMinAlpha, newMinAlpha = imgui.slider_float("Minimum Pulse Alpha", config.IndicatorMinimumPulseAlpha or 0.0, 0.0, 1.0)
                        if changedMinAlpha then
                            config.IndicatorMinimumPulseAlpha = newMinAlpha
                        end

                        local changedMaxAlpha, newMaxAlpha = imgui.slider_float("Maximum Pulse Alpha", config.IndicatorMaxPulseAlpha or 1.0, 0.0, 1.0)
                        if changedMaxAlpha then
                            config.IndicatorMaxPulseAlpha = newMaxAlpha
                        end

                        local changedGrowth, newGrowth = imgui.slider_int("Pulse Growth", config.IndicatorPulseGrowth or 0, 0, 50)
                        if changedGrowth then
                            config.IndicatorPulseGrowth = newGrowth
                        end
                    end

                    if imgui.checkbox("Fade On Success", config.IndicatorShouldFade) then
                        config.IndicatorShouldFade = not config.IndicatorShouldFade
                    end

                    if config.IndicatorShouldFade then
                        local changedFade, newFade = imgui.slider_float("Fade Duration (s)", config.IndicatorFadeDuration or 0.5, 0.1, 5.0)
                        if changedFade then
                            config.IndicatorFadeDuration = newFade
                        end
                    end

                    local changedPending, newPending = imgui.color_picker("Pending Color", config.IndicatorColorPending)
                    if changedPending then
                        config.IndicatorColorPending = newPending
                    end

                    local changedSuccess, newSuccess = imgui.color_picker("Success Color", config.IndicatorColorSuccess)
                    if changedSuccess then
                        config.IndicatorColorSuccess = newSuccess
                    end
                end
                imgui.unindent(20)
            end  

            imgui.text(" ")

            if imgui.checkbox("Enable additional cancel control", config.EnableCancelControl) then
                imgui.indent(indent_width)
                config.EnableCancelControl = not config.EnableCancelControl
            end
            if imgui.is_item_hovered() then
                imgui.set_tooltip("These are optional settings that extend beyond the core functionality to allow for additional customization. However, they have not been as extensively tested and may contain bugs or unintended side effects.")
            end

            if config.EnableCancelControl then
                imgui.indent(20)


                if imgui.checkbox("Disable cancelling queued item on hit received", config.DisableCancelHitReceived) then
                    config.DisableCancelHitReceived = not config.DisableCancelHitReceived
                end
                if imgui.is_item_hovered() then
                    imgui.set_tooltip("Cancels item use when hit by a monster")
                end

                if imgui.checkbox("Disable cancelling queued item for X amount of dodges performed", config.DisableCancelForXDodge) then
                config.DisableCancelForXDodge = not config.DisableCancelForXDodge
                end
            
                if config.DisableCancelForXDodge then
                    local changed, new_value_DodgePersistCount = imgui.slider_int("Dodge persist count", config.DodgePersistCount, 0, 5)
                    if changed then
                        config.DodgePersistCount = new_value_DodgePersistCount
                    end
                    if imgui.is_item_hovered() then
                        imgui.set_tooltip("Number of dodges in which the queued item will persist")
                    end
                end

                if imgui.checkbox("RADIAL MENU ONLY - Force disabled(greyed out) shortcuts", config.IgnoreDisabledShortcut) then
                    config.IgnoreDisabledShortcut = not config.IgnoreDisabledShortcut
                end
                if imgui.is_item_hovered() then
                    imgui.set_tooltip("Ignores the check that stops the process when a shortcut is disabled(greyed out). E.g. a trap that you cannot place at that specific spot.")
                end

                imgui.text(" ")
                imgui.text("-- Legacy timers, ONLY for redundancy")
                imgui.text("-- If you find you HAVE to use these, please submit a bug report.")
                if imgui.checkbox("Enable combat reset timer", config.EnableCombatTimer) then
                    config.EnableCombatTimer = not config.EnableCombatTimer
                end
            
                if config.EnableCombatTimer then
                    local changed, new_value_ResetTimerCombat = imgui.slider_int("Combat reset timer (s)", config.ResetTimerCombat, 1, 30)
                    if changed then
                        config.ResetTimerCombat = new_value_ResetTimerCombat
                    end
                    if imgui.is_item_hovered() then
                        imgui.set_tooltip("Reset all action executions after X seconds regardless while in combat with a monster")
                    end
                end

                if imgui.checkbox("Enable out of combat reset timer", config.EnableNoCombatTimer) then
                    config.EnableNoCombatTimer = not config.EnableNoCombatTimer
                end

                if config.EnableNoCombatTimer then
                    local changed, new_value_ResetTimerNoCombat = imgui.slider_int("Out of combat reset timer (s)", config.ResetTimerNoCombat, 0, 30)
                    if changed then
                        config.ResetTimerNoCombat = new_value_ResetTimerNoCombat
                    end
                    if imgui.is_item_hovered() then
                        imgui.set_tooltip("Reset all action executions after X seconds regardless while not in combat with a monster")
                    end
                end

                imgui.unindent(20)
            end

            imgui.text(" ")

            if imgui.checkbox("Debug", config.debug_flag) then
            config.debug_flag = not config.debug_flag
            end
            if imgui.is_item_hovered() then
                imgui.set_tooltip("Prints debug information to the REFramework debug console")
            end
            if config.debug_flag then
                if imgui.checkbox("Force all debug messages ", config.debug_forceMsg) then
                    config.debug_forceMsg = not config.debug_forceMsg
                end
            end
        end 
        imgui.tree_pop()
    end
end)



--= Type definitions =========================================================================--
local type_GUI020006                            = sdk.find_type_definition("app.GUI020006") -- Item bar
local type_GUI020008                            = sdk.find_type_definition("app.GUI020008") -- Radial Menu
local type_GUI020600                            = sdk.find_type_definition("app.GUI020600") -- M+KB item select
local type_GUI030208                            = sdk.find_type_definition("app.GUI030208") -- Radial customization
local type_GUI040000                            = sdk.find_type_definition("app.GUI040000") -- Member list
local type_GUI040002                            = sdk.find_type_definition("app.GUI040002") -- Invitation list
local type_cGUI060000                           = sdk.find_type_definition("app.cGUI060000Sign.cMapPlayerSign") -- Mini map ping
local type_ChatLogCommunication                 = sdk.find_type_definition("app.GUIFlowChatLogCommunication") -- Chat log
local type_HunterExtendBase                     = sdk.find_type_definition("app.HunterCharacter.cHunterExtendBase")
local type_PlayerManager                        = sdk.find_type_definition("app.PlayerManager")
local type_cHunterBadConditions                 = sdk.find_type_definition("app.HunterBadConditions.cHunterBadConditions")
local type_Weapon                               = sdk.find_type_definition("app.Weapon")
local type_cGUIShortcutPadControl               = sdk.find_type_definition("app.cGUIShortcutPadControl")
local type_HunterItemActionTable                = sdk.find_type_definition("app.HunterItemActionTable")
local type_ChatManager                          = sdk.find_type_definition("app.ChatManager")
local type_PlayerCommonSubActionUseSlingerItem  = sdk.find_type_definition("app.PlayerCommonSubAction.cUseSlingerItem")
local type_mcOtomoCommunicator                  = sdk.find_type_definition("app.mcOtomoCommunicator")
local type_cCallPorter                          = sdk.find_type_definition("app.PlayerCommonSubAction.cCallPorter")
local type_cPorterDismountBase                  = sdk.find_type_definition("app.PlayerCommonAction.cPorterDismountBase")
local type_cPorterDismountJumpOff               = sdk.find_type_definition("app.PlayerCommonAction.cPorterDismountJumpOff")
local type_mcHunterBonfire                      = sdk.find_type_definition("app.mcHunterBonfire")
local type_mcHunterFishing                      = sdk.find_type_definition("app.mcHunterFishing")
local type_PauseManagerBase                     = sdk.find_type_definition("ace.PauseManagerBase")
local type_PhotoCameraController                = sdk.find_type_definition("app.PhotoCameraController")
local type_cGUIMapController                    = sdk.find_type_definition("app.cGUIMapController")
local type_cSougankyo                           = sdk.find_type_definition("app.CameraSubAction.cSougankyo")
local type_ItemRecipeUtil                       = sdk.find_type_definition("app.ItemRecipeUtil")
local type_Hit                                  = sdk.find_type_definition("app.Hit")
local type_cCustomShortcutElement               = sdk.find_type_definition("app.cCustomShortcutElement")
local type_mcHunterArmorControl 			    = sdk.find_type_definition("app.mcHunterArmorControl")
local type_mcActiveSkillController 		        = sdk.find_type_definition("app.mcActiveSkillController")
--app.GUI020006.requestOpenItemSlider Item bar
--app.GUI020007 Radial M+KB


--= Variables ================================================================================--
-- Flags and States
local instance                      = nil
local instance_activeShortcut       = nil
local isCrafting                    = false
local isCraftingRecipeOnly          = nil
local HunterCharacter               = nil
local shouldSkipPad                 = true
local rocksteadyEquipped            = false
local executing                     = false

-- Crafting Information
local craftingRecipeID              = nil
local itemSuccess                   = nil
local GUI020600_itemIndex_current   = nil

-- Counters and Time
local cancelCount                   = 0
local cancelCountDodge              = 0
local resetTime                     = nil

-- Shortcut related
local table_shortcutRecipeItem      = {}
local shortcutIsEnabled             = nil
local shortcutIsSelected            = nil
local shortcutItemId                = nil
local shortcutPreviousItemId        = nil

-- Miscellaneous Information
local loadedTable                   = nil
local sourceInput                   = nil
local shouldThrottle                = true    
local last_debug_times              = {}
local last_debug_messages           = {}



--= Utility functions =======================================================================--
local function debug(msg, override)
    if not config.debug_flag then return end
    if override == false and config.debug_forceMsg == false then 
        if not executing then return end
    end
    

    local msg_key = tostring(msg)
    local current_time = os.time()

    if shouldThrottle then
        local last_msg = last_debug_messages[msg_key]
        local last_time = last_debug_times[msg_key]

        if last_msg == msg_key and last_time == current_time then
            return
        end

        last_debug_messages[msg_key] = msg_key
        last_debug_times[msg_key] = current_time
    end

    local timestamp = os.date("%H:%M:%S")
    print('[RQ][' .. timestamp .. '][DEBUG] ' .. msg_key)
end
debug("Radial queue v" .. VERSION .. " loaded.", true)

local function getHunterCharacter() 
    local MasterPlayer = sdk.get_managed_singleton("app.PlayerManager"):get_field("_PlayerList")[0]

	if MasterPlayer == nil then 
		return 
	end

	HunterCharacter = MasterPlayer:get_field("_PlayerInfo"):get_field("<Character>k__BackingField")
	if HunterCharacter == nil then
		return
    end

    return HunterCharacter
end

local function getHunterCharacterCombat()
    HunterCharacter = getHunterCharacter()

    if HunterCharacter:call("get_IsCombat()") == true  
        or HunterCharacter:call("get_IsCombatBoss()") == true then
        return true
    else
        return false
	end
end

local function setInputSource(instance)
    if instance == nil then
        return
    end
      --ID 100, 101(TU2) for M+KB, 55 for Radial
    sourceInput = instance:get_field("_PartsOwnerAccessor"):get_field("_Owner"):get_ID()
    if sourceInput ~= SOURCE_MKB and sourceInput ~= SOURCE_RADIAL then
        debug("setInputSource - Unknown sourceInput: " .. tostring(sourceInput))
        return
    end

    if sourceInput == nil then
        return
    end
end

local function getUserdataToInt(args)
    return tonumber(string.sub(string.gsub(tostring(args), "userdata: ", ""), -2), 16)
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

function updateShortcutTable(table_shortcutRecipeItem, item, recipe)
    table.insert(table_shortcutRecipeItem, {itemId = item, recipeId = recipe})
end

local function updateShortcut(retval)
    if instance_activeShortcut == nil then
        return
    end
    instance_activeShortcut:call("update()")
end

local function stopExecution(msg)
    if msg then 
        debug("STOP - " .. msg)
    end
    
    itemSuccess = true
    resetTime = nil
    sourceInput = nil 
    GUI020600_itemIndex_current = nil
    instance = nil
    isCrafting = false
    isCraftingRecipeOnly = nil
    craftingRecipeID = nil
    instance_activeShortcut = nil
    table_shortcutRecipeItem = {}
    shortcutIsEnabled = nil
    shortcutPreviousItemId = nil
    cancelCountDodge = 0
    executing = false
end

local function cancelOnShortcutItemId(_itemId)
    if 
        _itemId == -1 
    or  _itemId == 780 --SSF
    or  _itemId == 781 --SSF
    or  _itemId == 782 --SSF
    then
        return true
    end
    return false
end


local function checkIsShortcutSelected(args)
    if args == nil then
        return
    end

    if sdk.to_managed_object(args[2]):get_field("<_Selected>k__BackingField") == true then 
        shortcutIsSelected = true
        --shortcutItemId = getUserdataToInt(sdk.to_managed_object(args[2]):get_field("<ItemId>k__BackingField"))
        shortcutItemId = sdk.to_managed_object(args[2]):call("get_ItemId()")
        --local get_ItemId = sdk.to_managed_object(args[2]):get_ItemId()
        --debug("checkIsShortcutSelected - ItemId: " .. shortcutItemId)
        --local s_type                = getUserdataToInt(sdk.to_managed_object(args[2]):get_field("<Type>k__BackingField"))
        --local s_recipeId            = sdk.to_managed_object(args[2]):get_field("<RecipeId>k__BackingField")
        --local s_CommunicationId     = sdk.to_managed_object(args[2]):get_field("<CommunicationId>k__BackingField")
        --local _ShortcutItemParam    = sdk.to_managed_object(args[2]):get_field("<_ShortcutItemParam>k__BackingField")
        --local _param_type           = getUserdataToInt(_ShortcutItemParam:get_field("Type"))
        --local _param_itemId         = getUserdataToInt(_ShortcutItemParam:get_field("Value"))

        --debug("checkIsShortcutSelected---------------------------")
        --debug("get_ItemId: " .. shortcutItemId)
        --debug("Shortcut itemId: " .. tostring(shortcutItemId))
        --debug("Shortcut recipeId: " .. tostring(s_recipeId)) 
        --debug("Shortcut type: " .. tostring(s_type))
        --debug("Shortcut communicationId: " .. tostring(s_CommunicationId))
        --debug("Shortcut _param_type: " .. tostring(_param_type))
        --debug("Shortcut _param_itemId: " .. tostring(_param_itemId))
        --debug("checkIsShortcutSelected------------------------END") 

        
        
        if cancelOnShortcutItemId(shortcutItemId) == true then 
            if config.IgnoreDisabledShortcut == false then
                stopExecution("Cancel by ID: " .. tostring(shortcutItemId))
            end
        end

        if shortcutPreviousItemId == nil then
            shortcutPreviousItemId = shortcutItemId
        elseif shortcutPreviousItemId ~= shortcutItemId then
            if sourceInput == SOURCE_RADIAL then
                stopExecution("ShortcutItemId changed")
            end
            shortcutPreviousItemId = shortcutItemId
        end
    else
        shortcutIsSelected = false
    end
    
end

local function checkIsShortcutEnabled(retval)
    if shortcutIsSelected == true then
        local ret = getUserdataToInt(sdk.to_ptr(retval))
        if ret == 1 then
            shortcutIsEnabled = true
        else
            shortcutIsEnabled = false
        end
    end

    return retval
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
        elseif getHunterCharacterCombat() == false and config.EnableNoCombatTimer == true then
            resetTime = os.time() + config.ResetTimerNoCombat
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
           stopExecution("checkIfTimerCancel")
           resetTime = nil
       end
    end
end

local function checkCancelPotionMaxHealth(args)
    if args == nil then
        return
    end

    local hunterHealth = getHunterCharacter():call("get_HunterHealth()")
    local healthmanager = hunterHealth:get_field("<HealthMgr>k__BackingField")
    local health = healthmanager:get_Health()
    local maxHealth = healthmanager:get_MaxHealth()


    -- Todo, check hunter health if should cancel
    local itemId = getUserdataToInt(args[2])
    --debug("hunterActionId: " .. tostring(itemId))
    
    if     itemId == 1 --Potion
        or itemId == 2 --Mega Potion
        and health == maxHealth
    then
        stopExecution("checkCancelPotionMaxHealth")
    end
end


local function setMantleEquipped(args)
    local hunterSkillController = sdk.to_managed_object(args[2])
    local isMasterPlayer = hunterSkillController:get_field("_Hunter"):get_IsMaster()
    if isMasterPlayer == false then
        return
    end

    local skillType = hunterSkillController:get_field("_CurrentSkillType")
    debug(skillType)

    if isMasterPlayer and (rocksteadyEquipped == false or rocksteadyEquipped == nil) and skillType == 1 then
        rocksteadyEquipped = true
        debug("Rocksteady equipped: " .. tostring(rocksteadyEquipped))
    end
end

local function checkMantleRemoval(args)
    local hunterSkillController = sdk.to_managed_object(args[2])
    local isMasterPlayer = hunterSkillController:get_field("_Hunter"):get_IsMaster()

    if isMasterPlayer == false then
        return
    end

    local skillType = hunterSkillController:get_field("_CurrentSkillType")

    if isMasterPlayer and rocksteadyEquipped == true and skillType == 1 then
        rocksteadyEquipped = false
        debug("Rocksteady unequipped or expired: " .. tostring(rocksteadyEquipped))
    end
end



--= Core functions ========================================================================--
local function saveItem(args)
    if executing == false then
        executing = true
        debug("START - ItemID: " .. tostring(shortcutItemId))
    end
    if config.Enable == false then 
        return 
    end

    instance = sdk.to_managed_object(args[2])
    setInputSource(instance

    if sourceInput == SOURCE_MKB then
        GUI020600_itemIndex_current = getUserdataToInt(args[3])
        debug("itemIndex - " .. GUI020600_itemIndex_current)
        shortcutPreviousItemId = nil
    end

    itemSuccess = false
    shouldSkipPad = true
end

local function checkCraftingDetails(args)

    local itemAmount = sdk.to_int64(args[4])
    if not itemAmount then return end
    
    isCrafting = true
    craftingRecipeID = sdk.to_managed_object(args[2]):get_field("_ResultItem")
    craftingRecipeID = craftingRecipeID - 1
    debug("checkCraftingDetailsId: " .. tostring(craftingRecipeID))
   
    if itemAmount >= 2 then
        stopExecution("checkCraftingDetails")
    else
        return
    end  
end

local function checkShortcutType(args) 
    if sdk.to_managed_object(args[2]):get_field("<_Selected>k__BackingField") == true and craftingRecipeID == sdk.to_managed_object(args[2]):get_field("<ItemId>k__BackingField")  then 
        instance_activeShortcut = sdk.to_managed_object(args[2])
    end
    if instance_activeShortcut == nil then return end
    
    local shortcutRecipeItemID = instance_activeShortcut:get_field("<ItemId>k__BackingField")
    local shortcutRecipeID = instance_activeShortcut:get_field("<RecipeId>k__BackingField")

    updateShortcutTable(table_shortcutRecipeItem, shortcutRecipeItemID, shortcutRecipeID)
end

local function retryShortcut(args)
    if instance == nil or itemSuccess == true then
        return
    end

    if sourceInput == SOURCE_RADIAL then
        instance:call("updateShortcut()")
    end
    if instance_activeShortcut ~= nil then
        instance_activeShortcut:call("update()")
    end

    if sourceInput == SOURCE_RADIAL and shortcutIsEnabled == false then
        if config.IgnoreDisabledShortcut == false then
            stopExecution("Shortcut is disabled")
        end
    end

    checkIfTimerCancel()

    local recipeUnavailable = false
    if table_shortcutRecipeItem ~= nil then
        for _, entry in ipairs(table_shortcutRecipeItem) do
            if type(entry) == "table" then
                --debug("Entry: itemId = " .. tostring(entry.itemId) .. ", recipeId = " .. tostring(entry.recipeId))

                if (entry.recipeId == -1 or entry.recipeId == "-1") then
                    recipeUnavailable = true
                    break
                end
            end
        end
    else
        debug("table_shortcutRecipeItem is nil")
    end

    if (recipeUnavailable == true and isCrafting == true) or (recipeUnavailable == false and isCrafting == false) then
        --debug("retryShortcut - recipeUnavailable - MATCH -1")
        if itemSuccess == false then
            if executing == true then
                debug("RETRY - ItemId: " .. tostring(shortcutItemId))
            end    

            if sourceInput == SOURCE_MKB and GUI020600_itemIndex_current ~= nil then
                instance:call('execute(System.Int32)', GUI020600_itemIndex_current)
            elseif sourceInput == SOURCE_RADIAL then
                instance:call('useActiveItem(System.Boolean)', nil)
            else
                return
            end
        else 
            return
        end 
    else
        stopExecution("Crafting recipe detected")
    end
end


--= Cancel triggers =======================================================================--
local function cancelTriggerAttack(args) 
    local obj_weapon = sdk.to_managed_object(args[2])
    
    if obj_weapon:get_IsMaster() == true then
        stopExecution("cancelTriggerAttack")
    end
end

local function cancelTriggerWpAction(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("_Character")
    
    if isMasterPlayer:get_IsMaster() == true then
        stopExecution("cancelTriggerWpAction")
    end
end

local function cancelTriggerReceivedHit(args)
    if (config.EnableCancelControl == true and config.DisableCancelHitReceived == true) then return end

    if sdk.to_managed_object(args[3]):get_field("<DamageHit>k__BackingField"):get_field("_Owner"):get_Name() ~= "MasterPlayer" 
    and sdk.to_managed_object(args[3]):get_field("<AttackData>k__BackingField"):get_field("_FriendHitType") ~= 0  then 
        return 
    end
   
    local hitInfo = sdk.to_managed_object(args[3])
    local damageReceiverIsMasterPlayer = hitInfo:get_field("<DamageHit>k__BackingField"):get_field("_Owner"):get_Name()
    local isFriendlyHit     = getUserdataToInt(hitInfo:get_field("<AttackData>k__BackingField"):get_field("_FriendHitType"))
    local damageType        = getUserdataToInt(hitInfo:get_field("<AttackData>k__BackingField"):get_field("_DamageType"))
    local attack            = getUserdataToInt(hitInfo:get_field("<AttackData>k__BackingField"):get_field("_Attack"))
    local damageLevel       = getUserdataToInt(hitInfo:get_field("<AttackData>k__BackingField"):get_field("_DamageLevel"))
    local StageDamageType   = getUserdataToInt(hitInfo:get_field("<AttackData>k__BackingField"):get_field("_StageDamageType"))

    if isFriendlyHit ~= 0 then return end
    if damageType == -1 then return end
    if attack == 0 then return end

    if damageReceiverIsMasterPlayer == "MasterPlayer" and rocksteadyEquipped == false then
       debug("----- ATTACK DATA -----")
       debug("-- damageType: " .. tostring(damageType))
       debug("-- attack: " .. tostring(attack))
       debug("-- damageLevel: " .. tostring(damageLevel))
       debug("-- StageDamageType: " .. tostring(StageDamageType))
       debug("-----------------------")
       stopExecution("cancelTriggerReceivedHit")
    end

end

local function cancelTriggerDodge(args)
    local obj_hunterBadconditionsHunterCharacter = sdk.to_managed_object(args[3])
    
    if obj_hunterBadconditionsHunterCharacter:get_IsMaster() == true then
        if (config.EnableCancelControl == true and config.DisableCancelForXDodge == true) then
            cancelCountDodge = cancelCountDodge + 1

            if cancelCountDodge > config.DodgePersistCount then
                stopExecution("DodgePersistCount")
            end
        else
            stopExecution("cancelTriggerDodge")
        end
    end
end

local function cancelTriggerSeikret(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("_Character")

    if isMasterPlayer:get_IsMaster() == true then
        stopExecution("cancelTriggerSeikret")
    end
end

local function cancelTriggerSeikretDismount(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("<Chara>k__BackingField")

    if isMasterPlayer:get_IsMaster() == true then
        stopExecution("cancelTriggerSeikretDismount")
    end
end

local function cancelTriggerSlingerLoad(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("_Character")
    
    if isMasterPlayer:get_IsMaster() == true then
        stopExecution("cancelTriggerSlingerLoad")
    end
end

local function cancelTriggerOtomo(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("_OwnerHunter")

    if isMasterPlayer:get_IsMaster() == true then
        stopExecution("cancelTriggerOtomo(emote)")
    end
end

local function cancelTriggerBonfire(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("_Chara")
    if isMasterPlayer:get_IsMaster() == true then
        stopExecution("cancelTriggerBonfire")
    end
end

local function cancelTriggerFishing(args)

    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("Chara")
    if isMasterPlayer:get_IsMaster() == true then
        stopExecution("cancelTriggerFishing")
    end
end

local function cancelTriggerForce(args)
    itemSuccess = false
    stopExecution("cancelTriggerForce")
end


--= Visual indicator =======================================================================--
local alpha_time = 0.0
local last_time = os.clock()
local fade_out_time = 0.0
local was_item_success = false
local fading_out = false
local initial_fade_radius = 0.0
local final_fade_radius = 0.0
local should_draw = nil

local function draw_indicator_circle(x, y, radius, color)
    local num_segments = 32
    draw.filled_circle(x, y, radius, color, num_segments)
end

re.on_frame(function()
    if config.IndicatorEnable == false then return end

    local show_indicator = (itemSuccess == false) or (config.IndicatorShowInMenu and reframework:is_drawing_ui())

    local current_time = os.clock()
    local dt = current_time - last_time
    last_time = current_time

    local x = config.IndicatorPosX
    local y = config.IndicatorPosY
    local base_radius = config.IndicatorBaseRadius
    local growth = config.IndicatorPulseGrowth
    local fade_duration = config.IndicatorFadeDuration

    -- Only show if active OR menu preview enabled
    if itemSuccess == false or show_indicator == true then
        -- Reset fade tracking
        fade_out_time = 0.0
        fading_out = false

        -- Animate pulse
        alpha_time = alpha_time + dt

        local pulse_speed = config.IndicatorPulseSpeed or 1.0
        local sine = (math.sin(alpha_time * 2.0 * math.pi * pulse_speed) + 1.0) / 2.0

        -- Visual alpha (fade from min_alpha to 1)
        local min_alpha = config.IndicatorMinimumPulseAlpha or 0.0
        local visual_alpha = min_alpha + ((config.IndicatorMaxPulseAlpha or 1.0) - min_alpha) * sine

        -- Pulse growth only depends on the sine
        local radius = base_radius
        if config.IndicatorShouldPulse then
            radius = base_radius + (growth * sine)
        end

        -- Save current radius for use in fade out
        initial_fade_radius = radius
        final_fade_radius = base_radius + growth + 5

        -- Apply color with dynamic alpha
        local alpha_byte = math.floor(visual_alpha * 255)
        local color = (alpha_byte << 24) | (config.IndicatorColorPending & 0x00FFFFFF)

        draw_indicator_circle(x, y, radius, color)
    else
        -- First success transition
        if not was_item_success and show_indicator then
            fade_out_time = 0.0
            fading_out = true
        end

        -- Handle fading with radius growth
        if config.IndicatorShouldFade and fade_out_time <= fade_duration then
            fade_out_time = fade_out_time + dt
            local t = math.min(fade_out_time / fade_duration, 1.0)

            local alpha = 1.0 - t
            local alpha_byte = math.floor(alpha * 255)

            -- Interpolate radius from previous pulse to final size
            local radius = initial_fade_radius + (final_fade_radius - initial_fade_radius) * t
            local color = (alpha_byte << 24) | (config.IndicatorColorSuccess & 0x00FFFFFF)

            draw_indicator_circle(x, y, radius, color)

        elseif not config.IndicatorShouldFade then
            draw_indicator_circle(x, y, base_radius, config.IndicatorColorSuccess)
        end
    end

    -- Store last state
    was_item_success = itemSuccess
end)


--= Hooks =================================================================================--
if config.Enable == true then
    --= Main loop =========================================================================--
    -- Radial menu
    if type_GUI020008 then
        sdk.hook(type_GUI020008:get_method('onOpenApp'), function(args) stopExecution('type_GUI020008_onOpenApp') end, nil)
        sdk.hook(type_GUI020008:get_method("useActiveItem"), saveItem, nil)
    end

    -- M+KB
    if type_GUI020600 then
        sdk.hook(type_GUI020600:get_method("execute"), saveItem, nil)
        sdk.hook(type_GUI020600:get_method("onHudClose"), function(args) stopExecution("type_GUI020600_onHudClose") end, nil)
    end

    --Check crafting itemAmount for logic
    if type_ItemRecipeUtil then
        sdk.hook(type_ItemRecipeUtil:get_method("craft"), checkCraftingDetails, updateShortcut)
    end

    -- Check shortcut type
    if type_cCustomShortcutElement then
        sdk.hook(type_cCustomShortcutElement:get_method("update"), checkShortcutType, nil)
        sdk.hook(type_cCustomShortcutElement:get_method("isEnable"), checkIsShortcutSelected, checkIsShortcutEnabled)
    end

    -- Retry shortcut execution
    if type_PlayerManager then
        sdk.hook(type_PlayerManager:get_method("update"), retryShortcut, nil)
    end

    -- Item used successfully
    if type_HunterExtendBase then
        sdk.hook(type_HunterExtendBase:get_method("successItem(app.ItemDef.ID, System.Int32, System.Boolean, ace.ShellBase, System.Single, System.Boolean, app.ItemDef.ID, System.Boolean)"), function(args) stopExecution("type_HunterExtendBase_successItem") end, nil)
    end
    
    --= Cancel events =================================================================--
    if type_Hit then
        sdk.hook(type_Hit:get_method("callHitReturnEvent(System.Delegate[], app.HitInfo)"), cancelTriggerReceivedHit, nil)
    end

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

    -- Porter dismount
    if type_cPorterDismountBase then
        sdk.hook(type_cPorterDismountBase:get_method("doEnter"), cancelTriggerSeikretDismount, nil)
    end

    if type_cPorterDismountJumpOff then
        sdk.hook(type_cPorterDismountJumpOff:get_method("doEnter"), cancelTriggerSeikretDismount, nil)
    end

    -- Guarding
    local type_Wp00 = sdk.find_type_definition("app.Wp00Action.cGuard")
    if type_Wp00 then sdk.hook(type_Wp00:get_method("doEnter"), cancelTriggerWpAction, nil) end

    local type_Wp01 = sdk.find_type_definition("app.Wp01Action.cGuard")
    if type_Wp01 then sdk.hook(type_Wp01:get_method("doEnter"), cancelTriggerWpAction, nil) end

    local type_Wp06 = sdk.find_type_definition("app.Wp06Action.cGuard")
    if type_Wp06 then sdk.hook(type_Wp06:get_method("doEnter"), cancelTriggerWpAction, nil) end

    local type_Wp07 = sdk.find_type_definition("app.Wp07Action.cGuard")
    if type_Wp07 then sdk.hook(type_Wp07:get_method("doEnter"), cancelTriggerWpAction, nil) end

    local type_Wp09 = sdk.find_type_definition("app.Wp09Action.cGuard")
    if type_Wp09 then sdk.hook(type_Wp09:get_method("doEnter"), cancelTriggerWpAction, nil) end

    -- Stamp
    if type_ChatManager then
        sdk.hook(type_ChatManager:get_method("sendStamp"), function(args) stopExecution("type_ChatManager_sendStamp") end, nil)
        sdk.hook(type_ChatManager:get_method("sendFreeText"), function(args) stopExecution("type_ChatManager_sendFreeText") end, nil)
        sdk.hook(type_ChatManager:get_method("sendManualText"), function(args) stopExecution("type_ChatManager_sendManualText") end, nil)
    end

    -- Slinger reload
    if type_PlayerCommonSubActionUseSlingerItem then
        sdk.hook(type_PlayerCommonSubActionUseSlingerItem:get_method("doEnter"), cancelTriggerSlingerLoad, nil)
    end

    -- Pause
    if type_PauseManagerBase then
        sdk.hook(type_PauseManagerBase:get_method("requestPause"), cancelTriggerForce, nil)
    end

    -- Photo mode
    if type_PhotoCameraController then
        sdk.hook(type_PhotoCameraController:get_method("enable"), cancelTriggerForce, nil)
    end

    -- Map
    if type_cGUIMapController then
        sdk.hook(type_cGUIMapController:get_method("requestOpen"), cancelTriggerForce, nil)
    end

    -- Binoculars
    if type_cSougankyo then
        sdk.hook(type_cSougankyo:get_method("enter"), cancelTriggerForce, nil)
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

    -- Member list
    if type_GUI040000 then
        sdk.hook(type_GUI040000:get_method("onOpenApp"), cancelTriggerForce, function(retval) debug("STOP - type_GUI040000") end)
    end

    -- Invitation list
    if type_GUI040002 then
        sdk.hook(type_GUI040002:get_method("onOpen"), cancelTriggerForce, function(retval) debug("STOP - type_GUI040002") end)
    end

    -- Map ping
    if type_cGUI060000 then
        sdk.hook(type_cGUI060000:get_method("playSignCore"), cancelTriggerForce, function(retval) debug("STOP - type_cGUI060000") end)
    end

    -- Chat log
    if type_ChatLogCommunication then
        sdk.hook(type_ChatLogCommunication:get_method("start(app.GUIFlowChatLogCommunication.BOOT, ace.IGUIFlowHandle)"), cancelTriggerForce, function(retval) debug("STOP - type_ChatLogCommunication") end)
    end

    --= Misc utility ==================================================================--
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

    -- Get ItemID for potion cancel
    if type_HunterItemActionTable then
        sdk.hook(type_HunterItemActionTable:get_method("getItemActionTypeFromItemID"), checkCancelPotionMaxHealth, nil)
    end

   
    -- Mantle control
    if type_mcHunterArmorControl then
        sdk.hook(type_mcHunterArmorControl:get_method("updateMain"), getIsRockSteadyOn, nil)
    end

    if type_mcActiveSkillController then
        sdk.hook(type_mcActiveSkillController:get_method("startASkillEffectiveTimer"), setMantleEquipped, nil)
        sdk.hook(type_mcActiveSkillController:get_method("endASkillWearMantleEffectiveTimer"), checkMantleRemoval, nil)
        sdk.hook(type_mcActiveSkillController:get_method("doUnmantle"), checkMantleRemoval, nil)
    end
end


