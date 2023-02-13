-- Need filename to end in _spec so plenary can find the file

local function findmap(lhs)
   local maps = vim.api.nvim_get_keymap('n')

   for _, map in ipairs(maps) do
      if map.lhs == lhs then
         return map
      end
   end
end

describe("tj", function()
   before_each(function()
      require "tj"._clear()
      pcall(vim.keymap.del, "n", "asdfasdf")
   end)

   it("can be required", function()
      require("tj")
   end)

   it("can push a single mapping", function()
      require("tj").push("test1", "n", {
          asdfasdf = "echo 'This is a test'",
      })

      local found = findmap("asdfasdf")
      assert.are.same("echo 'This is a test'", found.rhs)
   end)

   it("can push multiple mappings", function()
      local rhs = "echo 'This is a test'"
      require("tj").push("test2", "n", {
          ['asdf_1'] = rhs .. "1",
          ['asdf_2'] = rhs .. "2",
      })
      local found = findmap("asdf_1")
      assert.are.same(rhs .. "1", found.rhs)

      local found2 = findmap("asdf_1")
      assert.are.same(rhs .. "1", found2.rhs)
   end)

   it("can delete NEW mappings after pop", function()
      require("tj").push("test1", "n", {
          asdfasdf = "echo 'This is a test'",
      })

      require("tj").pop("test1")
      local after_pop = findmap("asdfasdf")
      assert.are.same(nil, after_pop)
   end)

   it("can RESET EXISTING mappings after pop", function()
      vim.keymap.set('n', 'ggwp', "echo 'OG MAPPING'")

      local rhs = "echo 'This is a test'"
      require("tj").push("test1", "n", {
          ['ggwp'] = rhs,
      })

      local found = findmap("ggwp")
      assert.are.same(rhs, found.rhs)

      -- P(require("tj")._stack)
      require("tj").pop("test1")
      local after_pop = findmap("ggwp")
      assert.are.same("echo 'OG MAPPING'", after_pop.rhs)
   end)
end)
