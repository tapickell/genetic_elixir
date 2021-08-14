defmodule Genetic.Solver do
  alias Genetic.Types.Chromosome
  alias Genetic.Strategies.Selection

  @population_size 100
  @chunk_size 2
  @randomness 0.05
  @selection_rate 0.8

  def run(problem, opts \\ []) do
    initialize(&problem.genotype/0, opts)
    |> evolve(problem, {0, 0, 0.0}, opts)
  end

  defp initialize(genotype, opts) do
    population_size = Keyword.get(opts, :population_size, @population_size)
    for _ <- 1..population_size, do: genotype.()
  end

  defp evolve(population, problem, {g, lmf, temp}, opts) do
    case evaluate(population, &problem.fitness_function/1) |> problem.solution(g, temp) do
      {:solved, best} ->
        {:ok, best}

      {:unsolved, best_enough, population} ->
        pop_temp = 0.8 * (temp + (best_enough.fitness - lmf))

        population
        |> select(g, opts)
        |> crossover()
        |> mutation()
        |> evolve(problem, {g + 1, best_enough.fitness, pop_temp}, opts)
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

  defp select(population, generation, opts) do
    if generation in clone_gens(population) do
      len = length(population)
      subset_len = selection_count(population)
      IO.puts(" Clone Best #{subset_len}/#{len}")

      parents =
        Keyword.get(opts, :selection_type, &Selection.elite/2)
        |> apply([population, subset_len])
        |> Stream.cycle()
        |> Enum.take(len)
        |> Enum.shuffle()
        |> paired_up()

      {parents, []}
    else
      select(population, opts)
    end
  end

  defp select(population, opts) do
    parents =
      Keyword.get(opts, :selection_type, &Selection.elite/2)
      |> apply([population, selection_count(population)])

    {paired_up(parents), population_diff(population, parents)}
  end

  defp crossover({population, nonselected}) do
    Enum.reduce(population, [], fn {p1, p2}, acc ->
      cx_point = :rand.uniform(length(p1.genes))
      {{h1, t1}, {h2, t2}} = {Enum.split(p1.genes, cx_point), Enum.split(p2.genes, cx_point)}
      {c1, c2} = {%Chromosome{p1 | genes: h1 ++ t2}, %Chromosome{p2 | genes: h2 ++ t1}}
      [c1, c2 | acc]
    end) ++ nonselected
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

  defp make_even(n) do
    if rem(n, 2) == 0, do: n, else: n + 1
  end

  defp selection_count(population) do
    make_even(round(length(population) * @selection_rate))
  end

  defp population_diff(population, subset) do
    population
    |> MapSet.new()
    |> MapSet.difference(MapSet.new(subset))
    |> MapSet.to_list()
  end

  defp paired_up(population) do
    population
    |> Enum.chunk_every(@chunk_size)
    |> Enum.map(&List.to_tuple/1)
  end

  defp clone_gens(population) do
    len = length(population)
    Stream.iterate(10, &(&1 * 2)) |> Enum.take_while(fn x -> x < len end)
  end
end
