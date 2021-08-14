defmodule Genetic.Problem.NQueens do
  @moduledoc """
  Binary Genotype Optimization Problem
  """
  @behaviour Genetic.Problem

  alias Genetic.Types.Chromosome
  alias Genetic.{Helper, Solver}

  @puzzle_size 8

  def solve(opts \\ []) do
    Helper.measure_time(fn ->
      Solver.run(__MODULE__, opts)
      |> Helper.output_solution(__MODULE__)
    end)
    |> Helper.output_measurements(__MODULE__)
  end

  # terminate?/3 in book
  @impl true
  def solution(population, generation, temp) do
    t = Float.ceil(temp, 2)
    best = Enum.max_by(population, &fitness_function/1)

    IO.write(
      "\rBest: #{best.fitness}, Gen: #{generation}, PopSize: #{length(population)}, Temp: #{t}\n"
    )

    if best.fitness == 8 || generation >= 10_000 || (generation > 1000 && t == 0.01),
      do: {:solved, best},
      else: {:unsolved, best, population}
  end

  @impl true
  def on_tick(_proc_info) do
    :ok
  end

  @impl true
  def genotype do
    genes = Enum.shuffle(0..(@puzzle_size - 1))
    %Chromosome{genes: genes, size: @puzzle_size}
  end

  @impl true
  def fitness_function(chromosome) do
    diag_clashes =
      for i <- 0..(@puzzle_size - 1), j <- 0..(@puzzle_size - 1) do
        to_bin(1 != j, fn ->
          dx = abs(i - j)
          dy = dy(chromosome, i, j)
          to_bin(dx == dy)
        end)
      end

    length(Enum.uniq(chromosome.genes)) - Enum.sum(diag_clashes)
  end

  defp dy(chromosome, i, j) do
    (Enum.at(chromosome.genes, i) - Enum.at(chromosome.genes, j))
    |> abs()
  end

  defp to_bin(true), do: 1
  defp to_bin(_), do: 0

  defp to_bin(true, fun) do
    fun.()
  end

  defp to_bin(_, _fun), do: 0
end
