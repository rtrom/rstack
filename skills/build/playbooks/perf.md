# Perf

1. Measure a baseline on the real path: same build config, warm vs cold stated, N repeated runs with spread (BenchmarkDotNet, `dotnet-trace`, Chrome profiler, `hyperfine`). One run is an anecdote.
2. Explain the number: what limits it (CPU, IO, allocation, lock, network)? Could the benchmark be measuring setup, JIT, or caching instead of the work?
3. Profile; form hypotheses from the trace, not intuition.
4. One change per measurement. Keep a change only if the improvement exceeds run-to-run noise. Revert the rest.
5. Verify correctness is unchanged.
6. `/rstack:review`, `/rstack:pr` with before/after table and method. Append the outcome record.
