# A small program shaped like an Exercism Nim exercise and its tests.
# install_nim.sh compiles it with an instrumented compiler to record which
# parts of the compiler a typical test run uses (profile-guided optimisation).
import std/[json, sequtils, strutils, tables, unittest]

type Category = enum Ones, Twos, Threes, Yacht

proc score(dice: array[5, int], category: Category): int =
  case category
  of Ones, Twos, Threes:
    let n = category.ord + 1
    dice.filterIt(it == n).len * n
  of Yacht:
    if dice.allIt(it == dice[0]): 50 else: 0

proc wordCount(s: string): Table[string, int] =
  for word in s.toLowerAscii.splitWhitespace:
    result.mgetOrPut(word.strip(chars = {'.', ','}), 0) += 1

suite "Training":
  test "yacht":
    check score([5, 5, 5, 5, 5], Yacht) == 50

  test "ones":
    check score([1, 1, 1, 3, 5], Ones) == 3

  test "word count":
    check wordCount("one fish, two fish")["fish"] == 2

  test "json":
    let node = %*{"name": "test", "values": [1, 2, 3]}
    check node["values"].len == 3
    check $node == """{"name":"test","values":[1,2,3]}"""
