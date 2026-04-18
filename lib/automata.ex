defmodule Automata do
  def part1_nfa do
    q = [0, 1, 2, 3]
    sigma = [:a, :b]

    delta = %{
      {0, :a} => [0, 1],
      {0, :b} => [0],
      {1, :b} => [2],
      {2, :b} => [3]
    }

    q0 = 0
    f = [3]

    {q, sigma, delta, q0, f}
  end

  def determinize({q, sigma, delta, q0, f}) do
    q_prime =
      powerset(q)
      |> Enum.map(fn set -> normalize_set(set) end)
      |> Enum.uniq()
      |> Enum.sort()

    d_prime = build_dfa_transitions(q_prime, sigma, delta, %{})

    q0_prime = [q0]
    f_prime = Enum.filter(q_prime, fn r -> intersects?(r, f) end)

    {q_prime, sigma, d_prime, q0_prime, f_prime}
  end

  def powerset([]), do: [[]]

  def powerset([h | t]) do
    ps = powerset(t)
    ps ++ Enum.map(ps, fn ss -> [h | ss] end)
  end

  defp build_dfa_transitions([], _sigma, _delta, acc), do: acc

  defp build_dfa_transitions([r | tail], sigma, delta, acc) do
    acc2 =
      Enum.reduce(sigma, acc, fn a, current_acc ->
        s = move(delta, r, a)
        Map.put(current_acc, {r, a}, s)
      end)

    build_dfa_transitions(tail, sigma, delta, acc2)
  end

  defp move(delta, states, symbol) do
    states
    |> Enum.reduce([], fn state, acc ->
      acc ++ Map.get(delta, {state, symbol}, [])
    end)
    |> normalize_set()
  end

  defp intersects?(list1, list2) do
    Enum.any?(list1, fn x -> x in list2 end)
  end

  defp normalize_set(states) do
    states
    |> Enum.uniq()
    |> Enum.sort()
  end
end
