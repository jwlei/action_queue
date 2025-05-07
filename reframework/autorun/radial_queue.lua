-- @Author taakefyrsten
-- https://next.nexusmods.com/profile/taakefyrsten
-- https://github.com/jwlei/radial_queue
-- Version 1.9v4

-- INIT ------------------------------------
local debug_flag = true
local instance = nil
local itemSuccess = nil
local cancelCount = 0
--local cancelCountDodge = 0
local shouldSkipPad = true
local resetTime = nil
local HunterCharacter = nil
local loadedTable = nil
local sourceInput = nil
local GUI020600_itemIndex_current = nil
local craftingCount = 0
local craftingItemId = nil
local isCrafting = false
local isCraftingRecipeOnly = nil
local cShortcutObj = nil
local shortcutIdRecipes = {}

--app.GUI020006.requestOpenItemSlider Item bar
--app.GUI020007 Radial M+KB
local type_GUI020006 = sdk.find_type_definition("app.GUI020006") -- Item bar
local type_GUI020008 = sdk.find_type_definition("app.GUI020008") -- Radial Menu
local type_GUI020008PartsRotateFrame = sdk.find_type_definition("app.GUI020008PartsRotateFrame") -- Radial Menu 2
local type_GUI020600 = sdk.find_type_definition("app.GUI020600") -- M+KB item select
local type_GUI020600PartsFrame = sdk.find_type_definition("app.GUI020600PartsFrame") -- M+KB item select 2
local type_GUI030208 = sdk.find_type_definition("app.GUI030208") -- Radial customization
local type_GUI040000 = sdk.find_type_definition("app.GUI040000") -- Member list
local type_GUI040002 = sdk.find_type_definition("app.GUI040002") -- Invitation list
local type_cGUI060000 = sdk.find_type_definition("app.cGUI060000Sign.cMapPlayerSign") -- Mini map ping
local type_ChatLogCommunication = sdk.find_type_definition("app.GUIFlowChatLogCommunication") -- Chat log
local type_HunterExtendBase = sdk.find_type_definition("app.HunterCharacter.cHunterExtendBase")
local type_PlayerManager = sdk.find_type_definition("app.PlayerManager")
local type_cHunterBadConditions = sdk.find_type_definition("app.HunterBadConditions.cHunterBadConditions")
local type_Weapon = sdk.find_type_definition("app.Weapon")
local type_cGUIShortcutPadControl = sdk.find_type_definition("app.cGUIShortcutPadControl")
local type_HunterItemActionTable = sdk.find_type_definition("app.HunterItemActionTable")
local type_ChatManager = sdk.find_type_definition("app.ChatManager")
local type_PlayerCommonSubActionUseSlingerItem = sdk.find_type_definition("app.PlayerCommonSubAction.cUseSlingerItem")
local type_mcOtomoCommunicator = sdk.find_type_definition("app.mcOtomoCommunicator")
local type_cCallPorter = sdk.find_type_definition("app.PlayerCommonSubAction.cCallPorter")
local type_cPorterDismountBase = sdk.find_type_definition("app.PlayerCommonAction.cPorterDismountBase")
local type_cPorterDismountJumpOff = sdk.find_type_definition("app.PlayerCommonAction.cPorterDismountJumpOff")
local type_mcHunterBonfire = sdk.find_type_definition("app.mcHunterBonfire")
local type_mcHunterFishing = sdk.find_type_definition("app.mcHunterFishing")
local type_PauseManagerBase = sdk.find_type_definition("ace.PauseManagerBase")
local type_PhotoCameraController = sdk.find_type_definition("app.PhotoCameraController")
local type_cGUIMapController = sdk.find_type_definition("app.cGUIMapController")
local type_cSougankyo = sdk.find_type_definition("app.CameraSubAction.cSougankyo")
local type_ItemRecipeUtil = sdk.find_type_definition("app.ItemRecipeUtil")
local type_Hit = sdk.find_type_definition("app.Hit")
local type_cCustomShortcutElement = sdk.find_type_definition("app.cCustomShortcutElement")
-- SETTINGS --------------------------------

local config = {
    Enable = true,  -- Toggle mod
    EnableNoCombatTimer = true,
    ResetTimerNoCombat = 1, -- Time in seconds to reset item use
    EnableCombatTimer = false,
    ResetTimerCombat = 15,
    --EnableDodgePersist = false,
    --DodgePersistCount = 0,
    IndicatorEnable = false,
    IndicatorPosX = 720,
    IndicatorPosY = 100,
    IndicatorBaseRadius = 15,
    IndicatorColorPending = 3356920024, 
    IndicatorColorSuccess = 3355508539,
    IndicatorShouldFade = true,
    IndicatorFadeDuration = 0.5,
    IndicatorShouldPulse = true,
    IndicatorPulseSpeed = 1.0,
    IndicatorPulseGrowth = 10,
    IndicatorShowInMenu = true,
    IndicatorMinimumPulseAlpha = 0.5,
    IndicatorMaxPulseAlpha = 1.0
}

local function debug(msg)
    if debug_flag == true then
        local timestamp = os.date("%H:%M:%S")
        print('[RQ]' .. '[' .. timestamp .. ']'.. '[DEBUG] ' .. tostring(msg))
    end
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

        if config.IndicatorEnable == nil then
            config.IndicatorEnable = 0
        end

        if config.IndicatorPosX == nil then
            config.IndicatorPosX = 720
        end

        if config.IndicatorPosY == nil then
            config.IndicatorPosY = 100
        end

        if config.IndicatorBaseRadius == nil then
            config.IndicatorBaseRadius = 20
        end
           
        if config.IndicatorColorPending == nil then
            config.IndicatorColorPending = 3356920024
        end

        if config.IndicatorColorSuccess == nil then
            config.IndicatorColorSuccess = 3355508539
        end

        if config.IndicatorShouldFade == nil then
            config.IndicatorShouldFade = 1
        end

        if config.IndicatorFadeDuration == nil then
            config.IndicatorFadeDuration = 0.5
        end

        if config.IndicatorShouldPulse == nil then
            config.IndicatorShouldPulse = 1
        end

        if config.IndicatorPulseSpeed == nil then
            config.IndicatorPulseSpeed = 1.0
        end

        if config.IndicatorPulseGrowth == nil then
            config.IndicatorPulseGrowth = 10
        end

        if config.IndicatorShowInMenu == nil then
            config.IndicatorShowInMenu = 1
        end

        if config.IndicatorMinimumPulseAlpha == nil then
            config.IndicatorMinimumPulseAlpha = 0.5
        end

        if config.IndicatorMaxPulseAlpha == nil then
            config.IndicatorMaxPulseAlpha = 1.0
        end
    else
        save_config()
    end
end

load_config()



-- Core functions ------------------------
local function setInputSource(instance)
    if instance == nil then
        return
    end
      --ID 100 for M+KB, 55 for Radial
    sourceInput = instance:get_field("_PartsOwnerAccessor"):get_field("_Owner"):get_ID()
  
    if sourceInput == nil then
        return
    end
end

local function getItemId(args)
    return tonumber(string.sub(string.gsub(tostring(args), "userdata: ", ""), -2), 16)
end

local function setItemSuccess()
       itemSuccess = true
       resetTime = nil
       cancelCount = 0
       sourceInput = nil 
       GUI020600_itemIndex_current = nil
       instance = nil
       isCraftingRecipeOnly = nil
       cShortcutObj = nil
       shortcutIdRecipes = {}
       --cancelCountDodge = 0
end

local function cancelUseItem()
    if itemSuccess == false then
        setItemSuccess()
    end
end

local function setIsCraftingTrue()
    isCrafting = true
end

local function setIsCraftingFalse()
    isCrafting = false
    craftingCount = 0
    debug("ISCRAFTING SET TO FALSE")
end

local function getHunterCharacter() 
    local Player = sdk.get_managed_singleton("app.PlayerManager"):get_field("_PlayerList")[0]

	if Player == nil then 
		return 
	end

	HunterCharacter = Player:get_field("_PlayerInfo"):get_field("<Character>k__BackingField")
	if HunterCharacter == nil then
		return
    end

    return HunterCharacter
end

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
           setItemSuccess()
           debug("setItemSuccess() from timer")
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
    -- Todo, check hunter health if should cancel
    local itemId = getItemId(args[2])
    
    if     itemId == 1 --Potion
        or itemId == 2 --Mega Potion
    then
        cancelCount = cancelCount + 1
    end

    if cancelCount >= 1 then
        setItemSuccess()
        debug("setItemSuccess() from checkItemIDforCancel")
    end
end

local savedItemTime = nil
local function saveItem(args)
    
    debug("saveItem")
    if config.Enable == false then 
        return 
    end

    instance = sdk.to_managed_object(args[2])
    setInputSource(instance)

    if sourceInput == 100 then
        GUI020600_itemIndex_current = getItemId(args[3])
    end

    itemSuccess = false
    shouldSkipPad = true
    savedItemTime = os.clock()
    --DodgePersistCount = 0
end

local function checkCraftAllorOne(args)
    debug("checkCraft")
    
    local itemAmount = sdk.to_int64(args[4])
    if not itemAmount then return end
    
    craftingItemId = sdk.to_managed_object(args[2]):get_field("_ResultItem")
    craftingItemId = craftingItemId - 1
    debug("checkCraftAllorOneId: " .. tostring(craftingItemId))
    if itemAmount == 1 then
        if sourceInput == 100 then
            setItemSuccess()
        elseif sourceInput == 55 then
            setIsCraftingTrue()
            
            craftingCount = craftingCount + 1
        else
            return
        end
        
    elseif itemAmount >= 2 then
        debug("ITEM SUCCESS FROM checkCraftAllorOne")
        setItemSuccess()
    else
        return
    end  
end


function updateShortcutTable(shortcutIdRecipes, recipe)
    table.insert(shortcutIdRecipes, recipe)
end

local function cShortcutFunc(args) 
    if sdk.to_managed_object(args[2]):get_field("<_Selected>k__BackingField") == true and craftingItemId == sdk.to_managed_object(args[2]):get_field("<ItemId>k__BackingField")  then 
        cShortcutObj = sdk.to_managed_object(args[2])
    end
    if cShortcutObj == nil then return end
    debug("cShortcutFunc -- Found matching shortcut")
    
    local cShortcutItemId = cShortcutObj:get_field("<ItemId>k__BackingField")
    local cShortcutRecipe = cShortcutObj:get_field("<RecipeId>k__BackingField")
    debug("updateShortcutItemId: " .. tostring(cShortcutItemId))
    debug("updateShortcutRecipe: " .. tostring(cShortcutRecipe))
    updateShortcutTable(shortcutIdRecipes, cShortcutRecipe)
end

local function updateShortcut(retval)
    cShortcutObj:call("update()")

end


local craftingCountsByFrame = {}
local function cancelTriggerGUI020008UpdateItem(args)
    if instance == nil then
        return
    end
    
    if craftingItemId == nil then return end
    local obj_GUI020008PRR = nil
    if sdk.to_managed_object(args[2]):get_field("<_ShortcutElement>k__BackingField"):get_field("<_Selected>k__BackingField") == true then
        obj_GUI020008PRR = sdk.to_managed_object(args[2])
    end
    if obj_GUI020008PRR == nil then return end

    local shortcutElement = obj_GUI020008PRR:get_field("<_ShortcutElement>k__BackingField")
    if shortcutElement == nil then return end

    local itemId = shortcutElement:get_field("<ItemId>k__BackingField")
    if craftingItemId - 1 ~= itemId then return end

    local isSelected = shortcutElement:get_field("<_Selected>k__BackingField")
    if isSelected == false then return end

    local num = shortcutElement:get_field("<Num>k__BackingField")
    local frameIndex = obj_GUI020008PRR:get_field("<FrameIndex>k__BackingField")

    if craftingCountsByFrame[frameIndex] == nil then
        craftingCountsByFrame[frameIndex] = 0
    end

    local currentCount = craftingCountsByFrame[frameIndex]

    instance:call("updateShortcut()")


    if (num == 0 or num == nil) and currentCount == 0 then
        craftingCountsByFrame[frameIndex] = 1
    elseif (num == 0 or num == nil) and currentCount >= 1 then
        isCraftingRecipeOnly = true
        setItemSuccess()
        --instance = nil
        debug("FrameIndex - count [" .. tostring(frameIndex) .. "]: " .. tostring(currentCount))
        craftingCountsByFrame[frameIndex] = 0
        craftingItemId = nil
    else
        isCraftingRecipeOnly = false
    end
end

local function cancelTriggerGUI0020600UpdateItem(args)
    if instance == nil then
        return
    end
    if craftingItemId == nil then return end
    local obj_GUI020600PR = nil
    if sdk.to_managed_object(args[2]):get_field("<_ShortcutElement>k__BackingField"):get_field("<_Selected>k__BackingField") == true then
        obj_GUI020600PR = sdk.to_managed_object(args[2])
    end
    if obj_GUI020600PR == nil then return end

    local shortcutElement = obj_GUI020600PR:get_field("<_ShortcutElement>k__BackingField")
    if shortcutElement == nil then return end

    local itemId = shortcutElement:get_field("<ItemId>k__BackingField")
    if craftingItemId - 1 ~= itemId then return end

    local isSelected = shortcutElement:get_field("<_Selected>k__BackingField")
    if isSelected == false then return end

    local num = shortcutElement:get_field("<Num>k__BackingField")
    local frameIndex = obj_GUI020600PR:get_field("<FrameIndex>k__BackingField")

    if craftingCountsByFrame[frameIndex] == nil then
        craftingCountsByFrame[frameIndex] = 0
    end

    local currentCount = craftingCountsByFrame[frameIndex]

    --instance:call("onHudClose()")
    --instance:call("guiHudVisibleUpdate()")


    if (num == 0 or num == nil) and currentCount == 0 then
        craftingCountsByFrame[frameIndex] = 1
    elseif (num == 0 or num == nil) and currentCount >= 1 then
        setItemSuccess()
        debug("FrameIndex - count [" .. tostring(frameIndex) .. "]: " .. tostring(currentCount))
        craftingCountsByFrame[frameIndex] = 0
        craftingItemId = nil
    else
        return
    end
end


local function tryUseItem(args)
    if instance == nil then
        return
    end

    local currentTime = os.clock()
    --if currentTime - savedItemTime < 0.5 then
    --    return -- Skip if called too soon
    --end

    savedItemTime = currentTime

    if sourceInput == 55 then
        instance:call("updateShortcut()")
    end
    cShortcutObj:call("update()")
    checkIfTimerCancel()

    
    if isCrafting then
        debug("tryUseItem - isCrafting")
        return 
    end
    
 
    local anyActualItem = false
    if shortcutIdRecipes ~= nil then
        for _, recipe in ipairs(shortcutIdRecipes) do
            if recipe == -1 or recipe == "-1" then
                anyActualItem = true
                break
            end
        end
    else
        debug("shortcutIdRecipes is nil")
    end

    if anyActualItem == true then
        debug("tryUseItem - anyActualItem - MATCH -1")
        if itemSuccess == false and isCrafting == false then
            debug("tryUseItem - Executing")
            if sourceInput == 100 and GUI020600_itemIndex_current ~= nil then
                instance:call('execute(System.Int32)', GUI020600_itemIndex_current)
            elseif sourceInput == 55 then
                instance:call('useActiveItem(System.Boolean)', nil)
            else
                return
            end
        else 
            return
        end 
    else
        debug("tryUseItem - anyActualItem - NO MATCH, ONLY RECIPES")
        setItemSuccess()
    end

    
end

local function cancelTriggerAttack(args) 
    local obj_weapon = sdk.to_managed_object(args[2])
    
    if obj_weapon:get_IsMaster() == true then
        debug("CANCELLED BY MASTERPLAYER ATTACK")
        setItemSuccess()
    end
end

local function cancelTriggerReceivedHit(args)
    local hitObj = sdk.to_managed_object(args[3]):get_field("<DamageHit>k__BackingField")
    local damageReceiver = hitObj:get_field("_Owner"):get_Name()
    if damageReceiver == nil then return end

    if damageReceiver == "MasterPlayer" then
       debug("CANCELLED BY MASTERPLAYER HIT RECEIVED")
        setItemSuccess()
    end
end

local function cancelTriggerDodge(args)
    local obj_hunterBadconditionsHunterCharacter = sdk.to_managed_object(args[3])
    
    if obj_hunterBadconditionsHunterCharacter:get_IsMaster() == true then
        debug("CANCELLED BY  MASTERPLAYER DODGE")
        setItemSuccess()
        --[[
        if config.EnableDodgePersist == true then
            cancelCountDodge = cancelCountDodge + 1
            debug(cancelCountDodge)
            if cancelCountDodge > config.DodgePersistCount then
                debug("CANCELLED BY DODGE PERSIST")
                setItemSuccess()
            end
        else
            setItemSuccess()
        end
        ]]
    end
end

local function cancelTriggerSeikret(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("_Character")

    if isMasterPlayer:get_IsMaster() == true then
        debug("CANCELLED BY MASTERPLAYER SEIKRET")
        setItemSuccess()
    end
end

local function cancelTriggerSeikretDismount(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("<Chara>k__BackingField")

    if isMasterPlayer:get_IsMaster() == true then
        debug("CANCELLED BY MASTERPLAYER SEIKRET DISMOUNT BASE")
        setItemSuccess()
    end
end

local function cancelTriggerWpAction(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("_Character")
    
    if isMasterPlayer:get_IsMaster() == true then
        debug("CANCELLED BY MASTERPLAYER WPXX")
        setItemSuccess()
    end
end

local function cancelTriggerSlingerLoad(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("_Character")
    
    if isMasterPlayer:get_IsMaster() == true then
        debug("CANCELLED BY MASTERPLAYER SLINGER LOAD")
        setItemSuccess()
    end
end

local function cancelTriggerOtomo(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("_OwnerHunter")

    if isMasterPlayer:get_IsMaster() == true then
        debug("CANCELLED BY MASTERPLAYER OTOMO")
        setItemSuccess()
    end
end

local function cancelTriggerBonfire(args)
    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("_Chara")
    if isMasterPlayer:get_IsMaster() == true then
        debug("CANCELLED BY MASTERPLAYER BONFIRE")
        setItemSuccess()
    end
end

local function cancelTriggerFishing(args)

    local isMasterPlayer = sdk.to_managed_object(args[2]):get_field("Chara")
    if isMasterPlayer:get_IsMaster() == true then
       debug("CANCELLED BY MASTERPLAYER FISHING")
        setItemSuccess()
    end
end
local function cancelTriggerForce(args)
    debug("CANCELLED BY cancelTriggerForce")
    itemSuccess = false
    setItemSuccess()
end


-- Indicator ------------------------------------
-- Initializer for indicator
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

        local pulse_speed = config.IndicatorPulseSpeed or 1.0  -- Default to 1.0 if unset
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
            -- No fade, just draw static green
            draw_indicator_circle(x, y, base_radius, config.IndicatorColorSuccess)
        end
    end

    -- Store last state
    was_item_success = itemSuccess
end)


if config.Enable == true then
    -- HOOKS --------------------------------
    -- Item used call and save
    if type_GUI020008 then
        sdk.hook(type_GUI020008:get_method('onOpenApp'), cancelUseItem, function(retval) debug("Canceled by type_GUI020008") end)
        sdk.hook(type_GUI020008:get_method("useActiveItem"), saveItem, nil)
        sdk.hook(type_GUI020008:get_method("callbackPouchChange(app.ItemDef.ID)"), setIsCraftingFalse, nil)
    end

    if type_GUI020008PartsRotateFrame then
        --sdk.hook(type_GUI020008PartsRotateFrame:get_method("updateItem"), cancelTriggerGUI020008UpdateItem, nil)
    end

    if type_Hit then
        sdk.hook(type_Hit:get_method("callHitReturnEvent(System.Delegate[], app.HitInfo)"), cancelTriggerReceivedHit, nil)
    end

    -- Save item from M+KB
    if type_GUI020600 then
        sdk.hook(type_GUI020600:get_method("execute"), saveItem, nil)
        --sdk.hook(type_GUI020600:get_method("requestOpenCraftWindow"), setIsCraftingTrue, nil)
    end

    if type_GUI020600PartsFrame then
        --sdk.hook(type_GUI020600PartsFrame:get_method("updateItem"), cancelTriggerGUI0020600UpdateItem, nil)
    end

    -- Retry item Use
    if type_PlayerManager then
        sdk.hook(type_PlayerManager:get_method("update"), tryUseItem, nil)
    end

    --Check crafting itemAmount for logic
    if type_ItemRecipeUtil then
        sdk.hook(type_ItemRecipeUtil:get_method("craft"), checkCraftAllorOne, updateShortcut)
    end

    if type_cCustomShortcutElement then
        sdk.hook(type_cCustomShortcutElement:get_method("update"), cShortcutFunc, nil)
    end

    -- Item used successfully
    if type_HunterExtendBase then
        sdk.hook(type_HunterExtendBase:get_method("successItem(app.ItemDef.ID, System.Int32, System.Boolean, ace.ShellBase, System.Single, System.Boolean, app.ItemDef.ID, System.Boolean)"), cancelUseItem, nil)
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

        -- Porter dismount
        if type_cPorterDismountBase then
            sdk.hook(type_cPorterDismountBase:get_method("doEnter"), cancelTriggerSeikretDismount, nil)
        end

        if type_cPorterDismountJumpOff then
            sdk.hook(type_cPorterDismountJumpOff:get_method("doEnter"), cancelTriggerSeikretDismount, nil)
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
        sdk.hook(type_ChatManager:get_method("sendStamp"), cancelUseItem, nil)
        sdk.hook(type_ChatManager:get_method("sendFreeText"), cancelUseItem, nil)
        sdk.hook(type_ChatManager:get_method("sendManualText"), cancelUseItem, nil)
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
        sdk.hook(type_GUI040000:get_method("onOpenApp"), cancelTriggerForce, function(retval) debug("cancelled by 40000") end)
    end

    -- Invitation list
    if type_GUI040002 then
        sdk.hook(type_GUI040002:get_method("onOpen"), cancelTriggerForce, function(retval) debug("cancelled by 40002") end)
    end

    -- Map ping
    if type_cGUI060000 then
        sdk.hook(type_cGUI060000:get_method("playSignCore"), cancelTriggerForce, function(retval) debug("cancelled by 06000") end)
    end

    -- Chat log
    if type_ChatLogCommunication then
        sdk.hook(type_ChatLogCommunication:get_method("start(app.GUIFlowChatLogCommunication.BOOT, ace.IGUIFlowHandle)"), cancelTriggerForce, function(retval) debug("cancelled by chatlog") end)
    end
end


-- reFramework config -----------------------------------------------------------------------------------------------------

re.on_draw_ui(function()
    if imgui.tree_node("Radial queue") then
        if imgui.checkbox("Enable", config.Enable) then
            config.Enable = not config.Enable
            save_config()
            load_config()
        end

        if config.Enable then
     
            imgui.text(" ")

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
            --[[
            if imgui.checkbox("Enable dodge persist", config.EnableDodgePersist) then
                config.EnableDodgePersist = not config.EnableDodgePersist
                save_config()
                load_config()
            end
            
            if config.EnableDodgePersist then
                local changed, new_value_DodgePersistCount = imgui.slider_int("Dodge persist count", config.DodgePersistCount, 0, 5)
                if changed then
                    config.DodgePersistCount = new_value_DodgePersistCount
                    save_config()
                    load_config()
                end
                if imgui.is_item_hovered() then
                    imgui.set_tooltip("Number of dodges in which the queued item will persist")
                end
            end
            ]]
        end

        imgui.text(" ")

        if imgui.checkbox("Enable Indicator", config.IndicatorEnable) then
            config.IndicatorEnable = not config.IndicatorEnable
            save_config()
            load_config()
        end

        if config.IndicatorEnable then
            if imgui.checkbox("Show preview in REFramework menu", config.IndicatorShowInMenu) then
                config.IndicatorShowInMenu = not config.IndicatorShowInMenu
                save_config()
                load_config()
            end

            local changedX, newX = imgui.slider_int("Position X", config.IndicatorPosX or 720, 0, 3840)
            if changedX then
                config.IndicatorPosX = newX
                save_config()
                load_config()
            end

            local changedY, newY = imgui.slider_int("Position Y", config.IndicatorPosY or 100, 0, 2160)
            if changedY then
                config.IndicatorPosY = newY
                save_config()
                load_config()
            end

            local changedRadius, newRadius = imgui.slider_int("Base Radius", config.IndicatorBaseRadius or 20, 1, 50)
            if changedRadius then
                config.IndicatorBaseRadius = newRadius
                save_config()
                load_config()
            end

            if imgui.checkbox("Pulse Radius", config.IndicatorShouldPulse) then
                config.IndicatorShouldPulse = not config.IndicatorShouldPulse
                save_config()
                load_config()
            end

            if config.IndicatorShouldPulse then
                local changedPulseSpeed, newPulseSpeed = imgui.slider_float("Pulse Speed", config.IndicatorPulseSpeed or 1.0, 0.1, 5.0)
                if changedPulseSpeed then
                    config.IndicatorPulseSpeed = newPulseSpeed
                    save_config()
                    load_config()
                end

                local changedMinAlpha, newMinAlpha = imgui.slider_float("Minimum Pulse Alpha", config.IndicatorMinimumPulseAlpha or 0.0, 0.0, 1.0)
                if changedMinAlpha then
                    config.IndicatorMinimumPulseAlpha = newMinAlpha
                    save_config()
                    load_config()
                end

                local changedMaxAlpha, newMaxAlpha = imgui.slider_float("Maximum Pulse Alpha", config.IndicatorMaxPulseAlpha or 1.0, 0.0, 1.0)
                if changedMaxAlpha then
                    config.IndicatorMaxPulseAlpha = newMaxAlpha
                    save_config()
                    load_config()
                end

                local changedGrowth, newGrowth = imgui.slider_int("Pulse Growth", config.IndicatorPulseGrowth or 0, 0, 50)
                if changedGrowth then
                    config.IndicatorPulseGrowth = newGrowth
                    save_config()
                    load_config()
                end
            end

            if imgui.checkbox("Fade On Success", config.IndicatorShouldFade) then
                config.IndicatorShouldFade = not config.IndicatorShouldFade
                save_config()
                load_config()
            end

            if config.IndicatorShouldFade then
                local changedFade, newFade = imgui.slider_float("Fade Duration (s)", config.IndicatorFadeDuration or 0.5, 0.1, 5.0)
                if changedFade then
                    config.IndicatorFadeDuration = newFade
                    save_config()
                    load_config()
                end
            end

            local changedPending, newPending = imgui.color_picker("Pending Color", config.IndicatorColorPending)
            if changedPending then
                config.IndicatorColorPending = newPending
                save_config()
                load_config()
            end

            local changedSuccess, newSuccess = imgui.color_picker("Success Color", config.IndicatorColorSuccess)
            if changedSuccess then
                config.IndicatorColorSuccess = newSuccess
                save_config()
                load_config()
            end
        end
        imgui.tree_pop()
    end
end)