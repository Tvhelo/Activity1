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

  test "e_determinize builds a DFA from epsilon NFA" do
    {q_prime, sigma, d_prime, q0_prime, f_prime} =
      Automata.part3_nfa_epsilon()
      |> Automata.e_determinize()

    s0 = [0, 1, 2, 3, 7]
    s1 = [1, 2, 3, 4, 6, 7, 8]
    s2 = [1, 2, 3, 5, 6, 7]
    s3 = [1, 2, 3, 5, 6, 7, 9]
    s4 = [1, 2, 3, 5, 6, 7, 10]

    assert sigma == [:a, :b]
    assert q0_prime == s0

    assert s0 in q_prime
    assert s1 in q_prime
    assert s2 in q_prime
    assert s3 in q_prime
    assert s4 in q_prime

    assert d_prime[{s0, :a}] == s1
    assert d_prime[{s0, :b}] == s2
    assert d_prime[{s1, :a}] == s1
    assert d_prime[{s1, :b}] == s3
    assert d_prime[{s3, :b}] == s4

    assert s4 in f_prime
  end
end
