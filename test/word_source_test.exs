defmodule WordSourceTest do
  use ExUnit.Case

	test "make_definition/1 - term, single definition - create single" do
		single_definition = "lorem\r\n:   ipsum dolor sit"
		
		actual_definition =
			ExUtils.WordSource.make_definitions(single_definition)
		
		assert(actual_definition == [["lorem", "ipsum dolor sit"]])
	end
	
	test "make_definition/1 - term, many definitions - create many" do
		many_definition = ("lorem\r\n:   ipsum dolor sit" <>
													 "\r\n:   Four score and seven years ago" <>
													 "\r\n:   To be or not to be")
		
		actual_definition =
			ExUtils.WordSource.make_definitions(many_definition)
		
		assert(actual_definition == [["lorem",
																	("ipsum dolor sit; " <>
																		 "Four score and seven years ago; " <>
																		 "To be or not to be")]])
	end

	test "make_definition/1 - empty content - create empty" do
		actual_definitions = ExUtils.WordSource.make_definitions(<<>>)
		
		assert(actual_definitions == [])
	end

	test "start/1 - send :stop - process stopped." do
		server = ExUtils.WordSource.start("lorem\r\n:   ipsum dolor sit")
		send(server, :stop)
		
		# "Sleep"
		receive do
		after 50 -> :ok
		end

		assert(not Process.alive?(server))
	end
	
end
