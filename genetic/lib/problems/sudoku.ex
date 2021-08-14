defmodule Genetic.Problem.Sudoku do
  @moduledoc """
  Binary Genotype Optimization Problem
  """
  @behaviour Genetic.Problem

  alias Genetic.Types.Chromosome
  alias Genetic.{Helper, Instrumentor, Solver}

  @puzzle "256489173374615982981723456593274861712836549468591327635147298127958634849362715"
          |> String.graphemes()
          |> Enum.map(&String.to_integer/1)

  @puzzle_size length(@puzzle)
  @puzzle_target Enum.sum(@puzzle)

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
    t = Float.ceil(temp, 2)

    IO.write(
      "\rBest: #{best.fitness}, Worst: #{worst.fitness}, Gen: #{generation}, PopSize: #{length(population)}, Temp: #{t}\n"
    )

    if best.fitness == @puzzle_size || generation >= 10_000 || (generation > 200 && t == 0.01),
      do: {:solved, best},
      else: {:unsolved, best, population}
  end

  @impl true
  def on_tick(_proc_info) do
    :ok
  end

  @impl true
  def genotype do
    genes = for _ <- 1..@puzzle_size, do: Enum.random(1..9)
    %Chromosome{genes: genes, size: @puzzle_size}
  end

  @impl true
  def fitness_function(chromosome) do
    sum = Enum.sum(chromosome.genes)
    offset = Integer.floor_div(@puzzle_target, 6)

    num_correct =
      @puzzle
      |> List.myers_difference(chromosome.genes)
      |> Keyword.take([:eq])
      |> Keyword.values()
      |> Enum.map(&length/1)
      |> Enum.sum()

    if sum > @puzzle_target + offset || sum < @puzzle_target - offset || num_correct <= 35,
      do: 0,
      else: num_correct
  end
end
