defmodule Genetic.Problem.Spelling do
  @behaviour Genetic.Problem

  alias Genetic.Types.Chromosome
  alias Genetic.{Helper, Instrumentor, Solver}

  @fitness_goal 1
  @string_length 34
  @target "supercalifragilisticexpialidocious"

  def solve(opts \\ []) do
    {:ok, pid} = Instrumentor.start_link([])

    Helper.measure_time(fn ->
      Solver.run(__MODULE__, opts)
      |> Helper.output_solution(__MODULE__)
    end)
    |> Helper.output_measurements(__MODULE__)

    Instrumentor.first_and_last_ticks()
    |> Helper.output_tick_diff()

    :ok = Instrumentor.stop(pid)
  end

  @impl true
  def genotype do
    genes =
      Stream.repeatedly(fn -> Enum.random(?a..?z) end)
      |> Enum.take(@string_length)

    %Chromosome{genes: genes, size: @string_length}
  end

  @impl true
  def fitness_function(chromosome) do
    guess = List.to_string(chromosome.genes)
    String.jaro_distance(@target, guess)
  end

  @impl true
  def solution([best | rest] = population, generation, temp) do
    worst = List.last(rest)

    IO.write(
      "\rCurrent Best: #{best.fitness}, Current Worst: #{worst.fitness}, Gen: #{generation}, PopSize: #{length(population)}, Temp: #{Float.ceil(temp, 2)}\n"
    )

    if best.fitness >= @fitness_goal - 0.01 || generation >= 2000,
      do: {:solved, best},
      else: {:unsolved, best, population}
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
end
