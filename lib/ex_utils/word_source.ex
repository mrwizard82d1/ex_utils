defmodule ExUtils.WordSource do

  @server_name ExUtils.WordSource

	@doc """
  Start the word source server with the specified `content`.

  Optionally, one can supply `generator`. The default generator uses
  the built-in Erlang random number generator. The generator is a
  function taking a single integer argument that returns a number in
  the range 1..N (N is the actual argument). 
  """
	def start(content, generator \\ &:random.uniform/1) do
		terms = content |> make_terms
		server = spawn(__MODULE__, :_start_p, [terms, generator])
		:global.register_name(@server_name, server)
	end

	def _start_p(terms, generator) do
		# Seed random number generator with unique value to ensure that
		# different servers produce different sequences.
		if generator == &:random.uniform/1 do
			:random.seed(:erlang.now())
		end

		loop(terms, generator)
	end

	def next() do
		request = {:next, self}
		send(:global.whereis_name(@server_name), request)

		receive do
			{:response, term, actual_request} when request == actual_request ->
				term
		end
	end

	def stop() do
		send(:global.whereis_name(@server_name), :stop)
	end

	def loop(terms, generator) do
		receive do
			{:next, requester} = request ->
				term = Enum.at(terms,
											 generator.(length(terms)) - 1)
				send(requester, {:response, term, request})
			  loop(terms, generator)
			:stop ->
				:ok
			any ->
				IO.puts("Unexpected message: #{inspect(any)}.")
				loop(terms, generator)
		end
	end

	@doc """
  Returns the PID of the server.

  I intend this code to be called for testing only.
  """
	def server() do
		:global.whereis_name(@server_name)
	end

	@doc """
  Make terms from `content`.
  """
	def make_terms(content) when byte_size(content) == 0, do: []
	def make_terms(content) do
		content
		|> String.split(~r{\r\n\r\n})
		|> Enum.map(&(String.split(&1, ~r{\r\n:   }, parts: 2)))
		|> Enum.map(&split_terms/1)
	end

	defp split_terms([term | [definition_text]]) do
		[term | [String.replace(definition_text, ~r{\r\n:   }, "; ")]]
	end
				 
end
