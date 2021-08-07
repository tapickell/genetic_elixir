defmodule Genetic.Helper do
  def measure_time(fun) do
    fun
    |> :timer.tc()
    |> elem(0)
    |> Kernel./(1_000_000)
  end

  def output_solution({generation, solution}, label) do
    IO.puts("#{label} Solved Gen: #{generation}")
    IO.inspect(solution)
  end

  def output_measurements(seconds, label) do
    IO.puts("#{label} Solution seconds: #{seconds}")
  end

  def output_tick_diff({first, last}) do
    {start_time, start_data} = first
    {end_time, end_data} = last
    IO.puts("Time: #{DateTime.diff(end_time, start_time)} seconds")
    IO.puts("HeapSize: #{end_data.heap_size - start_data.heap_size}")
    IO.puts("StackSize: #{end_data.stack_size - start_data.stack_size}")
    IO.puts("Reductions: #{end_data.reductions - start_data.reductions}")
    IO.puts("TotalHeapSize:  #{end_data.total_heap_size - start_data.total_heap_size}")
  end
end
