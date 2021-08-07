defmodule Genetic.Instrumentor do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> %{ticks: initial_value, initial: nil} end, name: __MODULE__)
  end

  def all_ticks do
    [Agent.get(__MODULE__, & &1.initial) | Agent.get(__MODULE__, & &1.ticks) |> Enum.reverse()]
  end

  def first_and_last_ticks do
    %{ticks: [last | _], initial: first} = Agent.get(__MODULE__, & &1)
    {first, last}
  end

  def add_tick(tick) do
    if Agent.get(__MODULE__, & &1.initial) do
      Agent.update(__MODULE__, fn state -> %{state | ticks: [tick | state.ticks]} end)
    else
      Agent.update(__MODULE__, fn state -> %{state | initial: tick} end)
    end
  end

  def stop(pid), do: Agent.stop(pid)
end
