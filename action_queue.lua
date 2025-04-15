-- INITIALIZERS ----------------------------

local isInitialized  = false

local function init()
    local def_radial_gui = sdk.find_type_definition("app.GUI020008")
    local def_PlayerManager = sdk.find_type_definition("app.PlayerManager")
    local def_HunterExtendBase = sdk.find_type_definition("app.HunterExtendBase")
    local def_HunterActionArg = sdk.find_type_definition("app.HunterActionArg")
    local def_HunterContext = sdk.find_type_definition("app.HunterContext")
    local def_PlayerContextHolder = sdk.find_type_definition("app.PlayerContextHolder")
    local def_cPlayerManageInfo = sdk.find_type_definition("app.cPlayerManageInfo")
    local def_HunterCharacter = sdk.find_type_definition("app.HunterCharacter")
    local def_ItemQueue = sdk.find_type_definition("app.ItemQueue")

    
    
    
    local itemId = nil
    isInitialized = true
end

local cat_core = require("_CatLib")
local cat_text = require("_CatLib.game.text")
local LanguageUtils = require("_CatLib.language")
local lang = LanguageUtils.GetLanguage()



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

-- UTILITY FUNCTIONS -----------------------
local HunterCharacter = nil

function getPlayerCharacter()
    -- Get player character.
    --sdk.get_managed_singleton("app.PlayerManager"):getMasterPlayer():get_Character()

    if HunterCharacter and HunterCharacter:get_address() ~= 0 then
        return HunterCharacter
    end
    local playerManager = sdk.get_managed_singleton("app.PlayerManager")
    if not playerManager then
        return nil
    end

    local cPlayerManageInfo = playerManager:getMasterPlayer() --app.cPlayerManageInfo.getMasterPlayer()
    if not cPlayerManageInfo then
        return nil
    end

    HunterCharacter = cPlayerManageInfo:get_Character() --app.HunterCharacter.get_Character()
    return HunterCharacter
end



-- PRE-FUNCTION ----------------------------

local function useItem177x(args)
    local useId = 177
    local util = sdk.find_type_definition('app.cCustomShortcutElement')
    local gui_baseApp = sdk.find_type_definition('app.GUIBaseApp') --obj 
    

    local self = sdk.to_managed_object(args[2])
    
    self:set_field('<ItemId>k__BackingField', 177)
    
    util:call('execute(app.GUIBaseApp)', gui_baseApp)

    --local gui_baseApp_type = sdk.find_type_definition('app.GUIBaseApp') --type
    --local fGui = sdk.call_native_func(gui_baseApp, gui_baseApp_type, 'get_GUI(app.GUIBaseApp)', 55) --55 = GUI020008
    
    --util.set_ItemId(app.ItemDef.ID), useId)
    --util.execute(app.GUIBaseApp), gui_baseApp)

end
--[[
local function useItem177()
    init()
	debug('useItem177')
	local ItemUtil = sdk.find_type_definition("app.ItemUtil")
	debug(ItemUtil)
	
    local fUseItem = ItemUtil:get_method('useItem(app.ItemDef.ID, System.Int16, System.Boolean)')
    debug(fUseItem)
    if not fUseItem then return end
    --ItemUtil:call('ItemUtil:get_method("app.ItemUtil.useItem(app.ItemDef.ID, System.Int16, System.Boolean)', itemId, nil, nil)
    fUseItem(177, nil, nil) 
end
]]

local function pre_use(args)
	init()
    debug('pre_use')

    local cHunterExtendBase = getPlayerCharacter():get_HunterExtend()
	    

    local cHunterExtendBase = HunterCharacter:get_HunterExtend() --app.HunterCharacter.cHunterExtendBase.get_HunterExtend()
        if not cHunterExtendBase then
        return nil
    end

    cHunterExtendBase:call('useItem(app.ItemDef.ID, System.Boolean, app.ItemDef.ID)', itemId, true, nil)

    debug(itemId)
    app.ItemUtil.useItem(app.ItemDef.ID, System.Int16, System.Boolean)

    --local x = sdk.get_native_singleton("app.HunterCharacter.cHunterExtendBase")
    --local y = sdk.find_type_definition("app.HunterCharacter.cHunterExtendBase")
    --local z = sdk.call_native_func(x, y, "canUseItem(app.ItemDef.ID")

    local x = sdk.get_native_singleton("app.ItemUtil")
    local y = sdk.find_type_definition("app.ItemUtil")
    local z = sdk.call_native_func(x, y, "useItem(app.ItemDef.ID, System.Int16, System.Boolean)")

    if z ~= nil then
        -- We can use call like this because scene is a managed object, not a native one.
        z:call("useItem(app.ItemDef.ID, System.Boolean, app.ItemDef.ID)", 177, nil, nil)
    end
    
     local xx = sdk.get_native_singleton("app.GUIManager")
     debug(xx.call('get_'))


     local ItemUtil = sdk.get_managed_singleton("app.ItemUtil")
    debug(ItemUtil)
    if not ItemUtil then
        return nil
    end


    ItemUtil:call('useItem(app.ItemDef.ID, System.Int16, System.Boolean)', 177, nil, nil)
    sdk.call_native_func(sdk.get_native_singleton("app.ItemUtil"), sdk.find_type_definition("app.ItemUtil"), "useItem(app.ItemDef.ID, System.Int16, System.Boolean)", 177, nil, nil)
    
end

local function setItemId(args)
    local self = sdk.to_managed_object(args[2])
    local typeD = sdk.find_type_definition("app.cCustomShortcutElement")
    sdk.set_native_field(self, typeD, '<ItemId>k__BackingField', 177)
    local itemIdSET = self:get_field('<ItemId>k__BackingField')
    
  
    debug(itemIdSET)

end

local function getItemId(args)

    --debug('getItemId')
    if not isInitialized then
        init()
    end

    

    local self = sdk.to_managed_object(args[2])
    itemId = self:get_field('<ItemId>k__BackingField')
    
  
    --debug(itemId)
    
    -- args are modifiable
    -- args[1] = thread_context
    -- args[2] = "this"/object pointer
    -- rest of args are the actual parameters
    -- actual parameters start at args[2] in a static function
    -- Some native functions will have the object start at args[1] and rest at args[2]
    -- All args are void* and not auto-converted to their respective types.
    -- You will need to do things like sdk.to_managed_object(args[2])
    -- or sdk.to_int64(args[3]) to get arguments to better interact with or read.

    -- if the argument is a ValueType, you need to do this to access its fields:
    -- local type = sdk.find_type_definition("via.Position")
    -- local x = sdk.get_native_field(arg[3], type, "x")

    -- OPTIONAL: Specify an sdk.PreHookResult
    -- e.g.
    -- return sdk.PreHookResult.SKIP_ORIGINAL -- prevents the original function from being called
    -- return sdk.PreHookResult.CALL_ORIGINAL -- calls the original function, same as not returning anything
    
    --local guiMan = sdk.get_managed_singleton("app.GUIManager") --Managed object
    --local GUI020008 = guiMan:getGUI(55)
   -- GUI020008:call("get_TextActiveItem")
  
    --local item = sdk.call_native_func(sdk.get_native_singleton("via.gui.Text"), sdk.find_type_definition("via.gui.Text"), "get_TextActiveItem", nil)
    -- sdk.get_native_field(object, type_definition, field_name)
    -- sdk.set_native_field(object, type_definition, field_name, value)
    
   
end

local function debugPrint(args)
    debug('debugPrint')
    local self = sdk.to_managed_object(args[2])
    local xc = self:get_field('_Element')
    debug(xc)
    debug(xc:get_type_definition())
end

local function debugPrint2(args)
    debug('debugPrint2')
    local aceGUIDef = sdk.find_type_definition('ace.GUIDef.BUTTON_SLOT')
    local viaControl = sdk.find_type_definition('via.gui.Control')
    local viaSelectItem = sdk.find_type_definition('via.gui.SelectItem')
    local uint32 = sdk.find_type_definition('System.UInt32')

    local ace = sdk.find_type_definition('ace.cSafeEvent`4<ace.GUIDef.BUTTON_SLOT,via.gui.Control,via.gui.SelectItem,System.UInt32>')
    local ace_instance = ace:create_instance()
    debug(sdk.is_managed_object(ace_instance))
    ace_instance:call("execute(ace.GUIDef.BUTTON_SLOT, via.gui.Control, via.gui.SelectItem, System.UInt32)", 0, viaControl, viaSelectItem, uint32)
end

local function debugPrint3(args)
    --local self = sdk.to_managed_object(args[2])
    init()
    debug('pre_use')

    local cHunterExtendBase = getPlayerCharacter():get_HunterExtend()
    
    cHunterExtendBase:call('useItem(app.ItemDef.ID, System.Boolean, app.ItemDef.ID)', 2, nil, nil)
    --[[
    local itemIdx = self:get_TextActiveItem()
    local itemIdxx = self:get_field('<TextActiveItem>k__BackingField')
    local xxItem = itemIdxx.txt_item
    debug('debugPrint3')
    debug(itemIdx)
    debug(itemIdxx)
    debug(xxItem)
    ]]
end 

local function ace_test1(args)
    debug('ace_test1')
    debug(lang)
    local self = sdk.to_managed_object(args[2])
    
    local _Element = self:get_field('_Element')
    local _Items = _Element:get_field('_Items')
    local b = cat_text.GetItemName(itemId, lang)
    debug(_Element)
    debug(b)

    local tdf = sdk.find_type_definition("ace.DYNAMIC_ARRAY`1.LINQ<ace.cSafeEvent`1.cEventItem<ace.ACTION_ID>>")
    local tdf_item = tdf:get_field('get_Item(System.Int32)')
    local tdf_item_id = tdf_item(_Element)
    debug(tdf_item_id)
   
end

local function ace_test2(args)
    debug('ace_test2')
    
end


re.on_draw_ui(function()
    if imgui.tree_node("Item Queue") then
        if imgui.checkbox("Enable Item Queue", settings.Enable) then
            settings.Enable = not settings.Enable
            save_settings()
        end
        imgui.tree_pop()
    end
end)

local isActionQueued = false
local activeItem = nil

local cCustomShortcutElementHook = sdk.find_type_definition('app.cCustomShortcutElement')

if cCustomShortcutElementHook then 
    sdk.hook(cCustomShortcutElementHook:get_method('execute(app.GUIBaseApp)'), getItemId, nil)
    sdk.hook(cCustomShortcutElementHook:get_method('execute(app.GUIBaseApp)'), nil, nil)
end

local gui_type = sdk.find_type_definition("app.GUI020008")
if gui_type then
    sdk.hook(gui_type:get_method("onHudClose"), nil, nil)
end

local ace = sdk.find_type_definition('ace.cSafeEvent`4<ace.GUIDef.BUTTON_SLOT,via.gui.Control,via.gui.SelectItem,System.UInt32>')
if ace then 
    sdk.hook(ace:get_method('execute(ace.GUIDef.BUTTON_SLOT, via.gui.Control, via.gui.SelectItem, System.UInt32)'), nil, nil)
end

local ace1 = sdk.find_type_definition('ace.cSafeEvent`1<ace.ACTION_ID>')
if ace1 then 
    sdk.hook(ace1:get_method('execute(ace.ACTION_ID)'), ace_test1, nil)
end

local ace2 = sdk.find_type_definition('ace.cSafeEvent`2<ace.ACTION_ID,System.Boolean>')
if ace2 then 
    sdk.hook(ace2:get_method('execute(ace.ACTION_ID, System.Boolean)'), nil, nil)
end

--sdk.hook(sdk.find_type_definition('app.GUI020008'):get_method("useActiveItem"), getItemId, nil)

-- TODO SDK hook on hunter ready, do previous action

--Animation check? app.GUIBaseApp.isAnimSkipInputCore()

--[[
ace.ACTION_ID
ace.cActionController.execAction() 
ace.cSafeEvent`1<ace.ACTION_ID>.execute(ace.ACTION_ID) --
ace.cSafeEvent`2<ace.ACTION_ID,System.Boolean>.execute(ace.ACTION_ID, System.Boolean)
ace.cSafeEvent`1.cEventItem<ace.ACTION_ID>
]]

--[[
   if not PlayerManager then 
	PlayerManager = sdk.get_managed_singleton("app.PlayerManager") 
	if not PlayerManager then return end
    end
	
    local cPlayerManageInfo = PlayerManager:getMasterPlayer() --app.cPlayerManageInfo.getMasterPlayer()
    if not cPlayerManageInfo then return end 

    local cPlayerContextHolder = cPlayerManageInfo:get_ContextHolder() --app.cPlayerManageInfo.get_PlayerContextHolder()
    if not cPlayerContextHolder then return end

    local cHunterContext = cPlayerContextHolder:get_Hunter() 
    if not cHunterContext then return end

    local cHunterActionArg = cHunterContext:get_NextActionArg() --app.cHunterContext.get_ActionArg()
    if not cHunterActionArg then return end



    local HunterCharacter = cPlayerManageInfo:get_Character() --app.HunterCharacter.get_Character()
    if not HunterCharacter then return end

    local cHunterExtendBase = HunterCharacter:get_HunterExtend() --app.HunterCharacter.cHunterExtendBase.get_HunterExtend()
    if not cHunterExtendBase then return end

    local ItemUsed = HunterCharacter:get_UsedItemID()
]]