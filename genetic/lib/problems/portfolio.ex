defmodule Genetic.Problem.Portfolio do
  @moduledoc """
  Binary Genotype Optimization Problem
  """
  @behaviour Genetic.Problem

  alias Genetic.Types.Chromosome
  alias Genetic.{Helper, Instrumentor, Solver}

  @max_generation 100_000
  @target_fitness 180
  @len 10

  def solve(opts \\ []) do
    Helper.measure_time(fn ->
      Solver.run(__MODULE__, opts)
      |> Helper.output_solution(__MODULE__)
    end)
    |> Helper.output_measurements(__MODULE__)
  end

  # terminate?/3 in book
  @impl true
  def solution([best | rest] = population, generation, temp) do
    worst = List.last(rest)

    IO.write(
      "\rBest: #{best.fitness}, Worst: #{worst.fitness}, Gen: #{generation}, PopSize: #{length(population)}, Temp: #{Float.ceil(temp, 2)}\n"
    )

    max_value = Enum.max_by(population, &fitness_function/1)

    if max_value.fitness > @target_fitness || generation >= @max_generation,
      do: {:solved, best},
      else: {:unsolved, best, population}
  end

  @impl true
  def on_tick(_proc_info) do
    :ok
  end

  @impl true
  def genotype do
    genes = for _ <- 1..@len, do: {:rand.uniform(@len), :rand.uniform(@len)}
    %Chromosome{genes: genes, size: @len}
  end

  @impl true
  def fitness_function(chromosome) do
    chromosome.genes
    |> Enum.map(fn {roi, risk} -> 2 * roi - risk end)
    |> Enum.sum()
  end
end
