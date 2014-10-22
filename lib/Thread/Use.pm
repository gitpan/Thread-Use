package Thread::Use;

# Make sure we have version info for this module
# Make sure we do everything by the book
# Except for the dirty reference tricks (that's what this module is made of)

$VERSION = '0.05';
use strict;
no strict 'refs';

# Satisfy -require-

1;

#---------------------------------------------------------------------------
#  IN: 1 class to use
#      2..N any parameters to import

sub UNIVERSAL::useit {

# Make sure the module is loaded
# For all of the possible places where an import() could live
#  Reloop if it isn't there
#  Go there, with all parameters intact

    _require( $_[0] );
    foreach ($_[0],@{$_[0].'::ISA'}) {
        next unless defined( &{$_.'::import'} );
        goto &{$_.'::import'};
    }
} #UNIVERSAL::useit

#---------------------------------------------------------------------------
#  IN: 1 class to use
#      2..N any parameters to unimport

sub UNIVERSAL::noit {

# Make sure the module is loaded
# For all of the possible places where an import() could live
#  Reloop if it isn't there
#  Go there, with all parameters intact

    _require( $_[0] );
    foreach ($_[0],@{$_[0].'::ISA'}) {
        next unless defined( &{$_.'::unimport'} );
        goto &{$_.'::unimport'};
    }
} #UNIVERSAL::noit

#---------------------------------------------------------------------------
#  IN: 1 class for which to require

sub _require {

# Obtain the class
# Make sure we have directory delimiters instead of namespace delimiters
# Get the module

    my $filename = shift;
    $filename =~ s#::#/#g;
    require $filename.'.pm';
} #_require

#---------------------------------------------------------------------------

__END__

=head1 NAME

Thread::Use - use a module inside a thread only

=head1 SYNOPSIS

    use Thread::Use;

    threads->new( sub {
     useit Module;
     useit Module qw(parameters);

     noit Module;
     noit Module qw(parameters);
    } );

=head1 DESCRIPTION

                  *** A note of CAUTION ***

 This module only functions on Perl versions 5.8.0 and later.
 And then only when threads are enabled with -Dusethreads.  It
 is of no use with any version of Perl before 5.8.0 or without
 threads enabled.

                  *************************

When you are programming threaded applications and are interested in saving
memory by selectively loading modules inside threads only, you will find that
even if you C<use> a module inside a thread, it is in fact available to B<all>
threads, including the main thread.

This is caused by the fact that C<use> is executed at compile time.  At which
time Perl doesn't know anything about threads yet.

However, some modules, specifically the ones that are (partly) implemented
in XS, do not (yet) survive the cloning process that is involved with creating
threads.  So you can only use these modules inside threads only.  But if you
C<use> a module, it will be read in at compile time.

Of course, a C<use> is nothing more than a C<require> followed by a call
to the "import" class routine (if available).  But that doesn't feel natural
to do.  So this module allows you to use the C<useit> (for B<use> B<i>n
B<t>hreads command to indicate that a module should only be used inside
a thread.

For example: suppose you only need the C<PerlIO::gzip> module inside a thread:

 use Thread::Use;  # can be anywhere in your program

 threads->new( \&zipfile,filename,contents ); # start the thread

 sub zipfile {
   useit PerlIO::gzip;  # only use inside this thread
   open( my $out,'>:gzip', $_[0] ) or die "$_[0]: $!";
   print $out $_[1];
   close( $out );
 }

For completeness, it is also possible to pass any parameters as you would
with the C<use> command.  So:

 sub storable {
   useit Storable qw(freeze); # export "freeze" to namespace of thread
   my $frozen = freeze( \@_ );
 }

or to use the opposite C<no> equivalent;

 sub warnings {
   useit warnings "all";
   # special code
   noit warnings "all";
 }

=head1 REQUIRED MODULES

 (none)

=head1 CAVEATS

This modules is still experimental and subject to change.  At the current
stage it is more a proof of concept than anything else.

There is no way to C<useit> a module without having it call the "import"
class method, as you can do with C<use Module ()>.  However, a simple
C<require Module> does exactly the same, so if you want to C<useit> a module
without calling its "import" method, you should just use C<require>.

=head1 AUTHOR

Elizabeth Mattijsen, <liz@dijkmat.nl>.

Please report bugs to <perlbugs@dijkmat.nl>.

=head1 COPYRIGHT

Copyright (c) 2002-2003 Elizabeth Mattijsen <liz@dijkmat.nl>. All rights
reserved.  This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<threads>.

=cut
