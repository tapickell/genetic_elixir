measure = fn fun ->
  fun
  |> :timer.tc()
  |> elem(0)
  |> Kernel./(1_000_000)
  |> IO.inspect(label: :function_runtime)
end

n_length = 1000
population_size = 100
population = for _ <- 1..population_size, do: for(_ <- 1..n_length, do: Enum.random(0..1))

check_for_best = fn population ->
  best = Enum.max_by(population, &Enum.sum/1)
  best_sum = Enum.sum(best)
  # IO.inspect(best_sum, label: :currrent_best)
  {if(best_sum == 1000, do: :ok, else: :error), best}
end

evaluate = fn population ->
  Enum.sort_by(population, &Enum.sum/1, &>=/2)
end

selection = fn population ->
  population
  |> Enum.chunk_every(2)
  |> Enum.map(&List.to_tuple(&1))
end

crossover = fn population ->
  Enum.reduce(population, [], fn {p1, p2}, acc ->
    cx_point = :rand.uniform(1000)
    {{h1, t1}, {h2, t2}} = {Enum.split(p1, cx_point), Enum.split(p2, cx_point)}
    [h1 ++ t2, h2 ++ t1 | acc]
  end)
end

mutation = fn population ->
  population
  |> Enum.map(fn chromosome ->
    if :rand.uniform() < 0.05 do
      Enum.shuffle(chromosome)
    else
      chromosome
    end
  end)
end

gen_alg = fn population, algorithm ->
  case check_for_best.(population) do
    {:ok, best} ->
      best |> IO.inspect(label: :solution)

    {:error, _not_best} ->
      population
      |> evaluate.()
      |> selection.()
      |> crossover.()
      |> mutation.()
      |> algorithm.(algorithm)
  end
end

measure.(fn -> gen_alg.(population, gen_alg) end)
