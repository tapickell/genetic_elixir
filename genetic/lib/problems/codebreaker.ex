defmodule Genetic.Problem.Codebreaker do
  @moduledoc """
  Binary Genotype Optimization Problem
  """
  @behaviour Genetic.Problem

  alias Genetic.Types.Chromosome
  alias Genetic.{Helper, Solver}
  use Bitwise

  @key_length 64
  @magic_numb 32768
  @target 'ILoveGeneticAlgorithms'
  @encrypted 'LIjs`B`k`qlfDibjwlqmhv'

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

    if best.fitness == 1 || generation >= 10_000 || (generation > 1000 && t == 0.01),
      do: {:solved, best |> resolve_solution()},
      else: {:unsolved, best, population}
  end

  @impl true
  def on_tick(_proc_info) do
    :ok
  end

  @impl true
  def genotype do
    genes = for _ <- 1..@key_length, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: @key_length}
  end

  @impl true
  def fitness_function(chromosome) do
    key =
      chromosome.genes
      |> Enum.map(&Integer.to_string(&1))
      |> Enum.join("")
      |> String.to_integer(2)

    guess = cipher(@encrypted, key)
    String.jaro_distance(List.to_string(@target), List.to_string(guess))
  end

  defp cipher(word, key) do
    Enum.map(word, &rem(bxor(&1, key), @magic_numb))
  end

  defp resolve_solution(chromosome) do
    {key, ""} =
      chromosome.genes
      |> Enum.map(&Integer.to_string(&1))
      |> Enum.join("")
      |> Integer.parse(2)

    IO.write("\n The Key Is: #{key}\n")
    IO.write("\n The Secret Is: #{cipher(@encrypted, key)}\n")
    chromosome
  end
end
