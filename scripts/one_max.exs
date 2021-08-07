n_length = 1000
population_size = 100
population = for _ <- 1..population_size, do: for(_ <- 1..n_length, do: Enum.random(0..1))
