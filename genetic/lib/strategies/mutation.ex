defmodule Genetic.Strategies.Mutation do
  alias Genetic.Types.Chromosome

  use Bitwise

  # real value genes
  def gaussian(%{genes: genes} = chromosome) do
    gene_length = length(genes)
    mu = Enum.sum(genes) / gene_length

    sigma =
      genes
      |> Enum.map(fn x -> (mu - x) * (mu - x) end)
      |> Enum.sum()
      |> Kernel./(gene_length)

    new_genes = for _ <- 1..gene_length, do: :rand.normal(mu, sigma)
    IO.inspect(gene_length == length(new_genes), label: :length_check)

    %Chromosome{chromosome | genes: new_genes}
  end

  def scramble(%{genes: genes} = chromosome) do
    %Chromosome{chromosome | genes: Enum.shuffle(genes)}
  end

  # binary genotypes
  def flip(%{genes: genes} = chromosome) do
    %Chromosome{chromosome | genes: Enum.map(genes, &bxor(&1))}
  end

  def flip_probability(%{genes: genes} = chromosome, p) do
    %Chromosome{
      chromosome
      | genes:
          Enum.map(
            genes,
            fn gene ->
              apply_with_probability(&bxor/1, gene, probability(p))
            end
          )
    }
  end

  defp bxor(gene), do: Bitwise.bxor(gene, 1)

  defp apply_with_probability(applicative, gene, true), do: apply(applicative, gene)
  defp apply_with_probability(_applicative, gene, false), do: gene

  defp probability(p), do: :rand.uniform() < p
end
