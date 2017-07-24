require("prototypes/style")
data:extend({

  {
    type = "selection-tool",
    name = "upgrade-builder2",
    icon = "__upgrade-planner2__/graphics/builder.png",
    stack_size = 1,
    subgroup = "tool",
    order = "c[automated-construction]-d[upgrade-builder]",
    flags = {"goes-to-quickbar"},
    selection_color = {r = 0.2, g = 0.8, b = 0.2, a = 0.2},
    alt_selection_color = {r = 0.2, g = 0.2, b = 0.8, a = 0.2},
    selection_mode = {"buildable-type","items-to-place","tiles","blueprint"},
    always_include_tiles = true,
    alt_selection_mode = {"buildable-type","blueprint","items-to-place","tiles"},
    selection_cursor_box_type = "entity",
    alt_selection_cursor_box_type = "copy"
    
  },
  {
    type = "module",
    name = "no-module",
    icon = "__upgrade-planner2__/graphics/no-module.png",
    stack_size = 1,
    subgroup = "module",
    category = "speed",
    order = "a",
    flags = {},
    tier = 1,
    effect = { speed = {bonus = 0.0}, productivity={bonus=0.0}, pollution={bonus=1.0}, consumption = {bonus = 0.0}}
    
  },
  {
    type = "recipe",
    name = "upgrade-builder2",
    enabled = true,
    energy_required = 0.1,
    ingredients =
    {
    },
    result = "upgrade-builder2"
  },
})

data:extend{
  {
    type = "custom-input",
    name = "upgrade-planner2",
    key_sequence = "U",
  },
  {
    type = "custom-input",
    name = "upgrade-planner2-hide",
    key_sequence = "CONTROL + U",
  },
}




















