--- Terminal cursor position module.
-- Provides utilities for cursor positioning in terminals.
-- @module terminal.cursor.position

local M = {}
package.loaded["terminal.cursor.position"] = M -- Register the module early to avoid circular dependencies
M.stack = require "terminal.cursor.position.stack"

local terminal = require("terminal")
local output = require("terminal.output")
local input = require("terminal.input")
local utils = require("terminal.utils")



--- returns the sequence for requesting cursor position as a string.
-- If you need to get the current position, use `get` instead.
-- @treturn string the sequence for requesting cursor position
-- @within Sequences
function M.query_seq()
  return "\27[6n"
end



--- write the sequence for requesting cursor position, without flushing.
-- If you need to get the current position, use `get` instead.
function M.query()
  output.write(M.query_seq())
end



--- Requests the current cursor position from the terminal.
-- Will read entire keyboard buffer to empty it, then request the cursor position.
-- The output buffer will be flushed.
--
-- **This function is relatively slow!** It will block until the terminal responds.
-- A least 1 sleep step will be executed, which is 20+ milliseconds usually (depends
-- on the platform). So keeping track of the cursor is more efficient than calling
-- this many times.
-- @treturn[1] number row
-- @treturn[1] number column
-- @treturn[2] nil
-- @treturn[2] string error message in case of a keyboard read error
function M.get()
  local r, err = input.query(M.query_seq(), "^\27%[(%d+);(%d+)R$")
  if not r then
    return nil, err
  end
  return tonumber(r[1]), tonumber(r[2])
end



--- Creates ansi sequence to set the cursor position without writing it to the terminal.
-- @tparam number row the new row. Negative values are resolved from the bottom of the screen,
-- such that -1 is the last row.
-- @tparam number column the new column. Negative values are resolved from the right of the screen,
-- such that -1 is the last column.
-- @treturn string ansi sequence to write to the terminal
-- @within Sequences
function M.set_seq(row, column)
  -- Resolve negative indices, and range check
  local rows, cols = terminal.size()
  row = utils.resolve_index(row, rows, 1)
  column = utils.resolve_index(column, cols, 1)
  return "\27[" .. tostring(row) .. ";" .. tostring(column) .. "H"
end



--- Sets the cursor position and writes it to the terminal.
-- @tparam number row
-- @tparam number column
-- @return true
function M.set(row, column)
  output.write(M.set_seq(row, column))
  return true
end



--- Returns the ansi sequence to backup the current cursor position (in terminal storage, not stacked).
-- @treturn string ansi sequence to write to the terminal
-- @within Sequences
function M.backup_seq()
  return "\27[s"
end



--- Writes the ansi sequence to backup the current cursor position (in terminal storage, not stacked) to the terminal.
-- @return true
function M.backup()
  output.write(M.backup_seq())
  return true
end



--- Returns the ansi sequence to restore the cursor position (from the terminal storage, not stacked).
-- @treturn string ansi sequence to write to the terminal
-- @within Sequences
function M.restore_seq()
  return "\27[u"
end



--- Writes the ansi sequence to restore the cursor position (from the terminal storage, not stacked) to the terminal.
-- @return true
function M.restore()
  output.write(M.restore_seq())
  return true
end



--- Creates an ansi sequence to move the cursor up without writing it to the terminal.
-- @tparam[opt=1] number n number of rows to move up
-- @treturn string ansi sequence to write to the terminal
-- @within Sequences
function M.up_seq(n)
  n = n or 1
  return "\27["..tostring(n).."A"
end



--- Moves the cursor up and writes it to the terminal.
-- @tparam[opt=1] number n number of rows to move up
-- @return true
function M.up(n)
  output.write(M.up_seq(n))
  return true
end



--- Creates an ansi sequence to move the cursor down without writing it to the terminal.
-- @tparam[opt=1] number n number of rows to move down
-- @treturn string ansi sequence to write to the terminal
-- @within Sequences
function M.down_seq(n)
  n = n or 1
  return "\27["..tostring(n).."B"
end



--- Moves the cursor down and writes it to the terminal.
-- @tparam[opt=1] number n number of rows to move down
-- @return true
function M.down(n)
  output.write(M.down_seq(n))
  return true
end



--- Creates an ansi sequence to move the cursor vertically without writing it to the terminal.
-- @tparam[opt=1] number n number of rows to move (negative for up, positive for down)
-- @treturn string ansi sequence to write to the terminal
-- @within Sequences
function M.vertical_seq(n)
  n = n or 1
  if n == 0 then
    return ""
  end
  return "\27[" .. (n < 0 and (tostring(-n) .. "A") or (tostring(n) .. "B"))
end



--- Moves the cursor vertically and writes it to the terminal.
-- @tparam[opt=1] number n number of rows to move (negative for up, positive for down)
-- @return true
function M.vertical(n)
  output.write(M.vertical_seq(n))
  return true
end



--- Creates an ansi sequence to move the cursor left without writing it to the terminal.
-- @tparam[opt=1] number n number of columns to move left
-- @treturn string ansi sequence to write to the terminal
-- @within Sequences
function M.left_seq(n)
  n = n or 1
  return "\27["..tostring(n).."D"
end



--- Moves the cursor left and writes it to the terminal.
-- @tparam[opt=1] number n number of columns to move left
-- @return true
function M.left(n)
  output.write(M.left_seq(n))
  return true
end



--- Creates an ansi sequence to move the cursor right without writing it to the terminal.
-- @tparam[opt=1] number n number of columns to move right
-- @treturn string ansi sequence to write to the terminal
-- @within Sequences
function M.right_seq(n)
  n = n or 1
  return "\27["..tostring(n).."C"
end



--- Moves the cursor right and writes it to the terminal.
-- @tparam[opt=1] number n number of columns to move right
-- @return true
function M.right(n)
  output.write(M.right_seq(n))
  return true
end



--- Creates an ansi sequence to move the cursor horizontally without writing it to the terminal.
-- @tparam[opt=1] number n number of columns to move (negative for left, positive for right)
-- @treturn string ansi sequence to write to the terminal
-- @within Sequences
function M.horizontal_seq(n)
  n = n or 1
  if n == 0 then
    return ""
  end
  return "\27[" .. (n < 0 and (tostring(-n) .. "D") or (tostring(n) .. "C"))
end



--- Moves the cursor horizontally and writes it to the terminal.
-- @tparam[opt=1] number n number of columns to move (negative for left, positive for right)
-- @return true
function M.horizontal(n)
  output.write(M.horizontal_seq(n))
  return true
end



--- Creates an ansi sequence to move the cursor horizontal and vertical without writing it to the terminal.
-- @tparam[opt=0] number rows number of rows to move (negative for up, positive for down)
-- @tparam[opt=0] number columns number of columns to move (negative for left, positive for right)
-- @treturn string ansi sequence to write to the terminal
-- @within Sequences
function M.move_seq(rows, columns)
  return M.vertical_seq(rows or 0) .. M.horizontal_seq(columns or 0)
end



--- Moves the cursor horizontal and vertical and writes it to the terminal.
-- @tparam[opt=0] number rows number of rows to move (negative for up, positive for down)
-- @tparam[opt=0] number columns number of columns to move (negative for left, positive for right)
-- @return true
function M.move(rows, columns)
  output.write(M.move_seq(rows, columns))
  return true
end



--- Creates an ansi sequence to move the cursor to a column on the current row without writing it to the terminal.
-- @tparam number column the column to move to. Negative values are resolved from the right of the screen,
-- such that -1 is the last column.
-- @treturn string ansi sequence to write to the terminal
-- @within Sequences
function M.column_seq(column)
  -- Resolve negative indices, and range check
  local _, cols = terminal.size()
  column = utils.resolve_index(column, cols, 1)
  return "\27["..tostring(column).."G"
end



--- Moves the cursor to a column on the current row and writes it to the terminal.
-- @tparam number column the column to move to
-- @return true
function M.column(column)
  output.write(M.column_seq(column))
  return true
end



--- Creates an ansi sequence to move the cursor to a row on the current column without writing it to the terminal.
-- @tparam number row the row to move to. Negative values are resolved from the bottom of the screen,
-- such that -1 is the last row.
-- @treturn string ansi sequence to write to the terminal
-- @within Sequences
function M.row_seq(row)
  -- Resolve negative indices, and range check
  local rows, _ = terminal.size()
  row = utils.resolve_index(row, rows, 1)
  return "\27["..tostring(row).."d"
end



--- Moves the cursor to a row on the current column and writes it to the terminal.
-- @tparam number row the row to move to
-- @return true
function M.row(row)
  output.write(M.row_seq(row))
  return true
end



return M
