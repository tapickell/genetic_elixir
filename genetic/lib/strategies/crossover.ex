defmodule Genetic.Strategies.Crossover do
  alias Genetic.Types.Chromosome

  # Binary Genotypes
  def single_point(p1, p2) do
    cx_point = :rand.uniform(length(p1.genes))
    {{h1, t1}, {h2, t2}} = {Enum.split(p1.genes, cx_point), Enum.split(p2.genes, cx_point)}
    c1 = h1 ++ t2
    c2 = h2 ++ t1
    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end

  # Binary Genotypes
  def uniform(p1, p2, rate \\ 0.5) do
    {c1, c2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} ->
        if :rand.uniform() < rate, do: {x, y}, else: {y, x}
      end)
      |> Enum.unzip()

    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end

  # Real Value Genotypes
  def whole_arithmetic(p1, p2, alpha \\ 0.5) do
    {c1, c2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} ->
        {
          x * alpha + y * (1 - alpha),
          x * (1 - alpha) + y * alpha
        }
      end)
      |> Enum.unzip()

    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end

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

    # IO.puts(
    #  "C1 len: #{length(c1)} :: P1 len: #{length(p1.genes)}\nC2 len: #{length(c2)} :: P2 len: #{length(p2.genes)}\n"
    # )

    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end

  def order_differently(p1, p2) do
    {i1, i2} = rand_range(p1.genes)
    {h1, s1, t1} = slices(p1.genes, i1, i2)
    {h2, s2, t2} = slices(p2.genes, i1, i2)
    {c1, c2} = {h1 ++ s2 ++ t1, h2 ++ s1 ++ t2}

    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end

  defp slices(genes, i1, i2) do
    head = Enum.slice(genes, 0..i1)
    slice = Enum.slice(genes, i1..i2)
    tail = Enum.slice(genes, i2..-1)
    {head, slice, tail}
  end

  defp rand_range(l) do
    limit = Enum.count(l) - 1

    [:rand.uniform(limit), :rand.uniform(limit)]
    |> Enum.sort()
    |> List.to_tuple()
  end
end
