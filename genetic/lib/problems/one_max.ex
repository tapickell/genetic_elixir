defmodule Genetic.Problem.OneMax do
  alias Genetic.{Helper, Solver}

  @max_fitness 1000

  def solve do
    Helper.measure(fn ->
      Solver.run(&fitness_function/1, &genotype/0, @max_fitness)
      |> Helper.output_solution(__MODULE__)
    end)
    |> Helper.output_measurements(__MODULE__)
  end

  def genotype do
    for _ <- 1..1000, do: Enum.random(0..1)
  end

  def fitness_function(chromosome) do
    Enum.sum(chromosome)
  end
end
