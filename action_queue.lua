-- INIT ------------------------------------
local instance = nil
local itemSuccess = nil

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
    --local guix = sdk.to_managed_object(args[1])
    if instance == nil then
        return
    end

    if itemSuccess == false then 
        instance:call('useActiveItem(System.Boolean)', nil)
    else 
        return
    end     
end

local function cancelUseItem(args)
    itemSuccess = true
end


-- HOOKS --------------------------------
-- Item used call and save
local sdk_GUI020008 = sdk.find_type_definition("app.GUI020008")
if sdk_GUI020008 then
    sdk.hook(sdk_GUI020008:get_method("useActiveItem"), saveItem, nil)   
end

-- Item used successfully
local sdk_HunterExtendBase = sdk.find_type_definition("app.HunterCharacter.cHunterExtendBase")
if sdk_HunterExtendBase then
    sdk.hook(sdk_HunterExtendBase:get_method("successItem(app.ItemDef.ID, System.Int32, System.Boolean, ace.ShellBase, System.Single, System.Boolean, app.ItemDef.ID, System.Boolean)"), cancelUseItem, nil)
end

-- Retry item Use
local sdk_PlayerManager = sdk.find_type_definition("app.PlayerManager")
if sdk_PlayerManager then
    sdk.hook(sdk_PlayerManager:get_method("update"), tryUseItem, nil)
end

-- Cancels
if itemSuccess == nil then
    -- Dodge cancel
    local sdk_cHunterBadCondidions = sdk.find_type_definition("app.HunterBadConditions.cHunterBadConditions")
    if sdk_cHunterBadCondidions then
        sdk.hook(sdk_cHunterBadCondidions:get_method("onDodgeAction(app.HunterCharacter, System.Boolean)"), cancelUseItem, nil)
    end

    -- Attack cancel
    local sdk_Weapon = sdk.find_type_definition("app.Weapon")
    if sdk_Weapon then
        sdk.hook(sdk_Weapon:get_method("evAttackCollisionActive"), cancelUseItem, nil)
    end

    -- Seikret cancel
    local sdk_PlayerUtil = sdk.find_type_definition("app.PlayerUtil")
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




-- reFramework settings ----------------------------
re.on_draw_ui(function()
    if imgui.tree_node("Action queue") then
        if imgui.checkbox("Action queue", settings.Enable) then
            settings.Enable = not settings.Enable
            save_settings()
        end
        imgui.tree_pop()
    end
end)