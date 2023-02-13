local M = {}

M.example = function()
   print("hi")
end
-- functions we need:
-- vim.keymap.set()
-- vim.api.nvim_get_keymap
local function find_mapping(maps, lhs)
   for _, value in ipairs(maps) do
      if value.lhs == lhs then
         return value
      end
   end
end

M._stack = {}

M.push = function(name, mode, new_mappings)
   local maps = vim.api.nvim_get_keymap(mode);

   local existing_maps = {}
   for lhs, _ in pairs(new_mappings) do
      local existing = find_mapping(maps, lhs)
      if existing then
         table.insert(existing_maps, existing)
      end
   end

   for lhs, rhs in pairs(new_mappings) do
      vim.keymap.set(mode, lhs, rhs)
   end

   M._stack[name] = {
       mode = mode,
       existing = existing_maps,
       new = new_mappings,
   }
end

M.pop = function(name)
   local state = M._stack[name]
   M._stack[name] = nil

   for lhs, _ in pairs(state.new) do
      if state.existing[lhs] then
         -- handle mappings that existed
         local og_mapping = state.existing[lhs]
         vim.keymap.set(state.mode, lhs, og_mapping.rhs)
      else
         -- handle mappings that didn't exist
         vim.keymap.del(state.mode, lhs)
      end
   end
end

M._clear = function()
   M._stack = {}
end

M.push("maperino", "n", {
    ['<C-U>'] = 'echo lmao',
    ['<C-D>'] = 'xD',
    ['1'] = 'ummmmm',
})

return M
