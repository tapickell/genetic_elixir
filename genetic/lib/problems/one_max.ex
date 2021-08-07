defmodule Genetic.Problem.OneMax do
  alias Genetic.{Helper, Instrumentor, Solver}

  @max_fitness 1000

  def solve do
    {:ok, pid} = Instrumentor.start_link([])

    Helper.measure_time(fn ->
      Solver.run(&fitness_function/1, &genotype/0, &on_tick/1, @max_fitness)
      |> Helper.output_solution(__MODULE__)
    end)
    |> Helper.output_measurements(__MODULE__)

    Instrumentor.first_and_last_ticks()
    |> Helper.output_tick_diff()

    :ok = Instrumentor.stop(pid)
  end

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

  def genotype do
    for _ <- 1..1000, do: Enum.random(0..1)
  end

  def fitness_function(chromosome) do
    Enum.sum(chromosome)
  end
end
