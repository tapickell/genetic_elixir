defmodule Genetic.Problem do
  alias Genetic.Types.Chromosome

  @callback genotype :: Chromosome.t()
  @callback fitness_function(Chromosome.t()) :: number()
  @callback solution(Enum.t()) :: {:solved, Enum.t()} | {:unsolved, Enum.t()}
  @callback on_tick(Keyword.t()) :: :ok
end
