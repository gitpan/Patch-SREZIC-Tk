# -*- perl -*-

#
# $Id: Wm.pm,v 1.6 2002/03/08 21:13:49 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 2001 Slaven Rezic. All rights reserved.
# This package is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

package Patch::SREZIC::Tk::Wm;

use Tk::Wm;
package
    Tk::Wm;

sub Popup
{
 my $w = shift;
 $w->configure(@_) if @_;
 $w->idletasks;
 my ($mw,$mh) = ($w->reqwidth,$w->reqheight);
 my ($rx,$ry,$rw,$rh) = (0,0,0,0);
 my $base    = $w->cget('-popover');
 my $outside = 0;
 if (defined $base)
  {
   if ($base eq 'cursor')
    {
     ($rx,$ry) = $w->pointerxy;
    }
   else
    {
     $rx = $base->rootx;
     $ry = $base->rooty;
     $rw = $base->Width;
     $rh = $base->Height;
    }
  }
 else
  {
   my $sc = ($w->parent) ? $w->parent->toplevel : $w;
   $rx = -$sc->vrootx;
   $ry = -$sc->vrooty;
   $rw = $w->screenwidth;
   $rh = $w->screenheight;
  }
 my ($X,$Y) = AnchorAdjust($w->cget('-overanchor'),$rx,$ry,$rw,$rh);
 ($X,$Y)    = AnchorAdjust($w->cget('-popanchor'),$X,$Y,-$mw,-$mh);
 # adjust to not cross screen borders
 if ($X < 0) { $X = 0 }
 if ($Y < 0) { $Y = 0 }
 if ($X+$mw > $w->screenwidth && $mw < $w->screenwidth) { $X = "-0" }
 if ($Y+$mh > $w->screenheight && $mh < $w->screenheight) { $Y = "-0" }
# $w->Post($X,$Y); # XXX force use of geometry (because of negative coords)
 $w->positionfrom('user');
 my $geometry = sprintf "%s%d%s%d", $X =~ /^-/ ? '-' : '+', abs(int($X)),
                                    $Y =~ /^-/ ? '-' : '+', abs(int($Y));
 $w->geometry($geometry);
 $w->deiconify;
# $w->waitVisibility; # XXX seems to hang the second time???
}

sub Post
{
 my ($w,$X,$Y) = @_;
 $X = int($X);
 $Y = int($Y);
 $w->positionfrom('user');
 #$w->geometry("+$X+$Y");
 $w->MoveToplevelWindow($X,$Y);
 $w->deiconify;
# $w->idletasks; # to prevent problems with KDE's kwm etc.
# $w->raise;
}

1;

__END__
