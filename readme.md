# Zeek

Zeek a fuzzy finder in ZIG.

## Features

### V0

- write the algo
- fix the algo

### V1

- pattern input
- choose output out of 10

### V2

- prev next

## Command line interface ideas

Simple input in lines. The input is evaluated against the pattern. The inputs with the highest score
are up top. The solutions are cut off at 10. You choose a number. The input with the number gets
printed to the standard output.

```bash
$ cat options | zeek "pattern"
1 patterns
2 patners
3 patties
4 panties
5 cat
6 ...
...
chose (1..10): 2
patterns
```

What if you want to add a pattern later (idea):

```bash
$ cat file | zeek
enter a pattern: pattern
-- options --
1 patterns
2 patners
3 patties
4 panties
5 cat
6 ...
...
chose (1..10, n, next, p, prev): 2
patterns
```
