defmodule Genetic do
  @moduledoc """
  Documentation for `Genetic`.
  """

  @population_size 100
  @chunk_size 2

  def initialize(genotype) do
    for _ <- 1..@population_size, do: genotype.()
  end

  def run(fitness_function, genotype, max_fitness) do
    initialize(genotype)
    |> evolve(fitness_function, genotype, max_fitness)
  end

  def evolve(population, fitness_function, genotype, max_fitness) do
    [best | _] = population = evaluate(population, fitness_function)

    if fitness_function.(best) == max_fitness do
      best
    else
      population
      |> select()
      |> crossover()
      |> mutation()
      |> evolve(fitness_function, genotype, max_fitness)
    end
  end

  def evaluate(population, fitness_function) do
    Enum.sort_by(population, fitness_function, &>=/2)
  end

  def select(population) do
    population
    |> Enum.chunk_every(@chunk_size)
    |> Enum.map(&List.to_tuple/1)
  end

  def crossover(population) do
    Enum.reduce(population, [], fn {p1, p2}, acc ->
      cx_point = :rand.uniform(length(p1))
      {{h1, t1}, {h2, t2}} = {Enum.split(p1, cx_point), Enum.split(p2, cx_point)}
      {c1, c2} = {h1 ++ t2, h2 ++ t1}
      [c1, c2 | acc]
    end)
  end

  def mutation(population) do
    Enum.map(population, fn chromosome ->
      if :rand.uniform() < 0.05 do
        Enum.shuffle(chromosome)
      else
        chromosome
      end
    end)
  end
end
