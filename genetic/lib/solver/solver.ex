defmodule Genetic.Solver do
  @population_size 100
  @chunk_size 2

  def run(fitness_function, genotype, instrumentor, max_fitness, opts \\ []) do
    state = %{
      fitness_function: fitness_function,
      generation: 0,
      instrumentor: instrumentor,
      max_fitness: max_fitness
    }

    initialize(genotype, opts)
    |> evolve(state)
  end

  defp initialize(genotype, opts) do
    population_size = Keyword.get(opts, :population_size, @population_size)
    for _ <- 1..population_size, do: genotype.()
  end

  defp evolve(population, state) do
    %{generation: generation, instrumentor: instrumentor} = state
    instrumentor.(Process.info(self()))

    case evaluate(population, state) |> solution(state) do
      {:solved, generation, best} ->
        {generation, best}

      {:training, population} ->
        population
        |> select(state)
        |> crossover(state)
        |> mutation(state)
        |> evolve(%{state | generation: generation + 1})
    end
  end

  defp solution(population, state) do
    %{
      fitness_function: fitness_function,
      max_fitness: max_fitness,
      generation: generation
    } = state

    [best | _] = population

    if fitness_function.(best) == max_fitness,
      do: {:solved, generation, best},
      else: {:training, population}
  end

  defp evaluate(population, %{fitness_function: fitness_function}) do
    Enum.sort_by(population, fitness_function, &>=/2)
  end

  defp select(population, _state) do
    population
    |> Enum.chunk_every(@chunk_size)
    |> Enum.map(&List.to_tuple/1)
  end

  defp crossover(population, _state) do
    Enum.reduce(population, [], fn {p1, p2}, acc ->
      cx_point = :rand.uniform(length(p1))
      {{h1, t1}, {h2, t2}} = {Enum.split(p1, cx_point), Enum.split(p2, cx_point)}
      {c1, c2} = {h1 ++ t2, h2 ++ t1}
      [c1, c2 | acc]
    end)
  end

  defp mutation(population, _state) do
    Enum.map(population, fn chromosome ->
      if :rand.uniform() < 0.05 do
        Enum.shuffle(chromosome)
      else
        chromosome
      end
    end)
  end
end
