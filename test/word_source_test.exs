defmodule WordSourceTest do
  use ExUnit.Case

	@many_terms ("lorem\r\n:   ipsum" <>
								 "\r\n\r\ndolor\r\n:   sit\r\n:   amet" <>
								 "\r\n\r\nconsecetetur adipiscing elit" <>
								 "\r\n:   Cras cursus sem a nibh")

	test "make_definition/1 - term, single definition - create single" do
		single_definition = "lorem\r\n:   ipsum dolor sit"
		
		actual_definition =
			ExUtils.WordSource.make_terms(single_definition)
		
		assert(actual_definition == [["lorem", "ipsum dolor sit"]])
	end
	
	test "make_definition/1 - term, many definitions - create many" do
		many_terms = ("lorem\r\n:   ipsum dolor sit" <>
													"\r\n:   Four score and seven years ago" <>
													"\r\n:   To be or not to be")
		
		actual_definition =
			ExUtils.WordSource.make_terms(many_terms)
		
		assert(actual_definition == [["lorem",
																	("ipsum dolor sit; " <>
																		 "Four score and seven years ago; " <>
																		 "To be or not to be")]])
	end

	test "make_definition/1 - many terms - create many" do
		
		actual_terms =
			ExUtils.WordSource.make_terms(@many_terms)

		assert(actual_terms == 
						 [["lorem", "ipsum"],
							["dolor", "sit; amet"],
							["consecetetur adipiscing elit", "Cras cursus sem a nibh"]])
	end

	test "make_definition/1 - empty content - create empty" do
		actual_terms = ExUtils.WordSource.make_terms(<<>>)
		
		assert(actual_terms == [])
	end

	test "next/0 - server started - received a term." do
		ExUtils.WordSource.start(@many_terms, fn(_n) -> 2 end)

		actual_term = ExUtils.WordSource.next()

		assert(actual_term == ["dolor", "sit; amet"])
	end

	test "stop/0 - server started - process stopped." do
		ExUtils.WordSource.start("lorem\r\n:   ipsum dolor sit")

		# Query the server process BEFORE stopping it (because once it
		# dies, the runtime automatically unregisters the name.
		actual_server = ExUtils.WordSource.server()

		ExUtils.WordSource.stop()
		
		# Sleep to allowb server to stop
		receive do
		after 10 -> :ok
		end

		assert(not Process.alive?(actual_server))
	end

end
