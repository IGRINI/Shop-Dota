if IsServer() then
if not zombieinvillage then
	zombieinvillage = class({})
end



WeaponsModifierTable = {                                    ---------ЭТО ВСЕ ТЕБЕ НЕ НУЖНО
  weapon = {
    "modifier_item_iron_pickaxe",
    "modifier_item_iron_axe",
    "modifier_item_iron_sword",
    "modifier_item_copper_sword",
  },
  head = {
    "modifier_item_iron_helmet",
    "modifier_item_glasses",
  },
  chest = {
    "modifier_item_iron_chest",
    "modifier_item_copper_chest"
  },
  lefthand = {
    "modifier_item_wooden_shield",
  },
  pants = {
  },
  boots = {
  },
  leftring = {
  },
  necklace = {
  },
}
RejectingStatGainAbilities = {
  "item_iron_pickaxe",
  "iron_axe_ability",
  "item_iron_axe",
  "item_iron_sword",
  "item_copper_chest",
  "item_iron_helmet",
  "item_iron_chest",
  "item_wooden_shield",
  "item_glasses",
  "item_copper_sword",
  "item_branch",
}



_G.nPlayers = 0
_G.resources = {}                                           ---------ЭТО РЕСУРСЫ, В МОЕМ СЛУЧАЕ ДЕРЕВО

items = LoadKeyValues("scripts/kv/items.txt")                                 ---------ЗАГРУЖАЕМ КВ ФАЙЛЫ
costs = LoadKeyValues("scripts/kv/itemscosts.txt")
ingredients = LoadKeyValues("scripts/kv/itemsingredients.txt")

function zombieinvillage:FillingNetTables()                                         ----------НАПОЛНЯЕМ ТАБЛИЦЫ ДЛЯ ИСПОЛЬЗОВАНИЯ В ПАНОРАМЕ ВЫЗЫВАТЬ ЭТУ ФУНЦИЮ НУЖНО В ОНКОННЕКТФУЛЛ
    for shop, item in pairs(items) do
        CustomNetTables:SetTableValue("items",shop,item)
    end
    for item, cost in pairs(costs) do
        CustomNetTables:SetTableValue("itemscost",item,cost)
    end
    for item, ingredient in pairs(ingredients) do
        CustomNetTables:SetTableValue("itemsingredients",item,ingredient)
    end
end

_G.currentcreeps = {
  ["shagbarks"] = 0,
  ["zombies"] = 0,
  ["villagers"] = 0,
}

function zombieinvillage:StartGame()                        -----------ЭТА ФУНКЦИЯ У МЕНЯ ВЫЗЫВАЕТСЯ ПРИ ПОДКЛЮЧЕНИИ САМОГО ПЕРВОГО ИГРОКА
  zombieinvillage:spawnbranches()
  for playerid = 0, _G.nPlayers-1 do
    _G.resources[playerid] = {}
    _G.resources[playerid]["wood"] = 0                  --------------ОБЪЯВЛЕНИЕ РЕСУРСА ДЕРЕВА
    _G.resources[playerid]["equiped"] = {}
    _G.resources[playerid]["equiped"]["head"] = ""
    _G.resources[playerid]["equiped"]["chest"] = ""
    _G.resources[playerid]["equiped"]["lefthand"] = ""
    _G.resources[playerid]["equiped"]["righthand"] = ""
    _G.resources[playerid]["equiped"]["pants"] = ""
    _G.resources[playerid]["equiped"]["boots"] = ""
    _G.resources[playerid]["equiped"]["leftring"] = ""
    _G.resources[playerid]["equiped"]["rightring"] = ""
    _G.resources[playerid]["equiped"]["necklace"] = ""
  end
  CustomGameEventManager:RegisterListener("BuyItem", Dynamic_Wrap(zombieinvillage, 'BuyItem'))          ---------ПОДКЛЮЧАЕМ ФУНКЦИЮ ПОКУПКИ АЙТЕМОВ
  CustomGameEventManager:RegisterListener("UnEquip", Dynamic_Wrap(zombieinvillage, 'UnEquip'))
	local blacksmith = CreateUnitByName("blacksmith", Vector(-4.50472,-118.702,140), false, nil, nil, DOTA_TEAM_GOODGUYS)  -----СОЗДАЕМ ПРОДАВЦА
  blacksmith:AddNewModifier(blacksmith, nil, "modifier_shopkeeper", {})
  blacksmith:SetModel("models/props_gameplay/shopkeeper_fountain/shopkeeper_fountain.vmdl")
  blacksmith:SetOriginalModel("models/props_gameplay/shopkeeper_fountain/shopkeeper_fountain.vmdl")
  blacksmith:StartGesture(ACT_DOTA_IDLE)
  blacksmith:SetAngles(0,-90,0)
  blacksmith:AddNewModifier(blacksmith,nil,"modifier_shop",{})                           ------КИДАЕМ МОДИФИКАТОР ПРОДАВЦА, МОЖЕШЬ ЗАПИЛИТЬ СВОЙ И СО СВОЕЙ РЕНЖОЙ АУРЫ
  local stones = FindUnitsInRadius(DOTA_TEAM_NEUTRALS,                              ------ДАЛЬШЕ ТЕБЕ ПОКА НИЧЕ НЕ НУЖНО, МОТАЙ ВНИЗ
                          Vector(5771.64,6101.06,129.354),
                          nil,
                          3000,
                          DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                          DOTA_UNIT_TARGET_BASIC,
                          DOTA_UNIT_TARGET_FLAG_NONE,
                          FIND_ANY_ORDER,
                          false)
  for key,unit in pairs(stones) do
    if unit:GetUnitName() == "stone_ore" then
      unit:AddNewModifier(npc,nil,"modifier_stone",{})
    end
  end
  Timers:CreateTimer(0,function()
          if not GameRules:IsDaytime() then
            local zombiestospawn = 4*nPlayers
            local maxzombies = 40 * nPlayers
            for i=1,zombiestospawn do
              local vectors = {
                Vector(RandomFloat(-8058.79,7961.61), RandomFloat(-8048.31,-6967.8), 0),
                Vector(RandomFloat(7292.08,8154.95), RandomFloat(-7898.88,7663.7), 0),
                Vector(RandomFloat(-8058.79,7961.61), RandomFloat(7162.57,7981.11), 0),
                Vector(RandomFloat(-8151.97,-7166.34), RandomFloat(-7898.88,7663.7), 0),
              }
              local vector = vectors[RandomInt(1,4)]
              local zombie = CreateUnitByName("zvd_zombie", vector, true, nil, nil, DOTA_TEAM_BADGUYS)
              zombie:MoveToPositionAggressive(Vector(886.322,-1626.08,0))
            end
          end
        return 10
    end)
  local centr = Vector(886.322,-1626.08,0)
  for i=1,6 do
    local woman = CreateUnitByName("woman", centr + RandomVector(RandomInt(0,1000)), true, nil, nil, DOTA_TEAM_GOODGUYS)
  end
  for i=1,4 do
    local baby = CreateUnitByName("baby", centr + RandomVector(RandomInt(0,1000)), true, nil, nil, DOTA_TEAM_GOODGUYS)
  end
  for i=1,100 do
    local shagbark = CreateUnitByName("shagbark", centr + RandomVector(RandomInt(0,8000)), true, nil, nil, DOTA_TEAM_NEUTRALS)
  end
    --[[contRadiantShop = Containers:CreateShop({
      layout =      {2,2,2,2,2},
      skins =       {},
      headerText =  "Radiant Shop",
      pids =        {},
      position =    "entity", --"1000px 300px 0px",
      entity =      blacksmith,
      items =       {CreateItem("item_gold", blacksmith, blacksmith)},
      prices =      {20},
      stocks =      {[1]=9},
      closeOnOrder= true,
      range =       300,
      --OnCloseClickedJS = "ExampleCloseClicked",
      OnSelect  =   function(playerID, container, selected)
        print("Selected", selected:GetUnitName())
        if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
          container:Open(playerID)
        end
      end,
      OnDeselect =  function(playerID, container, deselected)
        print("Deselected", deselected:GetUnitName())
        if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
          container:Close(playerID)
        end
      end,
      OnEntityOrder=function(playerID, container, unit, target)
        print("ORDER ACTION radiant shop", playerID)
        if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
          container:Open(playerID)
          unit:Stop()
        else
          Containers:DisplayError(playerID, "#dota_hud_error_unit_command_restricted")
        end
      end,
    })]]
end


pidInventory = {}
pidEquipment = {}
defaultInventory = {}
function zombieinvillage:AddItems(hero)
	local abil = hero:FindAbilityByName("stat_gain")
	if abil then
	    abil:SetLevel(1)
	end
    local pickaxe = CreateItem("item_iron_pickaxe", hero, hero)
    hero:AddItem(pickaxe)
    --[[local pid = hero:GetPlayerID()

    local validItemsBySlot = {
      [1] = --helm
        {item_helm_of_iron_will=  true,
        item_veil_of_discord=     true},
      [2] = --chest
        {item_chainmail=          true,
        item_blade_mail=          true},
      [3] = --boots
        {item_boots=              true,
        item_phase_boots=         true},
    }

    local c = Containers:CreateContainer({
      layout =      {1,1,1},
      skins =       {"Hourglass"},
      headerText =  "#Armor",
      pids =        {pid},
      entity =      hero,
      closeOnOrder =false,
      position =    "200px 500px 0px",
      equipment =   true,
      layoutFile =  "file://{resources}/layout/custom_game/containers/alt_container_example.xml",
      OnDragWithin = false,
      OnRightClickJS = "ExampleRightClick",
      OnMouseOverJS = "ExampleMouseOver",
      AddItemFilter = function(container, item, slot)
        if slot ~= -1 and validItemsBySlot[slot][item:GetAbilityName()] then
          return true
        end
        return false
      end,
    })
    pidInventory[pid] = c
    pidEquipment[pid] = c
    local pack = CreateItem("item_open_armor", hero, hero)
    pack.container = c
    hero:AddItem(pack)
    local pickaxe = CreateItem("item_iron_pickaxe", hero, hero)
    hero:AddItem(pickaxe)]]
end
function zombieinvillage:BuyItem(t)                                               -----ФУНКЦИЯ ПОКУПКИ
  local item = items[t.shop][t.itemid]                                            -----ПОЛУЧАЕМ НАЗВАНИЕ АЙТЕМА ИЗ КВ, НИ В КОЕМ СЛУЧАЕ НЕ ПЕРЕДАВАЙ НИЧЕГО ИЗ ПАНОРАМЫ, ИГРОК МОЖЕТ ПОДМЕНИТЬ ПЕРЕМЕННЫЕ ЧЕРЕЗ ЧИТЕНЖИН КАКОЙ НИБУДЬ
  local cost = costs[tostring(item .. "_" .. t.itemid)] or nil                    -----ПОЛУЧЕМ ТАБЛИЦУ С ЦЕНАМИ ДЛЯ ОДИНАКОВЫХ АЙТЕМОВ
  if cost == nil and costs[item] ~= nil then                                      -----ЕСЛИ АЙТЕМ ОДИН И БЕЗ ПРИСТАВКИ С АЙДИ, ТО ИЩЕМ ЗАНОВО УЖЕ ОДИН АЙТЕМ
    cost = costs[item]
  elseif cost == nil and costs[item] == nil then
    cost = {}
    cost["gold"] = 0
    cost["wood"] = 0
    cost["howmany"] = 0
  end
  local pid = t.PlayerID                                                          ----ПРОСТО АЙДИ ИЗ ПАНОРАМЫ
  local hero = PlayerResource:GetSelectedHeroEntity(t.PlayerID)                   ----ГЕРОЙ ИГРОКА
  local currentgold = PlayerResource:GetGold(pid)
  local currentwood = _G.resources[pid]["wood"]                                   ----ПОЛУЧЕНИЕ ГОЛДЫ И КАСТОМНОГО РЕСУРСА
  local needingredients = ingredients[tostring(item .. "_" .. t.itemid)] or nil   ----ТО ЖЕ САМОЕ, ЧТО С ЦЕНАМИ, НО С ИНГРЕДИЕНТАМИ
  if needingredients == nil then
    needingredients = ingredients[item] or nil
  end
  if cost["gold"] or 0 <= currentgold and cost["wood"] or 0 <= currentwood then    -----ЕСЛИ ДЕНЕГ ХВАТАЕТ, ТО
    if needingredients then                                                         ----ЕСЛИ ИНГРЕДИЕНТЫ НУЖНЫ, ТО
      local ing = {}
      for i=0,2 do
        ing[i] = ing[i] or true                                                     ----ОБЪЯВЛЯЕМ ПЕРЕМЕННЫЕ ИНГРЕДИЕННТОВ(МАКСИМУМ 3, МОЖНО И БОЛЬШЕ, НО В ПАНОРАМЕ НАДО ПОДГОНЯТЬ)
      end
      local ingid = 0
      for ingredient,value in pairs(needingredients) do                             ----ДЛЯ КАЖДОГО ИНГРЕДИЕНТА ЧЕКАЕМ, ХВАТАЕТ ЛИ ЕГО
        ing[ingid] = zombieinvillage:enoughingrediens(hero,ingredient,value)
        ingid = ingid + 1
      end
      if ing[0] == true and ing[1] == true and ing[2] == true then                  -----ЕСЛИ ВСЕХ ИНГРЕДИЕНТОВ ХВАТАЕТ, ТО ЗАБИРАЕМ ИХ У ИГРОКА
        for ingredient,value in pairs(needingredients) do
          zombieinvillage:spendingredient(hero,ingredient,value)
        end
        for i=0,cost["howmany"]-1 or 0 do                                           -----ДАЕМ ИГРОКУ НУЖНОЕ КОЛИЧЕСТВО КУПЛЕННЫХ ИМ ВЕЩЕЙ
          local purchaseditem = CreateItem(item, hero, hero)
          hero:AddItem(purchaseditem)
          if not purchaseditem:IsNull() then
            purchaseditem:SetPurchaseTime(0)
          end
        end
        hero:SpendGold(cost["gold"] or 0, DOTA_ModifyGold_Unspecified)              -----СПИСЫВАЕМ ГОЛДУ И РЕСУРС
        _G.resources[pid]["wood"] = _G.resources[pid]["wood"] - (cost["wood"] or 0)
        CustomGameEventManager:Send_ServerToPlayer(PlayerInstanceFromIndex(pid+1),"ChangeWood",{wood = _G.resources[pid]["wood"]})    ----ПРОСТО ФУНКЦИЯ ОТПРАВКИ РЕСУРСА В ПАНОРАМУ
      end
    else
      for i=0,cost["howmany"]-1 or 0 do                                         ----ЕСЛИ ИНГРЕДИЕНТЫ НЕ НУЖНЫ, ТО ВСЕ КУДА ПРОЩЕ)
        local purchaseditem = CreateItem(item, hero, hero)
        hero:AddItem(purchaseditem)
        if not purchaseditem:IsNull() then
          purchaseditem:SetPurchaseTime(0)
        end
      end
      hero:SpendGold(cost["gold"] or 0, DOTA_ModifyGold_Unspecified)
      _G.resources[pid]["wood"] = _G.resources[pid]["wood"] - (cost["wood"] or 0)
      CustomGameEventManager:Send_ServerToPlayer(PlayerInstanceFromIndex(pid+1),"ChangeWood",{wood = _G.resources[pid]["wood"]})
    end
  end
end


function zombieinvillage:HasEquippedWeapons(hero,whatweapon)        ----НЕ НУЖНО
  for key,weapon in pairs(WeaponsModifierTable[whatweapon]) do
    if hero:HasModifier(weapon) then
      return true
    end
  end
  return false
end
function zombieinvillage:IsRejectAbility(ability)
  for key,ab in pairs(RejectingStatGainAbilities) do
    if ability == ab then
      return true
    end
  end
  return false
end

function zombieinvillage:UnEquip(t)
  local hero = PlayerResource:GetSelectedHeroEntity(t.PlayerID)
  local slot = t.slot
  if _G.resources[t.PlayerID]["equiped"][slot] ~= "" then
    hero:RemoveModifierByName("modifier_" .. _G.resources[t.PlayerID]["equiped"][slot])
      local item = CreateItem(_G.resources[t.PlayerID]["equiped"][slot], hero, hero)
      _G.resources[t.PlayerID]["equiped"][slot] = ""
      hero:AddItem(item)
      item:SetPurchaseTime(0)
  end
end

function zombieinvillage:enoughingrediens(hero,ingredient,value)            ------------ФУНКЦИЯ ПРОВЕРКИ, ХВАТАЕТ ЛИ АЙТЕМОВ
  local inventory = { hero:GetItemInSlot(0), hero:GetItemInSlot(1), hero:GetItemInSlot(2), hero:GetItemInSlot(3), hero:GetItemInSlot(4), hero:GetItemInSlot(5), hero:GetItemInSlot(6), hero:GetItemInSlot(7), hero:GetItemInSlot(8),}
  for k,v in pairs(inventory) do
    if v:GetName() == ingredient then
      if v:GetCurrentCharges() >= value then
        return true
      end
    end
  end
  return false
end

function zombieinvillage:spendingredient(hero,ingredient,value)            ------------ФУНКЦИЯ ОТДАЧИ АЙТЕМОВ
  local inventory = { hero:GetItemInSlot(0), hero:GetItemInSlot(1), hero:GetItemInSlot(2), hero:GetItemInSlot(3), hero:GetItemInSlot(4), hero:GetItemInSlot(5), hero:GetItemInSlot(6), hero:GetItemInSlot(7), hero:GetItemInSlot(8),}
  for k,v in pairs(inventory) do
    if v:GetName() == ingredient then
      if v:GetCurrentCharges() >= value then
        if v:GetCurrentCharges() == value then
          v:RemoveSelf()
        else
          v:SetCurrentCharges(v:GetCurrentCharges() - value)
        end
      end
    end
  end
end

_G.branches = 0

function zombieinvillage:spawnbranches()                        -----НЕ НУЖНО
  Timers:CreateTimer(function()
      if _G.branches < 1000 then
        local vector = Vector(RandomFloat(-7537.87,6388.76), RandomFloat(-7226.52,6731.26), 0)
        local branch = CreateItem("item_branch", nil, nil)
        CreateItemOnPositionSync(vector, branch)
        _G.branches = _G.branches + 1
        return 10.0
      else
        return 10.0
      end
    end
  )
end
end