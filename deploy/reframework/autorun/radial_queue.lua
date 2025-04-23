-- @Author taakefyrsten
-- https://next.nexusmods.com/profile/taakefyrsten
-- https://github.com/jwlei/radial_queue

-- INIT ------------------------------------
local instance = nil
local itemSuccess = nil
local cancelCount = 0

local sdk_GUI020008 = sdk.find_type_definition("app.GUI020008")
local sdk_HunterExtendBase = sdk.find_type_definition("app.HunterCharacter.cHunterExtendBase")
local sdk_PlayerManager = sdk.find_type_definition("app.PlayerManager")
local sdk_cHunterBadCondidions = sdk.find_type_definition("app.HunterBadConditions.cHunterBadConditions")
local sdk_Weapon = sdk.find_type_definition("app.Weapon")
local sdk_PlayerUtil = sdk.find_type_definition("app.PlayerUtil")
local sdk_cGUIShortcutPadControl = sdk.find_type_definition("app.cGUIShortcutPadControl")
local sdk_HunterItemActionTable = sdk.find_type_definition("app.HunterItemActionTable")
local sdk_ChatManager = sdk.find_type_definition("app.ChatManager")
local sdk_HunterCharacter = sdk.find_type_definition("app.HunterCharacter")
local sdk_WpCommonSubAction = sdk.find_type_definition("app.WpCommonSubAction.cAimStart")
--local sdk_PlayerCommonSubAction = sdk.find_type_definition("app.PlayerCommonSubAction.cSlingerAim")


-- SETTINGS --------------------------------

local settings = {
    Enable = true,  -- Toggle mod
}

local function debug(msg)
    local timestamp = os.date("%H:%M:%S")
    print('[IQ]' .. '[' .. timestamp .. ']'.. '[debug] ' .. tostring(msg))
end


local function save_settings()
    json.dump_file("ItemQueue.json", settings)
end

local function load_settings()
    local loadedTable = json.load_file("ItemQueue.json")
    if loadedTable then
        settings = loadedTable
        if settings.Enable == nil then
            settings.Enable = 1
        end
    else
        save_settings()
    end
end

load_settings()

-- Core functions ------------------------
local function saveItem(args)
    instance = sdk.to_managed_object(args[2])
    itemSuccess = false
end

local function tryUseItem(args)
    if instance == nil then
        return
    end

    if itemSuccess == false then 
        instance:call('useActiveItem(System.Boolean)', nil)
    else 
        return
    end 
end

local function setItemSuccess()
   itemSuccess = true
end

local function cancelUseItem(args)
    setItemSuccess()
end

--[[
local function cancelUseItemFocus(retval)
    if retval == nil then return end
    local isAim = (sdk.to_int64(retval) & 1)
  
    if isAim == 1 then
        setItemSuccess()
    end
end

]]

local function cancelUseItemFocus(args)
    local actionID = sdk.to_int64(args[4])
    -- 4835046936 focus
    debug(actionID)
    if actionID == 4835046936 then
        setItemSuccess()
    end
end

local function skipPadInput(args)
    if instance == nil then
        return
    end

    if instance:call('checkClose()') then
        return sdk.PreHookResult.SKIP_ORIGINAL
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


-- HOOKS --------------------------------
-- Item used call and save
if sdk_GUI020008 then
    sdk.hook(sdk_GUI020008:get_method('onOpenApp'), cancelUseItem, nil)
    sdk.hook(sdk_GUI020008:get_method("useActiveItem"), saveItem, nil)
end

-- Item used successfully
if sdk_HunterExtendBase then
    sdk.hook(sdk_HunterExtendBase:get_method("successItem(app.ItemDef.ID, System.Int32, System.Boolean, ace.ShellBase, System.Single, System.Boolean, app.ItemDef.ID, System.Boolean)"), cancelUseItem, nil)
end

-- Retry item Use
if sdk_PlayerManager then
    sdk.hook(sdk_PlayerManager:get_method("update"), tryUseItem, nil)
end

-- Skip pad control if HUD is closed
if sdk_cGUIShortcutPadControl then
    sdk.hook(sdk_cGUIShortcutPadControl:get_method("move(System.Single, via.vec2)"), skipPadInput, nil)
end 

-- Cancels
if itemSuccess == false or itemSuccess == nil then
    -- Focus
    if sdk_HunterCharacter then
        sdk.hook(sdk_HunterCharacter:get_method("changeActionRequest(app.AppActionDef.LAYER, ace.ACTION_ID, System.Boolean)"), cancelUseItemFocus, nil)
    end
    
    -- Dodge
    if sdk_cHunterBadCondidions then
        sdk.hook(sdk_cHunterBadCondidions:get_method("onDodgeAction(app.HunterCharacter, System.Boolean)"), cancelUseItem, nil)
    end

    -- Attack
    if sdk_Weapon then
        sdk.hook(sdk_Weapon:get_method("evAttackCollisionActive"), cancelUseItem, nil)
    end

    -- Seikret
    if sdk_PlayerUtil then
        sdk.hook(sdk_PlayerUtil:get_method("isPorterCallButtonOptionSucess"), cancelUseItem, nil)
    end

    -- Guarding
    local sdk_Wp00 = sdk.find_type_definition("app.Wp00Action.cGuard")
    if sdk_Wp00 then
        sdk.hook(sdk_Wp00:get_method("doEnter"), cancelUseItem, nil)
    end

    local sdk_Wp01 = sdk.find_type_definition("app.Wp01Action.cGuard")
    if sdk_Wp01 then
        sdk.hook(sdk_Wp01:get_method("doEnter"), cancelUseItem, nil)
    end

    local sdk_Wp06 = sdk.find_type_definition("app.Wp06Action.cGuard")
    if sdk_Wp06 then
        sdk.hook(sdk_Wp06:get_method("doEnter"), cancelUseItem, nil)
    end

    local sdk_Wp07 = sdk.find_type_definition("app.Wp07Action.cGuard")
    if sdk_Wp07 then
        sdk.hook(sdk_Wp07:get_method("doEnter"), cancelUseItem, nil)
    end

    local sdk_Wp09 = sdk.find_type_definition("app.Wp09Action.cGuard")
    if sdk_Wp09 then
        sdk.hook(sdk_Wp09:get_method("doEnter"), cancelUseItem, nil)
    end
end

if sdk_HunterItemActionTable then
    sdk.hook(sdk_HunterItemActionTable:get_method("getItemActionTypeFromItemID"), checkItemIDforCancel, nil)
end

-- Only send a single stamp
if sdk_ChatManager then
    sdk.hook(sdk_ChatManager:get_method("sendStamp"), cancelUseItem, nil)
end





--[[
if sdk_WpCommonSubAction then
    sdk.hook(sdk_WpCommonSubAction:get_method("doEnter"), cancelUseItem, nil)
end 

if sdk_PlayerCommonSubAction then
    sdk.hook(sdk_PlayerCommonSubAction:get_method("doUpdate"), cancelUseItem, nil)
end

]]


-- reFramework settings ----------------------------
re.on_draw_ui(function()
    if imgui.tree_node("Radial queue") then
        if imgui.checkbox("Radial queue", settings.Enable) then
            settings.Enable = not settings.Enable
            save_settings()
        end
        imgui.tree_pop()
    end
end)