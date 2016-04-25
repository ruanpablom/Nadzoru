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

AutomataTemplates = letk.List.new()

AutomataTemplates:append{
	name = 'Alternate',
	callback = function(data)
		Selector.new({
			title = 'Select events',
			success_fn = function( results, numresult )
				if results[1] and results[2] then
					local automaton = Automaton.new(data.param)
					local ew1, ew2 = results[1], results[2]
					local e_start, e_finish
					e_start, ew1.automata[automaton] = automaton:event_add(ew1.name, ew1.observable, ew1.controllable, ew1.refinement, ew1)
					e_finish, ew2.automata[automaton] = automaton:event_add(ew2.name, ew2.observable, ew2.controllable, ew2.refinement, ew2)
					local s1 = automaton:state_add(nil, true, true)
					local s2 = automaton:state_add(nil, true, false)
					automaton:transition_add(s1, s2, e_start)
					automaton:transition_add(s2, s1, e_finish)
					automaton:create_log()
					data.param.elements:append(automaton)
					Controller.create_automaton_tab(data, automaton)
				end
			end,
		})
		:add_combobox{
			list = data.param.events,
			text_fn  = function( a )
				return a.name
			end,
			text = 'Start:'
		}
		:add_combobox{
			list = data.param.events,
			text_fn  = function( a )
				return a.name
			end,
			text = 'Finish:'
		}
		:run()
	end,
}

AutomataTemplates:append{
	name = 'Alternate Finish',
	callback = function(data)
		Selector.new({
			title = 'Select events',
			success_fn = function( results, numresult )
				if results[1] and results[2] then
					local automaton = Automaton.new(data.param)
					local ew1, ew2 = results[1], results[2]
					local e_start, e_finish
					e_start, ew1.automata[automaton] = automaton:event_add(ew1.name, ew1.observable, ew1.controllable, ew1.refinement, ew1)
					e_finish, ew2.automata[automaton] = automaton:event_add(ew2.name, ew2.observable, ew2.controllable, ew2.refinement, ew2)
					local s1 = automaton:state_add(nil, true, true)
					local s2 = automaton:state_add(nil, false, false)
					automaton:transition_add(s1, s2, e_start)
					automaton:transition_add(s2, s1, e_finish)
					automaton:create_log()
					data.param.elements:append(automaton)
					Controller.create_automaton_tab(data, automaton)
				end
			end,
		})
		:add_combobox{
			list = data.param.events,
			text_fn  = function( a )
				return a.name
			end,
			text = 'Start:'
		}
		:add_combobox{
			list = data.param.events,
			text_fn  = function( a )
				return a.name
			end,
			text = 'Finish:'
		}
		:run()
	end,
}

AutomataTemplates:append{
	name = 'Mutual Exclusion',
	callback = function(data)
		Selector.new({
			title = 'Select events',
			success_fn = function( results, numresult )
				if results[1] and results[2] and #results[1]==#results[2] and #results[1]>1 then
					local automaton = Automaton.new(data.param)
					local s1 = automaton:state_add(nil, true, true)
					local s2 = automaton:state_add(nil, false, false)
					for _, ew1 in ipairs(results[1]) do
						local e_start
						e_start, ew1.automata[automaton] = automaton:event_add(ew1.name, ew1.observable, ew1.controllable, ew1.refinement, ew1)
						automaton:transition_add(s1, s2, e_start)
					end
					for _, ew2 in ipairs(results[2]) do
						local e_finish
						e_finish, ew2.automata[automaton] = automaton:event_add(ew2.name, ew2.observable, ew2.controllable, ew2.refinement, ew2)
						automaton:transition_add(s2, s1, e_finish)
					end
					automaton:create_log()
					data.param.elements:append(automaton)
					Controller.create_automaton_tab(data, automaton)
				end
			end,
		})
		:add_multipler{
			list = data.param.events,
			text_fn  = function( a )
				return a.name
			end,
			text = 'Start:'
		}
		:add_multipler{
			list = data.param.events,
			text_fn  = function( a )
				return a.name
			end,
			text = 'Finish:'
		}
		:run()
	end,
}

AutomataTemplates:append{
	name = 'Mutual Exclusion 2',
	callback = function(data)
		Selector.new({
			title = 'Select events',
			success_fn = function( results, numresult )
				if results[1] and results[2] and results[3] and results[4] then
					local automaton = Automaton.new(data.param)
					local ew1, ew2, ew3, ew4 = results[1], results[2], results[3], results[4]
					local e_start1, e_finish1, e_start2, e_finish2
					e_start1, ew1.automata[automaton] = automaton:event_add(ew1.name, ew1.observable, ew1.controllable, ew1.refinement, ew1)
					e_finish1, ew2.automata[automaton] = automaton:event_add(ew2.name, ew2.observable, ew2.controllable, ew2.refinement, ew2)
					e_start2, ew3.automata[automaton] = automaton:event_add(ew3.name, ew3.observable, ew3.controllable, ew3.refinement, ew3)
					e_finish2, ew2.automata[automaton] = automaton:event_add(ew4.name, ew4.observable, ew4.controllable, ew4.refinement, ew4)
					local s1 = automaton:state_add(nil, false, false)
					local s2 = automaton:state_add(nil, true, true)
					local s3 = automaton:state_add(nil, false, false)
					automaton:transition_add(s2, s1, e_start1)
					automaton:transition_add(s1, s1, e_start1)
					automaton:transition_add(s1, s2, e_finish1)
					automaton:transition_add(s2, s2, e_finish1)
					automaton:transition_add(s2, s3, e_start2)
					automaton:transition_add(s3, s3, e_start2)
					automaton:transition_add(s3, s2, e_finish2)
					automaton:transition_add(s2, s2, e_finish2)
					automaton:create_log()
					data.param.elements:append(automaton)
					Controller.create_automaton_tab(data, automaton)
				end
			end,
		})
		:add_combobox{
			list = data.param.events,
			text_fn  = function( a )
				return a.name
			end,
			text = 'Start1:'
		}
		:add_combobox{
			list = data.param.events,
			text_fn  = function( a )
				return a.name
			end,
			text = 'Finish1:'
		}
		:add_combobox{
			list = data.param.events,
			text_fn  = function( a )
				return a.name
			end,
			text = 'Start2:'
		}
		:add_combobox{
			list = data.param.events,
			text_fn  = function( a )
				return a.name
			end,
			text = 'Finish2:'
		}
		:run()
	end,
}

AutomataTemplates:append{
	name = 'Strong Couple',
	callback = function(data)
		Selector.new({
			title = 'Select events',
			success_fn = function( results, numresult )
				if results[1] and results[2] and results[3] then
					local automaton = Automaton.new(data.param)
					local ew1, ew2, ewo = results[1], results[2], results[3]
					local ev1, ev2
					ev1, ew1.automata[automaton] = automaton:event_add(ew1.name, ew1.observable, ew1.controllable, ew1.refinement, ew1)
					ev2, ew2.automata[automaton] = automaton:event_add(ew2.name, ew2.observable, ew2.controllable, ew2.refinement, ew2)
					local s1 = automaton:state_add(nil, false, false)
					local s2 = automaton:state_add(nil, true, true)
					local s3 = automaton:state_add(nil, false, false)
					automaton:transition_add(s2, s1, ev1)
					automaton:transition_add(s1, s2, ev2)
					automaton:transition_add(s2, s3, ev2)
					automaton:transition_add(s3, s2, ev1)
					for i,ew in ipairs(ewo) do
						local ev
						ev, ew.automata[automaton] = automaton:event_add(ew.name, ew.observable, ew.controllable, ew.refinement, ew)
						automaton:transition_add(s2, s2, ev)
					end
					automaton:create_log()
					data.param.elements:append(automaton)
					Controller.create_automaton_tab(data, automaton)
				end
			end,
		})
		:add_combobox{
			list = data.param.events,
			text_fn  = function( a )
				return a.name
			end,
			text = 'Event1:'
		}
		:add_combobox{
			list = data.param.events,
			text_fn  = function( a )
				return a.name
			end,
			text = 'Event2:'
		}
		:add_multipler{
			list = data.param.events,
			text_fn  = function( a )
				return a.name
			end,
			text = 'Other:'
		}
		:run()
	end,
}

AutomataTemplates:append{
	name = 'Minimum Occurrences',
	callback = function(data)
		local list =  letk.List.new()
		for n=1,10 do
			list:append(n)
		end
		Selector.new({
			title = 'Select event',
			success_fn = function( results, numresult )
				if results[1] then
					local automaton = Automaton.new(data.param)
					local ew = results[1]
					local occ = results[2]
					local ev
					ev, ew.automata[automaton] = automaton:event_add(ew.name, ew.observable, ew.controllable, ew.refinement, ew)
					local s = {}
					s[1] = automaton:state_add(nil, false, true)
					for i=1,occ do
						s[i+1] = automaton:state_add(nil, false, false)
						automaton:transition_add(s[i], s[i+1], ev)
					end
					automaton:state_set_marked(s[occ+1])
					automaton:transition_add(s[occ+1], s[occ+1], ev)
					automaton:create_log()
					data.param.elements:append(automaton)
					Controller.create_automaton_tab(data, automaton)
				end
			end,
		})
		:add_combobox{
			list = data.param.events,
			text_fn  = function( a )
				return a.name
			end,
			text = 'Event:'
		}
		:add_combobox{
			list = list,
			text_fn  = function( a )
				return a
			end,
			text = "Occurrences:"
		}
		:run()
	end,
}

for i,temp in AutomataTemplates:ipairs() do
	temp.caption = '_' .. temp.name
	temp.hint = temp.name
	temp.name = 'template_' .. temp.name:gsub(' ', '_'):lower()
end

return AutomataTemplates
