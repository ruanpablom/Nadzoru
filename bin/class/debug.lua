--[[
    This file is part of nadzoru.

    nadzoru is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    nadzoru is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with nadzoru.  If not, see <http://www.gnu.org/licenses/>.

    Copyright (C) 2011 Yuri Kaszubowski Lopes, Eduardo Harbs, Andre Bittencourt Leal and Roberto Silvio Ubertino Rosso Jr.
--]]

--This file can be used to store functions for debugging the code. Probably should be deleted in the launch version.

---Prints data. If it is a table, prints it recursively.
--If the 'elem' is not a table, just prints it. If it is a table, verifies if it has already been printed: if it was, just prints the address of the table; otherwise, prints the table recursively, using tabs to organize the information.
--@param elem Data to be printed.
--@param hist Historic of printed data. You shall not pass this parameter.
--@param tabs Number of tabs to be printed. You shall not pass this parameter.
function tostring2(elem)
	if type(elem)=='string' then
		return "'" .. elem .. "'"
	else
		return tostring(elem)
	end
end

function print_r(elem, hist, tabs)
	hist = hist or {}
	tabs = tabs or 0
	if type(elem)~='table' then
		print(tostring2(elem))
	else
		if not hist[elem] then
			hist[elem] = true
			print(tostring2(elem) .. ' {')
			tabs = tabs + 1
			for i,e in pairs(elem) do
				io.write(string.rep('\t', tabs) .. '[' .. tostring2(i) .. '] ')
				print_r(e, hist, tabs)
			end
			tabs = tabs - 1
			print(string.rep('\t', tabs) .. '}')
		else
			print(tostring2(elem) .. ' {...}')
		end
	end
end
