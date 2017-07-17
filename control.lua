require("mod-gui")
MAX_CONFIG_SIZE = 16
MAX_STORAGE_SIZE = 12
in_range_check_is_annoying = true
available_storage_entries = {}


function glob_init()
    global["entity-recipes"] = global["entity-recipes"] or {}
    global["config"] = global["config"] or {}
    global["config-tmp"] = global["config-tmp"] or {}
    global["storage"] = global["storage"] or {}
    global["storage_id"] = global["storage_id"] or {}

end

function get_type(entity)

    if game.entity_prototypes[entity] then
        return game.entity_prototypes[entity].type
    end
    if game.item_prototypes[entity] then
        return game.item_prototypes[entity].type
    end
    return ""

end

function count_keys(hashmap)

    local result = 0

    for _, __ in pairs(hashmap) do
        result = result + 1
    end

    return result

end

function get_config_item(player, index, type)

    if not global["config-tmp"][player.name]
            or index > #global["config-tmp"][player.name]
            or global["config-tmp"][player.name][index][type] == "" then

        return nil

    end
    if not game.item_prototypes[global["config-tmp"][player.name][index][type]] then
      gui_remove(player, index)
      return nil
    end
    if not game.item_prototypes[global["config-tmp"][player.name][index][type]].valid then
      gui_remove(player, index)
      return nil
    end
      
    return game.item_prototypes[global["config-tmp"][player.name][index][type]].name

end

function gui_init(player)
    if player.gui.top["replacer-config-button"] then
        player.gui.top["replacer-config-button"].destroy() 
    end
    if player.gui.top["upgrade-planner-config-button"] then
      player.gui.top["upgrade-planner-config-button"].destroy()
    end
    if player.gui.left["upgrade-planner-config-frame"] then
      player.gui.left["upgrade-planner-config-frame"].destroy()
    end
    
    if player.gui.left["upgrade-planner-storage-frame"] then
      player.gui.left["upgrade-planner-storage-frame"].destroy()
    end
    
    local flow = mod_gui.get_button_flow(player)
    if not flow["upgrade-planner-config-button"] then
      local button = flow.add
      {
        type = "sprite-button",
        name = "upgrade-planner-config-button",
        style = mod_gui.button_style,
        sprite = "item/upgrade-builder",
        tooltip = {"upgrade-planner-button-tooltip"}
      }
      button.style.visible = true
    end
end

function gui_open_frame(player)
    local flow = mod_gui.get_frame_flow(player)
    local frame = flow["upgrade-planner-config-frame"]
    local storage_frame = flow["upgrade-planner-storage-frame"]

    if frame then
        frame.destroy()
        if storage_frame then
            storage_frame.destroy()
        end
        global["config-tmp"][player.name] = nil
        return
    end

    -- If player config does not exist, we need to create it.

    global["config"][player.name] = global["config"][player.name] or {}

    -- Temporary config lives as long as the frame is open, so it has to be created
    -- every time the frame is opened.

    global["config-tmp"][player.name] = {}

    -- We need to copy all items from normal config to temporary config.

    local i = 0

    for i = 1, MAX_CONFIG_SIZE do

        if i > #global["config"][player.name] then
            global["config-tmp"][player.name][i] = { from = "", to = "" }
        else
            global["config-tmp"][player.name][i] = {
                from = global["config"][player.name][i].from, 
                to = global["config"][player.name][i].to
            }
        end
        
    end

    -- Now we can build the GUI.
    gui = mod_gui.get_frame_flow(player)
    frame = gui.add{
        type = "frame",
        caption = {"upgrade-planner-config-frame-title"},
        name = "upgrade-planner-config-frame",
        direction = "vertical"
    }

    local error_label = frame.add{ 
        type = "label",
        name = "upgrade-planner-error-label"
    }

    error_label.style.minimal_width = 200

    local ruleset_grid = frame.add{
        type = "table",
        colspan = 6,
        name = "upgrade-planner-ruleset-grid",
        style = "slot_table_style"
    }

    ruleset_grid.add{
        type = "label",
        name = "upgrade-planner-grid-header-1",
        caption = {"upgrade-planner-config-header-1"}
    }
    ruleset_grid.add{
        type = "label",
        name = "upgrade-planner-grid-header-2",
        caption = {"upgrade-planner-config-header-2"}
    }
    ruleset_grid.add{
        type = "label",
        name = "upgrade-planner-grid-header-3",
        caption = {"upgrade-planner-config-clear", "    "}
    }
    ruleset_grid.add{
        type = "label",
        name = "upgrade-planner-grid-header-4",
        caption = {"upgrade-planner-config-header-1"}
    }
    ruleset_grid.add{
        type = "label",
        name = "upgrade-planner-grid-header-5",
        caption = {"upgrade-planner-config-header-2"}
    }
    ruleset_grid.add{
        type = "label",
        name = "upgrade-planner-grid-header-6",
        caption = {"upgrade-planner-config-clear", ""}
    }
    local items = game.item_prototypes
    for i = 1, MAX_CONFIG_SIZE do
        local sprite = nil
        local tooltip = nil
        local from = get_config_item(player, i, "from")
        if from then 
          --sprite = "item/"..get_config_item(player, i, "from") 
          tooltip = items[from].localised_name
        end
        local elem = ruleset_grid.add{ 
            type = "choose-elem-button",
            name = "upgrade-planner-from-" .. i,
            style = "slot_button_style",
            --sprite = sprite,
            elem_type = "item",
            tooltip = tooltip
        }
        elem.elem_value = from
        local sprite = nil
        local tooltip = nil
        local to = get_config_item(player, i, "to")
        if to then 
          --sprite = "item/"..get_config_item(player, i, "to") 
          tooltip = items[to].localised_name
        end
        local elem = ruleset_grid.add{
            type = "choose-elem-button",
            name = "upgrade-planner-to-" .. i,
            --style = "slot_button_style",
            --sprite = sprite,
            elem_type = "item",
            tooltip = tooltip
        }
        elem.elem_value = to
        ruleset_grid.add{
            type = "sprite-button",
            name = "upgrade-planner-clear-" .. i,
            style = "red_slot_button_style",
            sprite = "utility/remove",
            tooltip = {"upgrade-planner-config-clear", ""}
        }
    end

    local button_grid = frame.add{
        type = "table",
        colspan = 2,
        name = "upgrade-planner-button-grid"
    }

    button_grid.add{
        type = "button",
        name = "upgrade-planner-apply",
        caption = {"upgrade-planner-config-button-apply"},
        style = mod_gui.button_style
    }
    button_grid.add{
        type = "button",
        name = "upgrade-planner-clear-all",
        caption = {"upgrade-planner-config-button-clear-all"},
        style = mod_gui.button_style
    }
    
    button_grid.add{
        type = "sprite-button",
        name = "upgrade_blueprint",
        sprite = "item/blueprint",
        tooltip = {"upgrade-planner-config-button-upgrade-blueprint"},
        style = mod_gui.button_style
    }

    storage_frame = gui.add{
        type = "frame",
        name = "upgrade-planner-storage-frame",
        caption = {"upgrade-planner-storage-frame-title"},
        direction = "vertical"
    }

    local storage_frame_error_label = storage_frame.add{
        type = "label",
        name = "upgrade-planner-storage-error-label"
    }

    storage_frame_error_label.style.minimal_width = 200

    local storage_frame_buttons = storage_frame.add{
        type = "table",
        colspan = 3,
        name = "upgrade-planner-storage-buttons"
    }

    storage_frame_buttons.add{
        type = "label",
        caption = {"upgrade-planner-storage-name-label"},
        name = "upgrade-planner-storage-name-label"
    }

    storage_frame_buttons.add{
        type = "textfield",
        text = "",
        name = "upgrade-planner-storage-name"
    }

    storage_frame_buttons.add{
        type = "button",
        caption = {"upgrade-planner-storage-store"},
        name = "upgrade-planner-storage-store",
        style = "upgrade-planner-small-button"
    }

    local storage_grid = storage_frame.add{
        type = "table",
        colspan = 3,
        name = "upgrade-planner-storage-grid"
    }

    local index = 1;
    if global["storage"][player.name] then

        for key, _ in pairs(global["storage"][player.name]) do
            storage_grid.add{
                type = "label",
                caption = key .. "        ",
                name = "upgrade-planner-storage-entry-" .. index
            }

            storage_grid.add{
                type = "button",
                caption = {"upgrade-planner-storage-restore"},
                name = "upgrade-planner-restore-" .. index,
                style = "upgrade-planner-small-button"
            }
            storage_grid.add{
                type = "button",
                caption = {"upgrade-planner-storage-remove"},
                name = "upgrade-planner-remove-" .. index,
                style = "upgrade-planner-small-button"
            }
            index = index + 1
        end

    end

end

function gui_save_changes(player)

    -- Saving changes consists in:
    --   1. copying config-tmp to config
    --   2. removing config-tmp
    --   3. closing the frame

    if global["config-tmp"][player.name] then

        local i = 0
        global["config"][player.name] = {}

        for i = 1, #global["config-tmp"][player.name] do

            -- Rule can be saved only if both "from" and "to" fields are set.

            if global["config-tmp"][player.name][i].from == ""
                    or global["config-tmp"][player.name][i].to == "" then

                global["config"][player.name][i] = { from = "", to = "" }

            else
                global["config"][player.name][i] = {
                    from = global["config-tmp"][player.name][i].from,
                    to = global["config-tmp"][player.name][i].to,
                    is_rail = global["config-tmp"][player.name][i].is_rail,
                    from_curved_rail = global["config-tmp"][player.name][i].from_curved_rail,
                    from_straight_rail = global["config-tmp"][player.name][i].from_straight_rail,
                    to_curved_rail = global["config-tmp"][player.name][i].to_curved_rail,
                    to_straight_rail = global["config-tmp"][player.name][i].to_straight_rail,
                }
            end
            
        end


    end

end

function gui_clear_all(player)

    local i = 0
    local frame = mod_gui.get_frame_flow(player)["upgrade-planner-config-frame"]

    if not frame then return end

    local ruleset_grid = frame["upgrade-planner-ruleset-grid"]

    for i = 1, MAX_CONFIG_SIZE do

        global["config-tmp"][player.name][i] = { from = "", to = "" }
        ruleset_grid["upgrade-planner-from-" .. i].elem_value = nil
        ruleset_grid["upgrade-planner-from-" .. i].tooltip = ''
        ruleset_grid["upgrade-planner-to-" .. i].elem_value = nil
        ruleset_grid["upgrade-planner-to-" .. i].tooltip = ''
        
    end

end

function gui_display_message(frame, storage, message)

    local label_name = "upgrade-planner-"
    if storage then label_name = label_name .. "storage-" end
    label_name = label_name .. "error-label"

    local error_label = frame[label_name]
    if not error_label then return end

    if message ~= "" then
        message = {message}
    end

    error_label.caption = message

end

function gui_set_rule(player, type, index, element )
    local name = element.elem_value
    local frame = mod_gui.get_frame_flow(player)["upgrade-planner-config-frame"]
    local ruleset_grid = frame["upgrade-planner-ruleset-grid"]
    if not frame or not global["config-tmp"][player.name] then return end
    local is_rail = false;
    local curved_rail = nil;
    local straight_rail = nil;

    if not name then
      ruleset_grid["upgrade-planner-" .. type .. "-" .. index].tooltip = ""
      global["config-tmp"][player.name][index][type] = ""
      return
    end

    if game.item_prototypes[name] and game.item_prototypes[name].straight_rail and game.item_prototypes[name].curved_rail  then
      is_rail = true;
      straight_rail = game.item_prototypes[name].straight_rail.name;
      curved_rail = game.item_prototypes[name].curved_rail.name;
    end

    if name ~= "deconstruction-planner" or type ~= "to" then

        local opposite = "from"
        local i = 0

        if type == "from" then

            opposite = "to"

            for i = 1, #global["config-tmp"][player.name] do
                if index ~= i and global["config-tmp"][player.name][i].from == name then
                    gui_display_message(frame, false, "upgrade-planner-item-already-set")
                    element.elem_value = nil
                    element.tooltip = ''
                    return
                end
            end

        end

        local related = global["config-tmp"][player.name][index][opposite]

        if related ~= "" then

            if related == name then
                gui_display_message(frame, false, "upgrade-planner-item-is-same")
                element.elem_value = nil
                element.tooltip = ''
                return
            end

            if get_type(name) ~= get_type(related) and (not is_exception(get_type(name), get_type(related))) then
                gui_display_message(frame, false, "upgrade-planner-item-not-same-type")
                element.elem_value = nil
                element.tooltip = ''
                return
            end

        end

    end

    global["config-tmp"][player.name][index][type] = name
    global["config-tmp"][player.name][index]["is_rail"] = is_rail
    global["config-tmp"][player.name][index][type.."_curved_rail"] = curved_rail
    global["config-tmp"][player.name][index][type.."_straight_rail"] = straight_rail

    
    --ruleset_grid["upgrade-planner-" .. type .. "-" .. index].sprite = "item/"..game.item_prototypes[stack.name].name
    ruleset_grid["upgrade-planner-" .. type .. "-" .. index].tooltip = game.item_prototypes[name].localised_name

end

function gui_clear_rule(player, index)

    local frame = mod_gui.get_frame_flow(player)["upgrade-planner-config-frame"]
    if not frame or not global["config-tmp"][player.name] then return end

    gui_display_message(frame, false, "")

    local ruleset_grid = frame["upgrade-planner-ruleset-grid"]

    global["config-tmp"][player.name][index] = { from = "", to = "" }
    ruleset_grid["upgrade-planner-from-" .. index].elem_value = nil
    ruleset_grid["upgrade-planner-from-" .. index].tooltip = ""
    ruleset_grid["upgrade-planner-to-" .. index].elem_value = nil
    ruleset_grid["upgrade-planner-to-" .. index].tooltip = ""

end

function gui_store(player)

    global["storage"][player.name] = global["storage"][player.name] or {}

    local storage_frame = mod_gui.get_frame_flow(player)["upgrade-planner-storage-frame"]
    if not storage_frame then return end

    local textfield = storage_frame["upgrade-planner-storage-buttons"]["upgrade-planner-storage-name"]
    local name = textfield.text
    name = string.match(name, "^%s*(.-)%s*$")

    if not name or name == "" then
        gui_display_message(storage_frame, true, "upgrade-planner-storage-name-not-set")
        return
    end

    if global["storage"][player.name][name] then
        gui_display_message(storage_frame, true, "upgrade-planner-storage-name-in-use")
        return
    end

    global["storage"][player.name][name] = {}
    local i = 0

    for i = 1, #global["config-tmp"][player.name] do
        global["storage"][player.name][name][i] = {
            from = global["config-tmp"][player.name][i].from,
            to = global["config-tmp"][player.name][i].to,
            is_rail = global["config-tmp"][player.name][i].is_rail,
            from_curved_rail = global["config-tmp"][player.name][i].from_curved_rail,
            from_straight_rail = global["config-tmp"][player.name][i].from_straight_rail,
            to_curved_rail = global["config-tmp"][player.name][i].to_curved_rail,
            to_straight_rail = global["config-tmp"][player.name][i].to_straight_rail
        }
    end

    local storage_grid = storage_frame["upgrade-planner-storage-grid"]
    local index = count_keys(global["storage"][player.name]) + 1

    if index > MAX_STORAGE_SIZE + 1 then
        gui_display_message(storage_frame, true, "upgrade-planner-storage-too-long")
        return
    end

    storage_grid.add{
        type = "label",
        caption = name .. "        ",
        name = "upgrade-planner-storage-entry-" .. index
    }

    storage_grid.add{
        type = "button",
        caption = {"upgrade-planner-storage-restore"},
        name = "upgrade-planner-restore-" .. index,
        style = "upgrade-planner-small-button"
    }

    storage_grid.add{
        type = "button",
        caption = {"upgrade-planner-storage-remove"},
        name = "upgrade-planner-remove-" .. index,
        style = "upgrade-planner-small-button"
    }

    gui_display_message(storage_frame, true, "")
    textfield.text = ""

end

function gui_restore(player, index)

    local frame = mod_gui.get_frame_flow(player)["upgrade-planner-config-frame"]
    local storage_frame = mod_gui.get_frame_flow(player)["upgrade-planner-storage-frame"]
    if not frame or not storage_frame then return end

    local storage_grid = storage_frame["upgrade-planner-storage-grid"]
    local storage_entry = storage_grid["upgrade-planner-storage-entry-" .. index]
    if not storage_entry then return end

    local name = string.match(storage_entry.caption, "^%s*(.-)%s*$")
    if not global["storage"][player.name] or not global["storage"][player.name][name] then return end

    global["config-tmp"][player.name] = {}

    local i = 0
    local ruleset_grid = frame["upgrade-planner-ruleset-grid"]
    local items = game.item_prototypes
    for i = 1, MAX_CONFIG_SIZE do
        if i > #global["storage"][player.name][name] then
            global["config-tmp"][player.name][i] = { from = "", to = "" }
        else
            local storage = global["storage"][player.name][name][i];
            global["config-tmp"][player.name][i] = {
                from = storage.from,
                to = storage.to,
                is_rail = storage.is_rail,
                from_curved_rail = storage.from_curved_rail,
                from_straight_rail = storage.from_straight_rail,
                to_curved_rail = storage.to_curved_rail,
                to_straight_rail = storage.to_straight_rail
            }
        end
        --local sprite = ""
        local name = get_config_item(player, i, "from")
        local tooltip = '';
        if( name ) then tooltip = items[name].localised_name end
        --if name then sprite = "item/"..items[name].name end
        ruleset_grid["upgrade-planner-from-" .. i].elem_value = name
        ruleset_grid["upgrade-planner-from-" .. i].tooltip = tooltip
        --local sprite = ""
        local name = get_config_item(player, i, "to")
        local tooltip = '';
        if( name ) then tooltip = items[name].localised_name end
        --if name then sprite = "item/"..items[name].name end
        ruleset_grid["upgrade-planner-to-" .. i].elem_value = name
        ruleset_grid["upgrade-planner-to-" .. i].tooltip = tooltip
    end

    gui_display_message(storage_frame, true, "")

end

function gui_remove(player, index)

    if not global["storage"][player.name] then return end

    local storage_frame = mod_gui.get_frame_flow(player)["upgrade-planner-storage-frame"]
    if not storage_frame then return end

    local storage_grid = storage_frame["upgrade-planner-storage-grid"]
    local label = storage_grid["upgrade-planner-storage-entry-" .. index]
--    local btn1 = storage_grid["upgrade-planner-restore-" .. index]
--    local btn2 = storage_grid["upgrade-planner-remove-" .. index]

--    if not label or not btn1 or not btn2 then return end
    if not label then return end


    local name = string.match(label.caption, "^%s*(.-)%s*$")

    global["storage"][player.name][name] = nil

    gui_open_frame(player);
    gui_open_frame(player);
    local button_flow = mod_gui.get_button_flow(player)
    button_flow["upgrade-planner-config-button"].style.visible = true
--    label.destroy()
--    btn1.destroy()
--    btn2.destroy()
--    gui_display_message(storage_frame, true, "")

end

script.on_event(defines.events.on_gui_click, function(event) 

    local element = event.element
    local player = game.players[event.player_index]
    
    if element.name == "upgrade_blueprint" then
      upgrade_blueprint(player)
    end

    if element.name == "upgrade-planner-config-button" then
        gui_open_frame(player)
    elseif element.name == "upgrade-planner-apply" then
        gui_save_changes(player)
    elseif element.name == "upgrade-planner-clear-all" then
        gui_clear_all(player)
    elseif element.name  == "upgrade-planner-storage-store" then
        gui_store(player)
    else

        local type, index = string.match(element.name, "upgrade%-planner%-(%a+)%-(%d+)")
        if type and index then
            if type == "restore" then
                gui_restore(player, tonumber(index))
                gui_save_changes(player)
            elseif type == "remove" then
                gui_remove(player, tonumber(index))
            elseif type == "clear" then
                gui_clear_rule(player, tonumber(index))
            end
        end

    end

end)

script.on_event(defines.events.on_gui_elem_changed, function(event)

  local element = event.element
  local player = game.players[event.player_index]
  local type, index = string.match(element.name, "upgrade%-planner%-(%a+)%-(%d+)")
  if type and index then
    if type == "from" or type == "to" then
      gui_set_rule(player, type, tonumber(index), element)
    end
  end

end)

script.on_init(function()

    glob_init()

    for _, player in pairs(game.players) do
        gui_init(player, false)
    end


end)

script.on_event(defines.events.on_player_selected_area, function(event)
  on_selected_area(event)
  remove_trees(event)
end)

script.on_event(defines.events.on_player_alt_selected_area, function(event)
  on_alt_selected_area(event)
  bot_remove_trees(event)
end)

function on_selected_area(event)
  if event.item ~= "upgrade-builder" then return end--If its a upgrade builder 
  
  local player = game.players[event.player_index]
  local config = global["config"][player.name]
  if config == nil then return end
  
  local surface = player.surface
  global.temporary_ignore = {}
  for k, belt in pairs (event.entities) do --Get the items that are set to be upgraded
    if belt.valid then
      local upgrade = nil;
      local upgrade_to = nil;
      local is_curved_rail = false;
      for i = 1, #config do
        if config[i].is_rail then
          if config[i].from_curved_rail == belt.name then
              upgrade = config[i];
              upgrade_to = config[i].to_curved_rail;
              is_curved_rail = true;
              break
          elseif config[i].from_straight_rail == belt.name then
              upgrade = config[i];
              upgrade_to = config[i].to_straight_rail;
              break
          end
        else
          if config[i].from == belt.name then
              upgrade = config[i];
              upgrade_to = config[i].to;
              break
          end
        end
      end
      if upgrade_to ~= nil then
        player_upgrade(player,upgrade.from,belt,upgrade.to,upgrade_to,true,is_curved_rail)
      end
    end
  end
  global.temporary_ignore = nil
end

function player_upgrade(player,orig_inv_name,belt,inv_name,upgrade,bool,is_curved_rail)
  if not belt then return end
  if global.temporary_ignore[belt.name] then return end
  local surface = player.surface
  if player.get_item_count(inv_name) > 0 or player.cheat_mode then 
    local d = belt.direction
    local f = belt.force
    local p = belt.position
    --local n = belt.name
    local item_count = 1;
    local pdel = { x=0,y=0, origx=0,origy=0 }
    if belt.type == 'straight-rail' then
      if d == 1 then
      end
    elseif belt.type == 'curved-rail' then
      item_count = 4;
      if d == 1  then -- up to up-right ( down-left to down)  1.7,2.3
        pdel.x = 1;
        pdel.y = -3;
        pdel.origx =-1;
        pdel.origy =-1;

      elseif d == 6  then -- up-right to right ( left to down-left)  2.3,1.7
        pdel.x = -2.5;
        pdel.y = 1;
        pdel.origx =-1;
        pdel.origy =-1;
      elseif d == 3  then -- right to down-right ( up-left to left) 2.3,1.7
        pdel.x = 1;
        pdel.y = 1;
        pdel.origx =1;
        pdel.origy =-1;
      elseif d == 0  then -- down-right to down (up to up-left)  1.7,2.3
        pdel.x = -3;
        pdel.y = -3;
        pdel.origx =1;
        pdel.origy =-1;
      elseif d == 5 then   -- down to down-left (up-right to up) 1.7,2.3
        pdel.x = -3;
        pdel.y = 1;
        pdel.origx =1;
        pdel.origy =1;
      elseif d == 2 then   -- down-left to left (right to up-right)  2.3,1.7
        pdel.x = 0.5;
        pdel.y = -3;
        pdel.origx =1;
        pdel.origy =1;
      elseif d == 7 then   -- left to up-left (down-right to right) 2.3,1.6
        pdel.x = -2.5;
        pdel.y = -3;
        pdel.origx =-1;
        pdel.origy =1;
      elseif d == 4 then   -- up-left to up (down to down-right)  1.7,2.3; 
        pdel.x = 1;
        pdel.y = 1;
        pdel.origx =-1;
        pdel.origy =1;
      end

      if d == 3 or d == 0  then
        p = { x=p.x-2, y = p.y };
      elseif d == 7 or d == 4 then
        p = { x=p.x, y = p.y-2 };
      elseif d == 5 or d == 2 then
        p = { x=p.x-2, y = p.y-2 };
      end
    end
    if player.can_reach_entity(belt) or in_range_check_is_annoying then
      local new_item
      script.raise_event(defines.events.on_preplayer_mined_item,{player_index = player.index, entity = belt})
      if upgrade ~="deconstruction-planner" then --Goddamn legacy features
        if belt.type == "underground-belt" then 
          if belt.neighbours and bool then
            player_upgrade(player,orig_inv_name,belt.neighbours,inv_name,upgrade,false,is_curved_rail)
          end
          new_item = surface.create_entity
          {
            name = upgrade, 
            position = p, 
            force = belt.force, 
            fast_replace = true, 
            direction = belt.direction, 
            type = belt.belt_to_ground_type, 
            spill=false
          }
          
        elseif belt.type == "loader" then 
          new_item = surface.create_entity
          {
            name = upgrade, 
            position = p, 
            force = belt.force, 
            fast_replace = true, 
            direction = belt.direction, 
            type = belt.loader_type, 
            spill=false
          }
        else
          new_item = surface.create_entity
          {
            name = upgrade, 
            position = p, 
            force = belt.force, 
            fast_replace = true, 
            direction = belt.direction, 
            spill=false
          }
        end
        if belt.valid then
          if new_item then 
            if new_item.valid then new_item.destroy() end
          end
          local a = belt.bounding_box;
          --local a = {left_top={x=(p.x-0.5)-pdel.x,y=(p.y-0.5)-pdel.y},right_bottom={x=(p.x+0.5)-pdel.x,y=(p.y+0.5)-pdel.y}}
          --If the create entity fast replace didn't work, we use this blueprint technique
          player.cursor_stack.set_stack{name = "blueprint", count = 1}
          player.cursor_stack.create_blueprint{surface = surface, force = belt.force,area = a}
          local old_blueprint = player.cursor_stack.get_blueprint_entities()
          local record_index = nil
          for index, entity in pairs (old_blueprint) do
            if( entity.direction == nil ) then entity.direction = 0; end
            if (entity.name == belt.name and entity.direction==belt.direction) then
              record_index = index
              entity.position.x = pdel.origx;
              entity.position.y = pdel.origy;
            else
              old_blueprint[index] = nil
            end
          end
          if record_index == nil then player.print("Blueprint index error line "..debug.getinfo(1).currentline) return end
          old_blueprint[record_index].name = upgrade
          player.cursor_stack.set_stack{name = "blueprint", count = 1}
          player.cursor_stack.set_blueprint_entities(old_blueprint)
          if not player.cheat_mode then
            player.insert{name = orig_inv_name, count = item_count}
          end
          script.raise_event
          (
            defines.events.on_player_mined_item,
            {
              player_index = player.index,
              item_stack = 
              {
                name = orig_inv_name,
                count = item_count
              }
            }
          )
          --And then copy the inventory to some table
          local inventories = {}
          for index = 1,10 do
            if belt.get_inventory(index) ~= nil then
              inventories[index] = {}
              inventories[index].name = index
              inventories[index].contents = belt.get_inventory(index).get_contents()
            end
          end

          belt.destroy()

          player.cursor_stack.build_blueprint{surface = surface, force_build=true, force = f, position = p}
          local ghost = surface.find_entities_filtered{area = a, name = "entity-ghost"}

          player.remove_item{name = inv_name, count = item_count}
          if ghost[1]~= nil then
            local p_x = player.position.x
            local p_y = player.position.y

            while ghost[1]~= nil do
              ghost[1].revive()
              player.teleport({math.random(p_x -5, p_x +5),math.random(p_y -5, p_y +5)})
              ghost = surface.find_entities_filtered{area = a, name = "entity-ghost"}
            end
            player.teleport({p_x,p_y})
          end
          local assembling = surface.find_entities_filtered{area = a, name = upgrade}
          if not assembling[1] then 
            player.print("Upgrade planner error - Entity to raise was not found")
            player.cursor_stack.set_stack{name = "upgrade-builder", count = 1}
            player.insert{name = orig_inv_name, count = item_count}
            return 
          end
          script.raise_event(defines.events.on_built_entity,{player_index = player.index, created_entity = assembling[1]})
          --Give back the inventory to the new entity
          for j, items in pairs (inventories) do
            for l, contents in pairs (items.contents) do
              if assembling[1] ~= nil then
              assembling[1].get_inventory(items.name).insert{name = l, count = contents}
              end
            end
          end
          inventories = nil
          local proxy = surface.find_entities_filtered{area = a, name = "item-request-proxy"}
          if proxy[1]~= nil then
            proxy[1].destroy()
          end
          player.cursor_stack.set_stack{name = "upgrade-builder", count = 1}      
        else 
          player.remove_item{name = inv_name, count = item_count}
          player.insert{name = orig_inv_name, count = item_count}
          script.raise_event(defines.events.on_player_mined_item,{player_index = player.index, item_stack = {name = orig_inv_name, count = item_count}})
          script.raise_event(defines.events.on_built_entity,{player_index = player.index, created_entity = new_item})
        end
      else
        player.insert{name = orig_inv_name, count = item_count}
        script.raise_event(defines.events.on_player_mined_item,{player_index = player.index, item_stack = {name = orig_inv_name, count = item_count}})
        belt.destroy()
      end
    else 
      surface.create_entity{name = "flying-text", position = {belt.position.x-1.3,belt.position.y-0.5}, text = "Out of range",color = {r=1,g=0.6,b=0.6}}
    end
  else
    global.temporary_ignore[orig_inv_name] = true
    surface.create_entity{name = "flying-text", position = {belt.position.x-1.3,belt.position.y-0.5}, text = "Insufficient items", color = {r=1,g=0.6,b=0.6}}
  end
end

function remove_trees(event)
  if event.item ~= "upgrade-builder" then return end
  --If its a upgrade builder 
  local player = game.players[event.player_index]
  local config = global["config"][player.name]
  if not config then return end 
  if #config == 0 then return end
  local index = 0
  for i = 1, #config do
    if config[i].from == "raw-wood" then
        index = i
        break
    end
  end
  if index == 0 then return end 
  local area = event.area
  if area.left_top.x == area.right_bottom.x then return end
  if area.left_top.y == area.right_bottom.y then return end
  for k, fucking_tree in pairs (player.surface.find_entities_filtered({area = area, type = "tree"})) do
    if player.can_reach_entity(fucking_tree) or in_range_check_is_annoying then
      if player.can_insert({name= "raw-wood", count = fucking_tree.prototype.mineable_properties.amount_max}) then
        script.raise_event(defines.events.on_preplayer_mined_item,{player_index = player.index, entity = fucking_tree})
        player.insert({name= "raw-wood", count = fucking_tree.prototype.mineable_properties.amount_max})
        script.raise_event
        (
          defines.events.on_player_mined_item,
          {
            player_index = player.index,
            item_stack = 
            {
              name= "raw-wood",
              count = fucking_tree.prototype.mineable_properties.amount_max
            }
          }
        )
        fucking_tree.die()
      else
        player.print("Cannot insert raw wood")
        break
      end
    else
      player.surface.create_entity{name = "flying-text", position = {fucking_tree.position.x-1.3,fucking_tree.position.y-0.5}, text = "Out of range",color = {r=1,g=0.6,b=0.6}}
    end
  end
end

function on_alt_selected_area(event)
--this is a lot simpler... but less cool
  if event.item == "upgrade-builder" then
    local player = game.players[event.player_index]
    local config = global["config"][player.name]
    if config ~= nil then
      local surface = player.surface
      for k, belt in pairs (event.entities) do
        if belt.valid then
          local index = 0
          local upgrade_to = nil;
          for i = 1, #config do
            if config[i].is_rail then
              if config[i].from_straight_rail == belt.name then
                index = i
                upgrade_to = config[i].to_straight_rail;
                break
              elseif config[i].from_curved_rail == belt.name then
                index = i
                upgrade_to = config[i].to_curved_rail;
                break
              end
            elseif config[i].from == belt.name then
                index = i
                upgrade_to = config[i].to;
                break
            end
          end
          if index > 0 then
            if upgrade_to ~= nil then
              bot_upgrade(player,belt,upgrade_to,true)
            end
          end
        end
      end
    end   
  end
end

function bot_upgrade(player,belt,upgrade,bool)
  if not belt then return end
  local surface = player.surface
  local p = belt.position
  local d = belt.direction
  local f = belt.force
  local p = belt.position
  local a = {{p.x-0.5,p.y-0.5},{p.x+0.5,p.y+0.5}}
  if upgrade == "deconstruction-planner" then
    belt.order_deconstruction(f)
    return
  end
  
  if belt.type == "underground-belt" then 
    if belt.neighbours and bool then
      bot_upgrade(player,belt.neighbours, upgrade, false)
    end
  end
  
  player.cursor_stack.set_stack{name = "blueprint", count = 1}
  player.cursor_stack.create_blueprint{surface = surface, force = belt.force,area = a}
  local old_blueprint = player.cursor_stack.get_blueprint_entities()
  old_blueprint[1].name = upgrade
  player.cursor_stack.set_stack{name = "blueprint", count = 1}
  player.cursor_stack.set_blueprint_entities(old_blueprint)
  belt.order_deconstruction(f)
  player.cursor_stack.build_blueprint{surface = surface, force = f, position = p}
  player.cursor_stack.set_stack{name = "upgrade-builder", count = 1}

end

function bot_remove_trees(event)
  if event.item ~= "upgrade-builder" then return end
  --If its a upgrade builder 
  local player = game.players[event.player_index]
  local config = global["config"][player.name]
  if not config then return end 
  if #config == 0 then return end
  --And now support deconstructing trees...
  local index = 0
  for i = 1, #config do
    if config[i].from == "raw-wood" then
        index = i
        break
    end
  end
  if index == 0 then return end
  
  local area = event.area
  if area.left_top.x == area.right_bottom.x then return end
  if area.left_top.y == area.right_bottom.y then return end
  for k, fucking_tree in pairs (player.surface.find_entities_filtered({area = area, type = "tree"})) do
    fucking_tree.order_deconstruction(player.force)
  end
end

script.on_configuration_changed(function(data)

  if not data or not data.mod_changes then
    return
  end
  
  if data.mod_changes["upgrade-planner"] then    
    for k, player in pairs (game.players) do
      gui_init(player)
    end 
  end

end)

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.players[event.player_index] 
  gui_init(player)
end)

function upgrade_blueprint(player)
  local stack = player.cursor_stack
  if not stack.valid then 
    return
  end
  if not stack.valid_for_read then
    return
  end
  if stack.name ~= "blueprint" then
    return
  end
  if not stack.is_blueprint_setup() then
    return
  end
  local config = global["config"][player.name]
  if not config then return end
  local entities = stack.get_blueprint_entities()
  for k, entity in pairs (entities) do
    for j, entry in pairs (config) do
      if( entry.is_rail ) then
        if entities[k].name == entry.from_straight_rail then
          entities[k].name = entry.to_straight_rail
          break
        elseif entities[k].name == entry.from_curved_rail then
          entities[k].name = entry.to_curved_rail
          break
        end
      elseif entry.from == entity.name then
        entities[k].name = entry.to
        break
      end
    end
  end
  local blueprint_icons = player.cursor_stack.blueprint_icons
  for k=1,4 do
    if( blueprint_icons[k] ) then
      for j, entry in pairs (config) do
        if blueprint_icons[k].signal.name == entry.from then
          blueprint_icons[k].signal.name = entry.to
          break
        end
      end
    end
  end
  player.cursor_stack.blueprint_icons = blueprint_icons  
  stack.set_blueprint_entities(entities)
  player.print({"blueprint-upgrade-sucessful"})
end

function is_exception(from, to)
  local exceptions = 
  {
    {from = "container", to = "logistic-container"},
    {from = "logistic-container", to = "container"}
  }
  for k, exception in pairs (exceptions) do
    if from == exception.from and to == exception.to then
      return true
    end
  end
  return false
end

script.on_event("upgrade-planner", function(event)
  local player = game.players[event.player_index]
  gui_open_frame(player)
end)
script.on_event("upgrade-planner-hide", function(event)
  local player = game.players[event.player_index]
  local frame_flow = mod_gui.get_frame_flow(player)
  local button_flow = mod_gui.get_button_flow(player)
  if button_flow["upgrade-planner-config-button"] then
    button_flow["upgrade-planner-config-button"].style.visible = not button_flow["upgrade-planner-config-button"].style.visible
  end
end)
























