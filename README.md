# Upgrade Builder and Planner

[Mod Download](https://mods.factorio.com/mods/d3x0r/upgrade-planner2] ![icon](images/thumb.png)

Automatically upgrade buildings by hand or with construction robots.

Use button in upper left of screen to access configuration GUI.  Drop an item onto a square in the left column or left-click an empty space to 
show item picker dialog.  The left item is the item to convert from.  The items on the right side are the items to replace the left item.

Click the save button on the bottom to make the current configuration the active configuration.  Click the Clear All button on the bottom to start 
a new plan.

There is a button on the bottom of the left configuration dialog that is used to upgrade blueprints.  Having a blueprint in hand and clicking on the
button will update all items in the blueprint according to the configuration.

In the inventory screen selection there is a new tool available that you can click to create.  This is the upgrade planner tool, and 
is used by having it in hand and drag-selecting a region where items should be upgraded.   Shift-click will select the region to be upgrade
by bots; so you can select much larger areas to upgrade.

The second dialog opened to the right allows saving a set of updates as a configuration that can later be recalled.  Click the restore button to
load the configuration into the current set of upgrades and make it active.  Click the Remove button to remove a configuration. 

## Known Bugs
When removing a configuration set from the middle of the list, re-adding a new item causes a script crash which ends the game with a duplicate control
id message.

## Changelog

1.3.0 - able to upgrade train rails.  Fixes tooltip updates.  Fixes missing translation string.  Auto commits reloaded plans to active plan.
Blueprints now get their icon images updated also.

## Pre-fork history 

### Credit where credit is due.
Original Mod By kds71
Version 1.1.10 by malk0lm
Updated to 0.13.6 by Slayer1557
Improved to use 0.13 API features by Klonan

- 1.2.17 - Able to upgrade blueprints, also added hotkey for toggling gui visibility and button visiblity

- 1.2.16 - Hacked in choose elem button

- 1.2.15 - 0.15 compatibility, New gui

- 1.2.14 - Removed distance chacking as it was annoying, Fixed raised event error.

- ?? 1.3? where did that go? 
  1.3.9 - Adds a new item and recipe (unlocked with Upgrade builder technology) - "Upgrade Builder" - that allows you to replace entities on the map using construction robots. Entities are replaced by hand unless you hold shift when selecting an area to mark it for bots to upgrade.

- Version 1.2.12 - Fixed belt not valid crash

- Version 1.2.12 - Fixed another belt not valid crash

- Version 1.2.11 - Fixed gui not showing on player joining a game

- Version 1.2.9 - If you upgrade one half of an underground belt it will try to upgrade the other half

- Version 1.2.8 - Fixed error about removed mod items

- Version 1.2.7 - Fixed on_built_entity error

- Version 1.2.6 - Upgrade planner will now raise events preplayer_mined_item, player_mined_item and on_built_entity

- Version 1.2.5 - For factorio 0.14 - Added support for deconstructing trees like this:

- Version 1.2.3 - Uses better method where possible to replace entities.

- Version 1.2.2 - Minor fixes and further cleanup by Klonan, recipe changed to deconstruction planner, Change from text button to image button

- Version 1.2 - I asked Klonan if we could cooperate and incorporate his version of the mod. The result is a much more powerful Upgrade builder. Now you are able to upgrade entities by hand, rather than relying on robots. You can still tell robots to do it by holding the shift key when designating the area.

- Version 1.1.12 - Added German Localization courtesy of Luma88 and Russian courtesy of RikkiLook. BUXFIX: Underground belts will now maintain their orientation when upgraded.


