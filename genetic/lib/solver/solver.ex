defmodule Genetic.Solver do
  alias Genetic.Types.Chromosome

  @population_size 100
  @chunk_size 2
  @randomness 0.05
  @cull_generation 10
  @best_part 4

  def run(problem, opts \\ []) do
    cull_generation = Keyword.get(opts, :cull_generation, @cull_generation)
    best_part = Keyword.get(opts, :best_part, @best_part)

    initialize(&problem.genotype/0, opts)
    |> evolve(problem, {0, 0, 0.0, cull_generation, best_part})
  end

  defp initialize(genotype, opts) do
    population_size = Keyword.get(opts, :population_size, @population_size)
    for _ <- 1..population_size, do: genotype.()
  end

  defp evolve(population, problem, {g, lmf, temp, cull, best_part}) do
    case evaluate(population, &problem.fitness_function/1) |> problem.solution(g, temp) do
      {:solved, best} ->
        {:ok, best}

      {:unsolved, best_enough, population} ->
        pop_temp = 0.8 * (temp + (best_enough.fitness - lmf))

        population
        |> select({g, cull, best_part})
        |> crossover()
        |> mutation()
        |> evolve(problem, {g + 1, best_enough.fitness, pop_temp, cull, best_part})
    end
  end

  defp evaluate(population, fitness_function) do
    population
    |> Enum.map(fn chromosome ->
      fitness = fitness_function.(chromosome)
      age = chromosome.age + 1
      %Chromosome{chromosome | fitness: fitness, age: age}
    end)
    |> Enum.sort_by(fitness_function, &>=/2)
  end

  defp select(population, {generation, cull, part})
       when generation > 0 and rem(generation, cull) == 0 do
    subset_len = part
    IO.puts(" Clone Best 1/#{subset_len}")
    len = length(population)
    subset = Integer.floor_div(len, subset_len)
    top = Enum.take(population, subset)

    1..subset_len
    |> Enum.reduce([], fn _, acc -> [top | acc] |> List.flatten() end)
    |> Enum.chunk_every(@chunk_size)
    |> Enum.map(&List.to_tuple/1)
  end

  defp select(population, _generation_cull_part) do
    population
    |> Enum.chunk_every(@chunk_size)
    |> Enum.map(&List.to_tuple/1)
  end

  defp crossover(population) do
    Enum.reduce(population, [], fn {p1, p2}, acc ->
      cx_point = :rand.uniform(length(p1.genes))
      {{h1, t1}, {h2, t2}} = {Enum.split(p1.genes, cx_point), Enum.split(p2.genes, cx_point)}
      {c1, c2} = {%Chromosome{p1 | genes: h1 ++ t2}, %Chromosome{p2 | genes: h2 ++ t1}}
      [c1, c2 | acc]
    end)
  end

  defp mutation(population) do
    Enum.map(population, fn chromosome ->
      if :rand.uniform() < @randomness do
        %Chromosome{chromosome | genes: Enum.shuffle(chromosome.genes)}
      else
        chromosome
      end
    end)
  end
end
