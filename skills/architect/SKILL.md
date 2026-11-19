---
name: architect
description: Settle types, signatures, and module shape before writing code that crosses a function or module boundary. Use when designing a new module or API, or when jumping straight to code would lock in the wrong shape.
---

# Architect

1. **Trace** every system the change touches: callers, data flow, persistence, external boundaries. Write the caller's usage first, as it would read at the call site.
2. **Sketch two different shapes**: types, signatures, module boundaries. Not two spellings of one idea; two real alternatives (e.g. state machine vs flags; one deep module vs two shallow ones; push vs pull).
3. **Pick** the shape where:
   - each piece of state has exactly one owner;
   - each task has one way to do it;
   - callers need to know the least (a deep module: lots of behavior behind a small interface);
   - illegal states are unrepresentable in the types (discriminated unions / sealed records, branded IDs, parse at the boundary);
   - validation lives at system boundaries and business logic stays pure.
4. **Write it down** as code skeletons (interfaces, records, signatures with `throw new NotImplementedException()` / `throw new Error("todo")`), compiled. The implementer fills in bodies; it doesn't redesign.
5. If workarounds repeat while filling in, the shape is wrong. Redesign, don't patch.

Large or contested design → the **arena** skill instead of sketching alone.

Output: the chosen skeleton, the rejected shape in two lines with why it lost, and the seams it implies for testing.
