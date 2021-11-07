sub EXPORT() {
    if  CORE::<&infix:<(==)>> {
        Map.new
    }
    else {
        require Implementation;
        Map.new:
          '&infix:<(==)>' => Implementation::{'&infix:<(==)>'},
          '&infix:<≡>'    => Implementation::{'&infix:<≡>'},
          '&infix:<≢>'    => Implementation::{'&infix:<≢>'},
    }
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

On versions of Rakudo that already implement the C<(==)> operator and its
friends, loading this module is basically a no-op.

The C<(==)> operator conceptually coerces its parameters to C<Set>s for
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

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Set-Equality . Comments
and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2020, 2021 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
