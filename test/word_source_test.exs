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

	test "start/1 - send :next - received a term." do
		server = ExUtils.WordSource.start(@many_terms, fn(_n) -> 2 end)
		send(server, {:next, self})
		
		actual_term = receive do
			{:response, term, {:next, me}}  when me == self ->
				term
		end

		assert(actual_term == ["dolor", "sit; amet"])
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
