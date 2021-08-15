defmodule Genetic.Solver do
  alias Genetic.Types.Chromosome
  alias Genetic.Strategies.{Crossover, Selection}

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
        |> crossover(opts)
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
    |> Enum.sort_by(& &1.fitness, :desc)

    # |> fitness_inspection()
  end

  defp fitness_inspection(population) do
    Enum.map(population, & &1.fitness)
    |> IO.inspect(label: :fitness_sorted)

    population
  end

  # defp select(population, generation, opts) do
  #  if generation in clone_gens(population) do
  #    len = length(population)
  #    subset_len = selection_count(population)
  #    IO.puts(" Clone Best #{subset_len}/#{len}")

  #    parents =
  #      Keyword.get(opts, :selection_type, &Selection.elite/2)
  #      |> apply([population, subset_len])
  #      |> Stream.cycle()
  #      |> Enum.take(len)
  #      |> Enum.shuffle()
  #      |> paired_up()

  #    {parents, []}
  #  else
  #    select(population, opts)
  #  end
  # end

  defp select(population, _g, opts) do
    parents =
      Keyword.get(opts, :selection_type, &Selection.elite/2)
      |> apply([population, selection_count(population)])

    # IO.inspect(length(parents), label: :parents_length)
    {paired_up(parents), population_diff(population, parents)}
  end

  defp crossover({population, nonselected}, opts) do
    crossover_type = Keyword.get(opts, :crossover_type, &Crossover.order_one/2)

    Enum.reduce(population, [], fn {p1, p2}, acc ->
      {c1, c2} = apply(crossover_type, [p1, p2])
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
    # IO.inspect(length(population), label: :pop_pre_selection_count)

    make_even(round(length(population) * @selection_rate))
    # |> IO.inspect(label: :selection_count)
  end

  defp population_diff(population, subset) do
    diff_len = length(population) - length(subset)

    diff =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(subset))
      |> MapSet.to_list()
      |> clone_fill(diff_len)

    # IO.inspect(length(population), label: :population_length)
    # IO.inspect(length(subset), label: :subset_length)
    # IO.inspect(length(diff), label: :diff_length)
    diff
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

  defp clone_fill(population, len) do
    population
    |> Stream.cycle()
    |> Enum.take(len)
  end
end
