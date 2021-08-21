defmodule Genetic.Strategies.Mutation do
  alias Genetic.Types.Chromosome

  use Bitwise

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
