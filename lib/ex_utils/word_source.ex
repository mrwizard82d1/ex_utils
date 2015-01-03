defmodule ExUtils.WordSource do

	def start(content) do
		definitions = content |> make_definitions
		spawn_link(ExUtils.WordSource, :loop, [definitions])
	end

	def loop(definitions) do
		receive do
			{:next, requester} ->
				definition = Enum.at(definitions,
														 :random.uniform(length(definitions)))
				send(requester, {:response, :next, definition, self})
			  loop(definitions)
			:stop ->
				:ok
			any ->
				IO.puts("Unexpected message: #{inspect(any)}.")
				loop(definitions)
		end
	end

	@doc """
  Make definitions from `content`.
  """
	def make_definitions(content) when byte_size(content) == 0, do: []
	def make_definitions(content) do
		content
		|> String.split(~r{\r\n\r\n})
		|> Enum.map(&(String.split(&1, ~r{\r\n:   }, parts: 2)))
		|> Enum.map(&split_definitions/1)
	end

	defp split_definitions([term | [definition_text]]) do
		[term | [String.replace(definition_text, ~r{\r\n:   }, "; ")]]
	end
				 
end
