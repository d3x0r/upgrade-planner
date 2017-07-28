
require("mod-gui")


local player = game.players[1];
if( player ) then 
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
    if flow["upgrade-planner-config-button"] then
    	flow["upgrade-planner-config-button"].destroy();
     end;
    if flow["upgrade-planner-config-frame"] then
    	flow["upgrade-planner-config-frame"].destroy();
     end;
    if flow["upgrade-planner-storage-frame"] then
	flow["upgrade-planner-storage-frame"].destroy();
	end

end;



