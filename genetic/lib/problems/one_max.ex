defmodule Genetic.Problem.OneMax do
  @behaviour Genetic.Problem

  alias Genetic.Types.Chromosome
  alias Genetic.{Helper, Instrumentor, Solver}

  @max_fitness 1000

  def solve do
    {:ok, pid} = Instrumentor.start_link([])

    Helper.measure_time(fn ->
      Solver.run(__MODULE__)
      |> Helper.output_solution(__MODULE__)
    end)
    |> Helper.output_measurements(__MODULE__)

    Instrumentor.first_and_last_ticks()
    |> Helper.output_tick_diff()

    :ok = Instrumentor.stop(pid)
  end

  @impl true
  def solution([best | _] = population) do
    if best.fitness == @max_fitness,
      do: {:solved, best},
      else: {:unsolved, population}
  end

  @impl true
  def on_tick(proc_info) do
    {DateTime.utc_now(),
     %{
       heap_size: proc_info[:heap_size],
       stack_size: proc_info[:stack_size],
       reductions: proc_info[:reductions],
       total_heap_size: proc_info[:total_heap_size]
     }}
    |> Instrumentor.add_tick()

    :ok
  end

  @impl true
  def genotype do
    genes = for _ <- 1..@max_fitness, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: @max_fitness}
  end

  @impl true
  def fitness_function(chromosome) do
    Enum.sum(chromosome.genes)
  end
end
