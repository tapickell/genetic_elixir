defmodule Genetic.Problem.Cargo do
  @moduledoc """
  Binary Genotype Optimization Problem

  IEX SOLUTION:

  indexed_sorted = Enum.zip(profits, weights) 
  |> Enum.with_index 
  |> Enum.sort(:desc)

  {result, leftover_weight} = Enum.map_reduce(indexed_sorted, 40,
   fn {{v, w}, i}, acc -> 
     if w <= acc, do: {{{v, w}, i}, acc - w}, else: {{nil, i}, acc}
   end)

  {[
   {{9, 7}, 3},
   {{8, 8}, 2},
   {{7, 9}, 5},
   {{6, 10}, 4},
   {nil, 0},
   {nil, 9},
   {{5, 6}, 1},
   {nil, 6},
   {nil, 8},
   {nil, 7}
  ], 0}

  Enum.reduce(result, {0, 0, 0}, fn {c, _i}, {va, wa, ia} ->
    case c do
      nil -> {va, wa, ia}
      {v, w} -> {va + v, wa + w, ia + 1}
    end
  end)
  {35, 40, 5}
  """
  @behaviour Genetic.Problem

  alias Genetic.Types.Chromosome
  alias Genetic.{Helper, Instrumentor, Solver}

  @cargo_size 10
  @profits [6, 5, 8, 9, 6, 7, 3, 1, 2, 6]
  @weights [10, 6, 8, 7, 10, 9, 7, 11, 6, 8]
  @weight_limit 40

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

  # terminate?/3 in book
  @impl true
  def solution([best | rest] = population, generation, temp) do
    worst = List.last(rest)

    IO.write(
      "\rBest: #{best.fitness}, Worst: #{worst.fitness}, Gen: #{generation}, PopSize: #{length(population)}, Temp: #{Float.ceil(temp, 2)}\n"
    )

    if best.fitness >= 35 || generation >= 10_000,
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

  @impl true
  def genotype do
    genes = for _ <- 1..@cargo_size, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: @cargo_size}
  end

  @impl true
  def fitness_function(chromosome) do
    potential_profits =
      @profits
      |> Enum.zip(chromosome.genes)
      |> Enum.map(fn {p, g} -> p * g end)
      |> Enum.sum()

    over_limit? =
      chromosome.genes
      |> Enum.zip(@weights)
      |> Enum.map(fn {c, w} -> c * w end)
      |> Enum.sum()
      |> Kernel.>(@weight_limit)

    if over_limit?, do: 0, else: potential_profits
  end
end
