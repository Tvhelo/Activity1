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

  def e_determinize({_q, sigma, _delta, q0, f} = nfae) do
    q0_prime = e_closure(nfae, [q0])

    {q_prime, d_prime} =
      e_determinize_reachable(nfae, sigma, [q0_prime], [], %{})

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

  defp e_determinize_reachable(_nfae, _sigma, [], visited, d_prime) do
    {Enum.sort(visited), d_prime}
  end

  defp e_determinize_reachable(nfae, sigma, [r | open], visited, d_prime) do
    if r in visited do
      e_determinize_reachable(nfae, sigma, open, visited, d_prime)
    else
      {new_transitions, new_states} = process_symbols(nfae, r, sigma, %{}, [])

      e_determinize_reachable(
        nfae,
        sigma,
        open ++ new_states,
        [r | visited],
        Map.merge(d_prime, new_transitions)
      )
    end
  end

  defp process_symbols(_nfae, _r, [], transitions, new_states) do
    {transitions, new_states}
  end

  defp process_symbols(nfae, r, [a | rest], transitions, new_states) do
    s = move_with_epsilon(nfae, r, a)

    if s == [] do
      process_symbols(nfae, r, rest, transitions, new_states)
    else
      process_symbols(
        nfae,
        r,
        rest,
        Map.put(transitions, {r, a}, s),
        new_states ++ [s]
      )
    end
  end

  defp move_with_epsilon({_q, _sigma, delta, _q0, _f} = nfae, r, a) do
    closure_r = e_closure(nfae, r)
    moved = move(delta, closure_r, a)
    e_closure(nfae, moved)
  end
end
