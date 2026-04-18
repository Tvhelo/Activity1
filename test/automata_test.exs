defmodule AutomataTest do
  use ExUnit.Case

  test "part1_nfa returns expected 5-tuple" do
    {q, sigma, delta, q0, f} = Automata.part1_nfa()

    assert q == [0, 1, 2, 3]
    assert sigma == [:a, :b]
    assert q0 == 0
    assert f == [3]

    assert delta[{0, :a}] == [0, 1]
    assert delta[{0, :b}] == [0]
    assert delta[{1, :b}] == [2]
    assert delta[{2, :b}] == [3]
  end

  test "determinize transforms part1 NFA into equivalent DFA" do
    {q_prime, sigma, d_prime, q0_prime, f_prime} =
      Automata.part1_nfa()
      |> Automata.determinize()

    assert sigma == [:a, :b]
    assert q0_prime == [0]

    assert [0] in q_prime
    assert [0, 1] in q_prime
    assert [0, 2] in q_prime
    assert [0, 3] in q_prime

    assert d_prime[{[0], :a}] == [0, 1]
    assert d_prime[{[0], :b}] == [0]
    assert d_prime[{[0, 1], :b}] == [0, 2]
    assert d_prime[{[0, 2], :b}] == [0, 3]

    assert [0, 3] in f_prime
  end

  test "e_closure includes the same state and epsilon reachable states" do
    nfae = Automata.part3_nfa_epsilon()

    assert Automata.e_closure(nfae, [0]) == [0, 1, 2, 3, 7]
    assert Automata.e_closure(nfae, [4]) == [1, 2, 3, 4, 6, 7]
    assert Automata.e_closure(nfae, [8]) == [8]
  end

  test "e_closure works with multiple starting states" do
    nfae = Automata.part3_nfa_epsilon()

    assert Automata.e_closure(nfae, [4, 8]) == [1, 2, 3, 4, 6, 7, 8]
  end
end
