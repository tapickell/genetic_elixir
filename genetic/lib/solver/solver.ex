defmodule Genetic.Solver do
  alias Genetic.Types.Chromosome

  @population_size 100
  @chunk_size 2

  def run(problem, opts \\ []) do
    initialize(&problem.genotype/0, opts)
    |> evolve(problem)
  end

  defp initialize(genotype, opts) do
    population_size = Keyword.get(opts, :population_size, @population_size)
    for _ <- 1..population_size, do: genotype.()
  end

  defp evolve(population, problem) do
    problem.on_tick(Process.info(self()))

    case evaluate(population, &problem.fitness_function/1) |> problem.solution() do
      {:solved, best} ->
        {:ok, best}

      {:unsolved, population} ->
        population
        |> select()
        |> crossover()
        |> mutation()
        |> evolve(problem)
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

  defp select(population) do
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
      if :rand.uniform() < 0.05 do
        %Chromosome{chromosome | genes: Enum.shuffle(chromosome.genes)}
      else
        chromosome
      end
    end)
  end
end
