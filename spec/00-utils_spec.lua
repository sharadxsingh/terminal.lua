describe("Utils", function()

  local utils

  before_each(function()
    utils = require "terminal.utils"
  end)



  describe("invalid_constant()", function()

    it("handles numbers only table", function()
      local c = {
        "one", "two", "three"
      }
      local result = utils.invalid_constant(4, c)
      assert.are.equal('Invalid value: 4. Expected one of: 1, 2, 3', result)
    end)


    it("handles strings only table", function()
      local c = {
        one = 1, two = 2, three = 3
      }
      local result = utils.invalid_constant("four", c)
      assert.are.equal('Invalid value: "four". Expected one of: "one", "three", "two"', result)
    end)


    it("handles mixed table", function()
      local c = {
        1, 2, three = 3, four = 4
      }
      local result = utils.invalid_constant(5, c)
      assert.are.equal('Invalid value: 5. Expected one of: 1, 2, "four", "three"', result)
    end)


    it("uses the prefix if given", function()
      local c = {
        "one", "two", "three"
      }
      local result = utils.invalid_constant(4, c, "Invalid something: ")
      assert.are.equal('Invalid something: 4. Expected one of: 1, 2, 3', result)
    end)

  end)



  describe("throw_invalid_constant()", function()

    it("throws an error", function()
      local c = {
        "one", "two", "three"
      }
      local f = function()
        utils.throw_invalid_constant(4, c)
      end
      assert.has_error(f, 'Invalid value: 4. Expected one of: 1, 2, 3')
    end)

  end)



  describe("make_lookup()", function()

    it("creates a lookup table throwing errors", function()
      local const = utils.make_lookup("foreground color", {
        red = 1, green = 2, blue = 3
      })
      assert.are.equal(1, const.red)
      assert.are.equal(2, const.green)
      assert.are.equal(3, const.blue)
      local f = function()
        return const.yellow
      end
      assert.has_error(f, 'Invalid foreground color: "yellow". Expected one of: "blue", "green", "red"')
    end)

  end)



  describe("resolve_index()", function()

    local list = {
      { i = 3,  max = 5, min = 2,   exp = 3, desc = "proper range remains unchanged" },
      { i = 0,  max = 5, min = 2,   exp = 2, desc = "zero is clamped to min" },
      { i = -1, max = 5, min = 2,   exp = 5, desc = "negative index is clamped to max" },
      { i = -2, max = 5, min = 2,   exp = 4, desc = "negative index is resolved" },
      { i = -6, max = 5, min = 2,   exp = 2, desc = "negative index is clamped to min" },
      { i = 0,  max = 5, min = nil, exp = 1, desc = "minimum defaults to 1" },
    }

    for _, v in ipairs(list) do
      it(v.desc, function()
        assert.are.equal(v.exp, utils.resolve_index(v.i, v.max, v.min))
      end)
    end

  end)

end)
