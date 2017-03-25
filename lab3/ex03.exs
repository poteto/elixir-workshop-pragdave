defmodule Ex03 do

  @moduledoc """

  `Enum.map` takes a collection, applies a function to each element in
  turn, and returns a list containing the result. It is an O(n)
  operation.

  Because there is no interaction between each calculation, we could
  process all elements of the original collection in parallel. If we
  had one processor for each element in the original collection, that
  would turn it into an O(1) operation.

  However, we don't have that many processors on our machines, so we
  have to compromise. If we have two processors, we could divide the
  map into two chunks, process each independently on its own
  processor, then combine the results.

  You might think this would halve the elapsed time, but the reality
  is that the initial chunking of the collection, and the eventual
  combining of the results both take time. As a result, the speed up
  will be less that a factor of two. If the work done in the mapping
  function is time consuming, then the speedup factor will be greater,
  as the overhead of chunking and combining will be relatively less.
  If the mapping function is trivial, then parallelizing the code will
  actually slow it down.

  Your mission is to implement a function

      pmap(collection, process_count, func)

  This will take the collection, split it into n chunks, where n is
  the process count, and then run each chunk through a regular map
  function, but with each map running in a separate process.

  Useful functions include `Enum.count/1`, `Enum.chunk/4` and
 `Enum.concat/1`.

  """

  def pmap(collection, process_count, function) do
    collection
    |> Enum.chunk(process_count)
    |> Enum.map(fn group ->
      Enum.map(group, fn i -> &(Task.async(function.(&1))) end)
    end)
    |> Enum.map(fn i -> &(Task.await(&1)) end)
  end
end


ExUnit.start
defmodule TestEx03 do
  use ExUnit.Case
  import Ex03

  test "pmap with 1 process" do
    assert pmap(1..10, 1, &(&1+1)) == 2..11 |> Enum.into([])
  end

  # test "pmap with 2 processes" do
  #   assert pmap(1..10, 2, &(&1+1)) == 2..11 |> Enum.into([])
  # end

  # test "pmap with 3 processes (doesn't evenly divide data)" do
  #   assert pmap(1..10, 3, &(&1+1)) == 2..11 |> Enum.into([])
  # end

  # test "actually reduces time" do
  #   range = 1..1_000_000
  #   # random calculation to burn some cpu
  #   calc  = fn n -> :math.sin(n) + :math.sin(n/2) + :math.sin(n/4)  end

  #   { time1, result1 } = :timer.tc(fn -> pmap(range, 1, calc) end)
  #   { time2, result2 } = :timer.tc(fn -> pmap(range, 2, calc) end)

  #   assert result2 == result1
  #   assert time2 < time1 * 0.8
  # end

end
