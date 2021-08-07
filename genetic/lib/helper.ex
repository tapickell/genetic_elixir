defmodule Genetic.Helper do
  def measure(fun) do
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
end
