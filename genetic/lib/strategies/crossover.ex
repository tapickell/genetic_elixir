defmodule Genetic.Strategies.Crossover do
  alias Genetic.Types.Chromosome

  def order_one(p1, p2) do
    lim = Enum.count(p1.genes) - 1

    {i1, i2} =
      [:rand.uniform(lim), :rand.uniform(lim)]
      |> Enum.sort()
      |> List.to_tuple()

    slice1 = Enum.slice(p1.genes, i1..i2)
    slice_set1 = MapSet.new(slice1)
    p2_cont = Enum.reject(p2.genes, &MapSet.member?(slice_set1, &1))
    {h1, t1} = Enum.split(p2_cont, i1)

    slice2 = Enum.slice(p2.genes, i1..i2)
    slice_set2 = MapSet.new(slice2)
    p1_cont = Enum.reject(p2.genes, &MapSet.member?(slice_set2, &1))
    {h2, t2} = Enum.split(p1_cont, i1)

    {c1, c2} = {h1 ++ slice1 ++ t1, h2 ++ slice2 ++ t2}
    {%Chromosome{genes: c1, size: p1.size}, %Chromosome{genes: c2, size: p2.size}}
  end

  def random(p1, p2) do
    cx_point = :rand.uniform(length(p1.genes))
    {{h1, t1}, {h2, t2}} = {Enum.split(p1.genes, cx_point), Enum.split(p2.genes, cx_point)}
    {%Chromosome{p1 | genes: h1 ++ t2}, %Chromosome{p2 | genes: h2 ++ t1}}
  end
end
