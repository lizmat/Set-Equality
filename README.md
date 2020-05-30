NAME
====

Set::Equality - Implement (==) for older Raku versions

SYNOPSIS
========

    use Set::Equality;

    say (1,2,3) (==) (3,1,2);  # True

DESCRIPTION
===========

The `Set::Equality` module implements the `(==)` operator (and its unicode version `≡`, and its counterpart `≢`) for older versions of Raku.

The `(==)` operator concepgtually coerces its parameters to `Set`s for non-`QuantHash` types. So:

    (1,2,3) (==) (3,1,2)

is conceptually the same as:

    (1,2,3).Set eqv (3,1,2).Set

It will however actually do as little actual coercion as possible to provide the `True` or `False` it is to return. For example:

    <foo bar baz> (==) %hash

will return `True` if there are 3 keys in the hash, and they are `foo`, `bar` and `baz`, and each of these keys holds a truthy value.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Set-Equality . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2020 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

