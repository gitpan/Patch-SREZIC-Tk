# -*- perl -*-

#
# $Id: Widget.pm,v 1.7 2002/02/19 22:08:10 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 2001 Slaven Rezic. All rights reserved.
# This package is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

package Patch::SREZIC::Tk::Widget;

use Tk::Widget;
package
    Tk::Widget;

sub Busy
{
 my ($w,@args) = @_;
 return unless $w->viewable;
 my($sub, %args);
 for(my $i=0; $i<=$#args; $i++) {
     if (ref $args[$i] eq 'CODE') {
	 if (defined $sub) {
	     die "Multiple code definition not allowed";
	 }
	 $sub = $args[$i];
     } else {
	 $args{$args[$i]} = $args[$i+1]; $i++;
     }
 }
 my $cursor  = delete $args{'-cursor'};
 my $recurse = delete $args{'-recurse'};
 $cursor  = 'watch' unless defined $cursor;
 unless (exists $w->{'Busy'})
  {
   my @old = ($w->grabSave);
   my $key;
   my @config;
   foreach $key (keys %args)
    {
     push(@config,$key => $w->Tk::cget($key));
    }
   if (@config)
    {
     push(@old, sub { $w->Tk::configure(@config) });
     $w->Tk::configure(%args);
    }
   unless ($w->Tk::bind('Busy'))
    {
     $w->Tk::bind('Busy','<Any-KeyPress>',[_busy => 1]);
     $w->Tk::bind('Busy','<Any-KeyRelease>',[_busy => 0]);
     $w->Tk::bind('Busy','<Any-ButtonPress>',[_busy => 1]);
     $w->Tk::bind('Busy','<Any-ButtonRelease>',[_busy => 0]);
     $w->Tk::bind('Busy','<Any-Motion>',[_busy => 0]);
    }
   $w->{'Busy'} = BusyRecurse(\@old,$w,$cursor,$recurse,1);
  }
 my $g = $w->grabCurrent;
 if (defined $g)
  {
   # warn "$g has the grab";
   $g->grabRelease;
  }
 $w->update;
 eval {local $SIG{'__DIE__'};  $w->grab };
 $w->update;
 if ($sub) {
     eval {
	 $sub->();
     };
     my $err = $@;
     $w->Unbusy(-recurse => $recurse);
     die $err if $err;
 }
}

# obsolete:
sub BindMouseWheel {
    my($w) = @_;

    # The MouseWheel will typically only fire on Windows.  However,
    # someone could use the "event generate" command to produce one
    # on other platforms.

    $w->Tk::bind('<MouseWheel>',
	      [ sub { $_[0]->yview('scroll',-($_[1]/120)*3,'units') }, Tk::Ev("D")]);

    if ($Tk::platform eq 'unix') {
	# Support for mousewheels on Linux/Unix commonly comes through mapping
	# the wheel to the extended buttons.  If you have a mousewheel, find
	# Linux configuration info at:
	#   http://www.inria.fr/koala/colas/mouse-wheel-scroll/
	$w->Tk::bind('<4>',
		 sub { $_[0]->yview('scroll', -3, 'units')
			   unless $Tk::strictMotif;
		   });
	$w->Tk::bind('<5>',
		 sub { $_[0]->yview('scroll', 3, 'units')
			   unless $Tk::strictMotif;
		   });
    }
}

# class binding
sub MouseWheelBind {
    my($mw,$class) = @_;

    # The MouseWheel will typically only fire on Windows.  However,
    # someone could use the "event generate" command to produce one
    # on other platforms.

    $mw->Tk::bind($class, '<MouseWheel>',
	      [ sub { $_[0]->yview('scroll',-($_[1]/120)*3,'units') }, Tk::Ev("D")]);

    if ($Tk::platform eq 'unix') {
	# Support for mousewheels on Linux/Unix commonly comes through mapping
	# the wheel to the extended buttons.  If you have a mousewheel, find
	# Linux configuration info at:
	#   http://www.inria.fr/koala/colas/mouse-wheel-scroll/
	$mw->Tk::bind($class, '<4>',
		 sub { $_[0]->yview('scroll', -3, 'units')
			   unless $Tk::strictMotif;
		   });
	$mw->Tk::bind($class, '<5>',
		 sub { $_[0]->yview('scroll', 3, 'units')
			   unless $Tk::strictMotif;
		   });
    }
}

1;

__END__
