require("prototypes/style")
data:extend({

  {
    type = "selection-tool",
    name = "upgrade-builder",
    icon = "graphics/builder.png",
    stack_size = 1,
    subgroup = "tool",
    order = "c[automated-construction]-d[upgrade-builder]",
    flags = {"goes-to-quickbar"},
    selection_color = {r = 0.2, g = 0.8, b = 0.2, a = 0.2},
    alt_selection_color = {r = 0.2, g = 0.2, b = 0.8, a = 0.2},
    selection_mode = {"buildable-type"},
    alt_selection_mode = {"buildable-type"},
    selection_cursor_box_type = "entity",
    alt_selection_cursor_box_type = "copy"
    
  },
  {
    type = "recipe",
    name = "upgrade-builder",
    enabled = true,
    energy_required = 0.1,
    ingredients =
    {
    },
    result = "upgrade-builder"
  }
})

data:extend{
  {
    type = "custom-input",
    name = "upgrade-planner",
    key_sequence = "U",
  },
  {
    type = "custom-input",
    name = "upgrade-planner-hide",
    key_sequence = "CONTROL + U",
  },
}




















