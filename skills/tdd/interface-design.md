# Interface Design for Testability

Good interfaces make testing natural:

1. **Accept dependencies, don't create them**

   ```typescript
   // Testable
   function processOrder(order, paymentGateway) {}

   // Hard to test
   function processOrder(order) {
     const gateway = new StripeGateway();
   }
   ```

2. **Return results, don't produce side effects**

   ```typescript
   // Testable
   function calculateDiscount(cart): Discount {}

   // Hard to test
   function applyDiscount(cart): void {
     cart.total -= discount;
   }
   ```

3. **Small surface area**
   - Fewer methods = fewer tests needed
   - Fewer params = simpler test setup

4. **One adapter is a hypothetical seam; two make a real one**
   - Signal: an interface, an injected dependency, or an event or notification callback, with exactly one
     implementation or subscriber. (A function passed in to *decide* something, like a predicate, counts as a
     dependency: count its distinct implementations.) This item counts *implementations*; the *Speculative
     generality* row in [refactoring.md](refactoring.md) counts callers.
   - A test double at a system boundary is a second adapter, so that seam is real. A mock of an internal
     collaborator does not count, because [mocking.md](mocking.md) already rules it out.
   - With one adapter, keep passing the dependency in (item 1), but type it as the concrete class rather than an
     interface. For a callback, return the result and let the caller act on it. Extract the interface when the
     second adapter is written, not when it is imagined. "What if we swap the database" is not a second adapter.

5. **The interface is the test surface**
   - Signal: a behaviour you can observe only by reaching past the interface (one of the red flags in
     [tests.md](tests.md)) or cannot observe through it at all: it shows up only in a log or a private field, or
     only by reading the store behind the interface instead of reading back through it. No test needs to exist
     yet; ask how one would check the behaviour.
   - **Not this signal:** a side effect at a system boundary (an email sent, a file written, a payment made).
     That is observed through the boundary's test double, as [mocking.md](mocking.md) describes, and asserting
     on it is not reaching past the interface.
   - Treat it as an interface defect, not a testing one. Change the interface until the behaviour can be seen
     through it; never widen the test's reach instead.

## Design it twice

**Signal:** you are about to commit to an interface, and only one shape of it has been drafted. In finished code
you cannot see how many shapes were drafted. What you can see is how many callers the interface has: before any
exist, this is cheap, and it gets harder with every caller added.

Draft a second shape that is deliberately different, such as a different split of methods or a different owner of
the state, and do it in parallel: two agents, or two passes that cannot see each other, so the second is not a
tweak of the first. A single agent with no way to isolate the drafts says so, and writes the second draft from
the requirements alone, before rereading the first. Compare the two by which hides more behind a smaller
interface, using the *When designing interfaces, ask* questions in [deep-modules.md](deep-modules.md).
Record which one won and why the other lost, in the task or the design record (not in the code). "The first draft
won" is a valid result.
