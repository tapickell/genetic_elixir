defmodule Genetic.Strategies.Selection do
  def elite(population, selection_count) do
    Enum.take(population, selection_count)
  end

  def random(population, selection_count) do
    Enum.take_random(population, selection_count)
  end

  def tournament_fitness(population, n, tourn_size) do
    0..(n - 1)
    |> Enum.map(fn _ ->
      population
      |> Enum.take_random(tourn_size)
      |> Enum.max_by(& &1.fitness)
    end)
  end

  def tournament_diversity(population, n, tourn_size, selected \\ MapSet.new()) do
    if MapSet.size(selected) == n do
      MapSet.to_list(selected)
    else
      chosen =
        population
        |> Enum.take_random(tourn_size)
        |> Enum.max_by(& &1.fitness)

      tournament_diversity(population, n, tourn_size, MapSet.put(selected, chosen))
    end
  end

  def roulette(chromosomes, n) do
    sum_fitness =
      chromosomes
      |> Enum.map(& &1.fitness)
      |> Enum.sum()

    Enum.map(0..(n - 1), fn _ ->
      u = :rand.uniform() * sum_fitness

      Enum.reduce_while(chromosomes, 0, fn x, sum ->
        if x.fitness + sum > u do
          {:halt, x}
        else
          {:cont, x.fitness + sum}
        end
      end)
    end)
  end
end
