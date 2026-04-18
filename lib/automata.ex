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

  def part3_nfa_epsilon do
    q = Enum.to_list(0..10)
    sigma = [:a, :b]

    delta = %{
      {0, :eps} => [1, 7],
      {1, :eps} => [2, 3],
      {2, :a} => [4],
      {3, :b} => [5],
      {4, :eps} => [6],
      {5, :eps} => [6],
      {6, :eps} => [1, 7],
      {7, :a} => [8],
      {8, :b} => [9],
      {9, :b} => [10]
    }

    q0 = 0
    f = [10]

    {q, sigma, delta, q0, f}
  end

  def e_closure({_q, _sigma, delta, _q0, _f}, states) do
    start = normalize_set(states)
    e_closure_walk(delta, start, start)
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

  defp e_closure_walk(_delta, [], visited), do: normalize_set(visited)

  defp e_closure_walk(delta, [current | rest], visited) do
    next_eps = Map.get(delta, {current, :eps}, [])

    {rest2, visited2} =
      Enum.reduce(next_eps, {rest, visited}, fn state, {pending, seen} ->
        if state in seen do
          {pending, seen}
        else
          {pending ++ [state], seen ++ [state]}
        end
      end)

    e_closure_walk(delta, rest2, visited2)
  end
end
