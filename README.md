[![Actions Status](https://github.com/lizmat/Set-Equality/workflows/test/badge.svg)](https://github.com/lizmat/Set-Equality/actions)

NAME
====

Set::Equality - Implement (==) for older Raku versions

SYNOPSIS
========

```raku
use Set::Equality;

say (1,2,3) (==) (3,1,2);  # True
```

DESCRIPTION
===========

The `Set::Equality` module implements the `(==)` operator (and its unicode version `≡`, and its counterpart `≢`) for versions of Raku **before** the 2020.06 Rakudo compiler release. Its implementation and tests are identical to the ones from Rakudo 2020.06 and later.

On versions of Rakudo that already implement the `(==)` operator and its friends, loading this module is basically a no-op.

The `(==)` operator conceptually coerces its parameters to `Set`s for non-`QuantHash` types. So:

```raku
(1,2,3) (==) (3,1,2)
```

is conceptually the same as:

```raku
(1,2,3).Set eqv (3,1,2).Set
```

It will however actually do as little actual coercion as possible to provide the `True` or `False` it is to return. For example:

```raku
<foo bar baz> (==) %hash
```

will return `True` if there are 3 keys in the hash, and they are `foo`, `bar` and `baz`, and each of these keys holds a truthy value.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Set-Equality . Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2020, 2021, 2024 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

