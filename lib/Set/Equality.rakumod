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

=begin code :lang<raku>

use Set::Equality;

say (1,2,3) (==) (3,1,2);  # True

=end code

=head1 DESCRIPTION

The C<Set::Equality> module implements the C<(==)> operator (and its unicode
version C<≡>, and its counterpart C<≢>) for versions of Raku B<before> the
2020.06 Rakudo compiler release.  Its implementation and tests are identical
to the ones from Rakudo 2020.06 and later.

On versions of Rakudo that already implement the C<(==)> operator and its
friends, loading this module is basically a no-op.

The C<(==)> operator conceptually coerces its parameters to C<Set>s for
non-C<QuantHash> types.  So:

=begin code :lang<raku>

(1,2,3) (==) (3,1,2)

=end code

is conceptually the same as:

=begin code :lang<raku>

(1,2,3).Set eqv (3,1,2).Set

=end code

It will however actually do as little actual coercion as possible to provide
the C<True> or C<False> it is to return.  For example:

=begin code :lang<raku>

<foo bar baz> (==) %hash

=end code

will return C<True> if there are 3 keys in the hash, and they are C<foo>,
C<bar> and C<baz>, and each of these keys holds a truthy value.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Set-Equality . Comments
and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

=head1 COPYRIGHT AND LICENSE

Copyright 2020, 2021, 2024 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
