use v6.*;

unit module Set::Equality:ver<0.0.2>:auth<cpan:ELIZABETH>;

use nqp;

#--- from src/core.c/set_equality ----------------------------------------------
# This file implements the following set operators:
#   (==)  set equality (ASCII)
#   ≡     is identical to
#   ≢     is not identical to

proto sub infix:<<(==)>>($, $, *% --> Bool:D) is pure is export {*}
multi sub infix:<<(==)>>(Setty:D \a, Setty:D \b --> Bool:D) {
    nqp::unless(
      nqp::eqaddr(nqp::decont(a),nqp::decont(b)),
      nqp::stmts(                   # A and B not same object
        (my \araw := a.RAW-HASH),
        (my \braw := b.RAW-HASH),
        nqp::if(
          araw && braw,
          nqp::if(                  # A and B both allocated
            nqp::isne_i(nqp::elems(araw),nqp::elems(braw)),
            (return False),         # not same number of elems
            nqp::stmts(             # same number of elems in A and B
              (my \iter := nqp::iterator(araw)),
              nqp::while(           # have something to iterate over
                iter,
                nqp::unless(
                  nqp::existskey(braw,nqp::iterkey_s(nqp::shift(iter))),
                  return False      # elem in A doesn't exist in B
                )
              )
            )
          ),
          nqp::if(                  # A and B not both allocated
            (araw && nqp::elems(araw)) || (braw && nqp::elems(braw)),
            return False            # allocated side contains elements
          )
        )
      )
    );

    True
}
multi sub infix:<<(==)>>(Setty:D \a, Mixy:D  \b --> Bool:D) { a.Mix (==) b }
multi sub infix:<<(==)>>(Setty:D \a, Baggy:D \b --> Bool:D) { a.Bag (==) b }
multi sub infix:<<(==)>>(Setty:D \a, Any     \b --> Bool:D) { a (==) b.Set }

multi sub infix:<<(==)>>(Mixy:D \a, Mixy:D  \b --> Bool:D) {
    MIX-IS-EQUAL(a, b)
}
multi sub infix:<<(==)>>(Mixy:D \a, Baggy:D \b --> Bool:D) {
    MIX-IS-EQUAL(a, b)
}
multi sub infix:<<(==)>>(Mixy:D \a, Setty:D \b --> Bool:D) { a (==) b.Mix }
multi sub infix:<<(==)>>(Mixy:D \a, Any     \b --> Bool:D) { a (==) b.Mix }

multi sub infix:<<(==)>>(Baggy:D \a, Mixy:D \b --> Bool:D) {
    MIX-IS-EQUAL(a, b)
}
multi sub infix:<<(==)>>(Baggy:D \a, Baggy:D \b --> Bool:D) {
    MIX-IS-EQUAL(a, b)
}
multi sub infix:<<(==)>>(Baggy:D \a, Setty:D \b --> Bool:D) { a (==) b.Bag }
multi sub infix:<<(==)>>(Baggy:D \a, Any     \b --> Bool:D) { a (==) b.Bag }

multi sub infix:<<(==)>>(Map:D \a, Map:D \b --> Bool:D) {
    nqp::unless(
      nqp::eqaddr(nqp::decont(a),nqp::decont(b)),
      nqp::if(                    # A and B are different
        nqp::isne_i(
          nqp::elems(my \araw := nqp::getattr(nqp::decont(a),Map,'$!storage')),
          nqp::elems(my \braw := nqp::getattr(nqp::decont(b),Map,'$!storage'))
        ),
        (return False),           # different number of elements
        nqp::if(                  # same size
          nqp::eqaddr(a.keyof,Str(Any)) && nqp::eqaddr(b.keyof,Str(Any)),
          nqp::stmts(             # both are normal Maps
            (my \iter := nqp::iterator(araw)),
            nqp::while(
              iter,
              nqp::unless(
                nqp::iseq_i(
                  nqp::istrue(nqp::iterval(nqp::shift(iter))),
                  nqp::istrue(nqp::atkey(braw,nqp::iterkey_s(iter)))
                ),
                (return False)    # elem in A hasn't got same validity in B
              )
            )
          ),
          return a.Set (==) b.Set # either is objectHash, so coerce
        )
      )
    );

    True
}

multi sub infix:<<(==)>>(Iterable:D \a, Map:D \b --> Bool:D) {
    my \iterator := a.iterator;
    my \braw := nqp::getattr(nqp::decont(b),Map,'$!storage');

    return False                          # can never find all values
      if nqp::istype(iterator,PredictiveIterator)
      && iterator.count-only < nqp::elems(braw);

    my $key;
    my $seen := nqp::hash;
    nqp::if(
      nqp::eqaddr(b.keyof,Str(Any)),
      nqp::until(                         # normal Map
        nqp::eqaddr(($key := iterator.pull-one),IterationEnd),
        nqp::if(
          nqp::istrue(nqp::atkey(braw,$key)),
          nqp::bindkey($seen,$key,1),
          (return False)                  # not seen or not true
        )
      ),
      nqp::until(                         # object hash
        nqp::eqaddr((my \object := iterator.pull-one),IterationEnd),
        nqp::if(
          nqp::istrue(
            nqp::getattr(
              nqp::ifnull(
                nqp::atkey(braw,$key := object.WHICH),
                BEGIN                     # provide virtual value 0
                  nqp::p6bindattrinvres(nqp::create(Pair),Pair,'$!value',0)
              ),
              Pair,
              '$!value'
            )
          ),
          nqp::bindkey($seen,$key,1),
          (return False)                  # not seen or not true
        )
      )
    );

    nqp::hllbool(nqp::iseq_i(nqp::elems($seen),nqp::elems(braw)))
}

multi sub infix:<<(==)>>(Any \a, Mixy:D  \b --> Bool:D) { a.Mix (==) b     }
multi sub infix:<<(==)>>(Any \a, Baggy:D \b --> Bool:D) { a.Bag (==) b     }
multi sub infix:<<(==)>>(Any \a, Setty:D \b --> Bool:D) { a.Set (==) b     }

multi sub infix:<<(==)>>(Failure:D \a, Any $) { a.throw }
multi sub infix:<<(==)>>(Any $, Failure:D \b) { b.throw }
multi sub infix:<<(==)>>(Any \a, Any \b --> Bool:D) { a.Set (==) b.Set }

# U+2261 IDENTICAL TO
my constant &infix:<≡> is export = &infix:<<(==)>>;

# U+2262 NOT IDENTICAL TO
proto sub infix:<≢>($, $, *%) is pure is export {*}
multi sub infix:<≢>(\a, \b --> Bool:D) { not a (==) b }

#--- from src/core.c/Rakudo/QuantHash ------------------------------------------
# a Pair with the value 0
my $p0 := nqp::p6bindattrinvres(nqp::create(Pair),Pair,'$!value',0);

my sub MIX-IS-EQUAL(\a,\b) {
    nqp::unless(
      nqp::eqaddr(nqp::decont(a),nqp::decont(b)),
      nqp::stmts(                   # A and B not same object
        (my \araw := a.RAW-HASH),
        (my \braw := b.RAW-HASH),
        nqp::if(
          araw && braw,
          nqp::if(                  # A and B both allocated
            nqp::isne_i(nqp::elems(araw),nqp::elems(braw)),
            (return False),         # different number of elements
            nqp::stmts(             # same number of elements
              (my \iter := nqp::iterator(araw)),
              nqp::while(           # number of elems in B >= A
                iter,
                nqp::unless(
                  nqp::getattr(nqp::iterval(nqp::shift(iter)),Pair,'$!value')
                    ==              # value in A should equal to B
                  nqp::getattr(
                    nqp::ifnull(nqp::atkey(braw,nqp::iterkey_s(iter)),$p0),
                    Pair,
                    '$!value'
                  ),
                  return False      # not same weight
                )
              )
            )
          ),
          nqp::if(                  # A and B not both allocated
            (araw && nqp::elems(araw)) || (braw && nqp::elems(braw)),
            return False            # allocated side contains elements
          )
        )
      )
    );

    True
}

=begin pod

=head1 NAME

Set::Equality - Implement (==) for older Raku versions

=head1 SYNOPSIS

  use Set::Equality;

  say (1,2,3) (==) (3,1,2);  # True

=head1 DESCRIPTION

The C<Set::Equality> module implements the C<(==)> operator (and its unicode
version C<≡>, and its counterpart C<≢>) for versions of Raku B<before> the
2020.06 Rakudo compiler release.  Its implementation and tests are identical
to the ones from Rakudo 2020.06 and later.

The C<(==)> operator concepgtually coerces its parameters to C<Set>s for
non-C<QuantHash> types.  So:

  (1,2,3) (==) (3,1,2)

is conceptually the same as:

  (1,2,3).Set eqv (3,1,2).Set

It will however actually do as little actual coercion as possible to provide
the C<True> or C<False> it is to return.  For example:

  <foo bar baz> (==) %hash

will return C<True> if there are 3 keys in the hash, and they are C<foo>,
C<bar> and C<baz>, and each of these keys holds a truthy value.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Set-Equality . Comments
and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2020 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
