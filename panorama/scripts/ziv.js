var isshopopen = false;
var isshopactive = false;
var isequipmentopen = false;
var shops = {};
var wood = 0;
var gold = 0;
var amount = 0;
function ActivateShop(t) //функция активации магаза
{
	if(!isshopactive)
	{
		$("#SHOPBUTTON").style['visibility'] = "visible";
		$("#SHOPLABEL").text = $.Localize(t.name);
		$("#SHOPNAME").text = $.Localize(t.name);
		isshopactive = true;
	}
	FillShop(t.name)
}
function updateresources() //функция апдейта панельки с ресурсами
{
	gold = Players.GetGold(Game.GetLocalPlayerID());
	$("#gold").text = $.Localize("#Gold") + gold;
	$("#wood").text = $.Localize("#Wood") + wood;
	$.Schedule(0.05, function(){updateresources();});
}
function FillShop(shopname) //наполняем магазин из кв файла // панельки все уже созданы, поэтому мы просто меням их
{
	for (var i = 1; i <= 7 * 3; i++)
	{
		$("#item_panel_" + i).style['visibility'] = "collapse";
		$("#item_need_1_" + i).style['visibility'] = "collapse";
		$("#item_need_2_" + i).style['visibility'] = "collapse";
		$("#item_need_3_" + i).style['visibility'] = "collapse";
		$("#item_needl_1_" + i).style['visibility'] = "collapse";
		$("#item_needl_2_" + i).style['visibility'] = "collapse";
		$("#item_needl_3_" + i).style['visibility'] = "collapse";
	}
	for (var itemid in shops[shopname])
	{
		var itemcost = CustomNetTables.GetTableValue("itemscost",shops[shopname][itemid] + "_" + itemid);
		if(itemcost == null)
		{
			itemcost = CustomNetTables.GetTableValue("itemscost",shops[shopname][itemid]);
		}
		var itemsingredients = CustomNetTables.GetTableValue("itemsingredients",shops[shopname][itemid] + "_" + itemid);
		if(itemsingredients == null)
		{
			itemsingredients = CustomNetTables.GetTableValue("itemsingredients",shops[shopname][itemid]);
		}
		var ingredientnumber = 1;
	    for (var k in itemsingredients) 
	    {
			$("#item_need_" + ingredientnumber + "_" + itemid).style['visibility'] = "visible";
			$("#item_need_" + ingredientnumber + "_" + itemid).itemname = k;
			$("#item_needl_" + ingredientnumber + "_" + itemid).style['visibility'] = "visible";
			$("#item_needl_" + ingredientnumber + "_" + itemid).text = itemsingredients[k];
			$("#item_needl_" + ingredientnumber + "_" + itemid).SetPanelEvent("onmouseover",ShowTooltip($("#item_needl_" + ingredientnumber + "_" + itemid),$.Localize("#DOTA_Tooltip_ability_" + k) + ": " + itemsingredients[k]));
			$("#item_needl_" + ingredientnumber + "_" + itemid).SetPanelEvent("onmouseout",HideTooldip($("#item_needl_" + ingredientnumber + "_" + itemid)));
			ingredientnumber += 1
	    }
		$("#item_panel_" + itemid).style['visibility'] = "visible";
		$("#item_image_" + itemid).itemname = shops[shopname][itemid];
		if(itemcost != null)
		{
			if(itemcost["gold"] != null)
			{
				$("#item_goldcost_" + itemid).text = itemcost["gold"];
				$("#item_goldcost_" + itemid).SetPanelEvent("onmouseover",ShowTooltip($("#item_goldcost_" + itemid),$.Localize("#GoldCost") + itemcost["gold"]));
				$("#item_goldcost_" + itemid).SetPanelEvent("onmouseout",HideTooldip($("#item_goldcost_" + itemid)));
			}
			else
			{
				$("#item_goldcost_" + itemid).style['visibility'] = "collapse";
			}
			if(itemcost["wood"] != null)
			{
				$("#item_woodcost_" + itemid).text = itemcost["wood"];
				$("#item_woodcost_" + itemid).SetPanelEvent("onmouseover",ShowTooltip($("#item_woodcost_" + itemid),$.Localize("#WoodCost") + itemcost["wood"]));
				$("#item_woodcost_" + itemid).SetPanelEvent("onmouseout",HideTooldip($("#item_woodcost_" + itemid)));
			}
			else
			{
				$("#item_woodcost_" + itemid).style['visibility'] = "collapse";
			}
			if(itemcost["howmany"] != null)
			{
				$("#item_howmany_" + itemid).text = itemcost["howmany"];
				$("#item_howmany_" + itemid).SetPanelEvent("onmouseover",ShowTooltip($("#item_howmany_" + itemid),$.Localize("#howmany") + itemcost["howmany"]));
				$("#item_howmany_" + itemid).SetPanelEvent("onmouseout",HideTooldip($("#item_howmany_" + itemid)));
			}
			else
			{
				$("#item_howmany_" + itemid).style['visibility'] = "collapse";
			}
			$("#item_panel_" + itemid).SetPanelEvent("onmouseactivate",BuyItem(shopname,itemid,itemcost["gold"] || 0, itemcost["wood"] || 0));
		}
		else
		{
			$("#item_goldcost_" + itemid).style['visibility'] = "collapse";
			$("#item_woodcost_" + itemid).style['visibility'] = "collapse";
			$("#item_howmany_" + itemid).style['visibility'] = "collapse";
			$("#item_panel_" + itemid).SetPanelEvent("onmouseactivate",BuyItem(shopname,itemid,0,0));
		}
	}
}
function CreateItemList() //создаем панельки магазина
{
	var linenumber = 1
	var itemnumber = 0
	for (var i = 1; i <= 7; i++)
	{
		var line = $.CreatePanel("Panel", $("#ITEMPANEL"), "line_" + i);
		line.SetHasClass("itemline",true);
	}
	for (var i = 1; i <= 7 * 3; i++)
	{
		if(itemnumber == 3)
		{
			itemnumber = 0
			linenumber += 1
		}
		itemnumber += 1
		var itempanel = $.CreatePanel("Panel", $("#line_" + linenumber), "item_panel_" + i);
		itempanel.SetHasClass("itempanel",true);
		var itemimage = $.CreatePanel("DOTAItemImage", $("#item_panel_" + i), "item_image_" + i);
		itemimage.SetHasClass("itemimage",true);
		$("#item_image_" + i).itemname = "item_iron_pickaxe"
		var goldlabel = $.CreatePanel("Label", $("#item_panel_" + i), "item_goldcost_" + i);
		goldlabel.SetHasClass("goldlabel",true);
		$("#item_goldcost_" + i).text = "100"
		goldlabel.SetPanelEvent("onmouseover",ShowTooltip(goldlabel,"Gold cost: 10"));
		goldlabel.SetPanelEvent("onmouseout",HideTooldip(goldlabel));
		var woodlabel = $.CreatePanel("Label", $("#item_panel_" + i), "item_woodcost_" + i);
		woodlabel.SetHasClass("woodlabel",true);
		$("#item_woodcost_" + i).text = "100"
		woodlabel.SetPanelEvent("onmouseover",ShowTooltip(woodlabel,"Wood cost: 10"));
		woodlabel.SetPanelEvent("onmouseout",HideTooldip(woodlabel));
		var itemineed1 = $.CreatePanel("DOTAItemImage", $("#item_panel_" + i), "item_need_1_" + i);
		itemineed1.SetHasClass("itemineed1",true);
		$("#item_need_1_" + i).itemname = "item_iron"
		var itemineed2 = $.CreatePanel("DOTAItemImage", $("#item_panel_" + i), "item_need_2_" + i);
		itemineed2.SetHasClass("itemineed2",true);
		$("#item_need_2_" + i).itemname = "item_iron"
		var itemineed3 = $.CreatePanel("DOTAItemImage", $("#item_panel_" + i), "item_need_3_" + i);
		itemineed3.SetHasClass("itemineed3",true);
		$("#item_need_3_" + i).itemname = "item_iron"
		var itemineedlabel1 = $.CreatePanel("Label", $("#item_panel_" + i), "item_needl_1_" + i);
		itemineedlabel1.SetHasClass("itemineedl1",true);
		$("#item_needl_1_" + i).text = "22"
		itemineedlabel1.SetPanelEvent("onmouseover",ShowTooltip(itemineedlabel1,"Need iron: 22"));
		itemineedlabel1.SetPanelEvent("onmouseout",HideTooldip(itemineedlabel1));
		var itemineedlabel2 = $.CreatePanel("Label", $("#item_panel_" + i), "item_needl_2_" + i);
		itemineedlabel2.SetHasClass("itemineedl2",true);
		$("#item_needl_2_" + i).text = "22"
		itemineedlabel2.SetPanelEvent("onmouseover",ShowTooltip(itemineedlabel2,"Need iron: 22"));
		itemineedlabel2.SetPanelEvent("onmouseout",HideTooldip(itemineedlabel2));
		var itemineedlabel3 = $.CreatePanel("Label", $("#item_panel_" + i), "item_needl_3_" + i);
		itemineedlabel3.SetHasClass("itemineedl3",true);
		$("#item_needl_3_" + i).text = "22"
		itemineedlabel3.SetPanelEvent("onmouseover",ShowTooltip(itemineedlabel3,"Need iron: 22"));
		itemineedlabel3.SetPanelEvent("onmouseout",HideTooldip(itemineedlabel3));
		var howmany = $.CreatePanel("Label", $("#item_panel_" + i), "item_howmany_" + i);
		howmany.SetHasClass("howmany",true);
		$("#item_howmany_" + i).text = "22"
		howmany.SetPanelEvent("onmouseover",ShowTooltip(howmany,"You will receive: 22"));
		howmany.SetPanelEvent("onmouseout",HideTooldip(howmany));
	}
}
function DeactivateShop(t) //деактивируем магазин
{
	$("#SHOPBUTTON").style['visibility'] = "collapse";
	isshopactive = false;
	if(isshopopen)
	{
		$("#SHOP").style['position'] = "21% 0px 0px";
		isshopopen = false;
	}
}
function OpenShop(keys) //открываем магазин
{
	if(!isshopopen)
	{
		$("#SHOP").style['position'] = "0% 0px 0px";
		isshopopen = true;
	}
	else
	{
		$("#SHOP").style['position'] = "21% 0px 0px";
		isshopopen = false;
	}
}
function OpenEquipment(keys) //не нужно
{
	if(!isequipmentopen)
	{
		$("#equipment").style['position'] = "-4% 0px 0px";
		isequipmentopen = true;
	}
	else
	{
		$("#equipment").style['position'] = "-22% 0px 0px";
		isequipmentopen = false;
	}
}
function EquipedSomethink(t) //не нужно
{
	if($("#" + t.slot + "_item") == null)
	{
		var item = $.CreatePanel("DOTAItemImage", $("#" + t.slot), t.slot + "_item");
		item.SetHasClass("item",true);
		$("#" + t.slot + "_item").itemname = t.item;
		item.SetPanelEvent("onmouseactivate",UnEquip(t.slot));
	}
	else
	{
		$("#" + t.slot + "_item").style['visibility'] = "visible";
		$("#" + t.slot + "_item").itemname = t.item;
		$("#" + t.slot + "_item").SetPanelEvent("onmouseactivate",UnEquip(t.slot));
	}
}
function ChangeWood(t) //принимаем дерево из луа
{
	wood = t.wood;
}
var ShowTooltip = (function(panel,text)//универсальная функция показа тултипов
{
	return function()
	{
		$.DispatchEvent("DOTAShowTextTooltip",panel,text);
	}
});
var HideTooldip = (function(panel)
{
	return function()
	{
		$.DispatchEvent("DOTAHideTextTooltip",panel);
	}
});
var BuyItem = (function(shop,itemid,goldcost,woodcost)//покупаем айтем при нажатии
{
	return function()
	{
		if (gold >= goldcost && wood >= woodcost)
		{
			GameEvents.SendCustomGameEventToServer("BuyItem",{shop : shop,itemid : itemid});
		}
	}
});
var UnEquip = (function(slot)
{
	return function()
	{
		$("#" + slot + "_item").style['visibility'] = "collapse";
		GameEvents.SendCustomGameEventToServer("UnEquip",{slot : slot});
	}
});
(function()
{
	shops["blacksmith"] = CustomNetTables.GetTableValue("items","blacksmith");					//ЗАГРУЖАЕМ В ПЕРЕМЕННУЮ МАГАЗИНОВ МАГАЗИН КУЗНЕЦА И ЛЮБЫЕ ДРУГИЕ
	updateresources()
	CreateItemList()
	GameEvents.Subscribe("ActivateShop",ActivateShop);											//ПОДПИСЫВАЕМСЯ В ПАНОРАМЕ НА СЛУШАНИЕ
	GameEvents.Subscribe("DeactivateShop",DeactivateShop);
	GameEvents.Subscribe("EquipedSomethink",EquipedSomethink);
	GameEvents.Subscribe("ChangeWood",ChangeWood);
})();