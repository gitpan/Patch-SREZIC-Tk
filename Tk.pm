# -*- perl -*-

#
# $Id: Tk.pm,v 1.36 2002/03/11 21:44:45 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 2001,2002 Slaven Rezic. All rights reserved.
# This package is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

package Patch::SREZIC::Tk;
use vars qw($VERSION $VERBOSE);

$VERSION = "800_024.003";
$VERBOSE = 1 unless defined $VERBOSE;

use Tk 800.024;

sub out ($) { if ($VERBOSE) { print STDERR "Loading patch $_[0]\n" } }

if ($Tk::platform ne "MSWin32") {
    out "Tk::Wm";
    eval 'use Patch::SREZIC::Tk::Wm'; die $@ if $@;
}

out "Tk::Widget";
use Patch::SREZIC::Tk::Widget;

out "Tk::Entry";
use Patch::SREZIC::Tk::Entry;

out "Tk::FBox";
use Patch::SREZIC::Tk::FBox;

out "Tk::IconList";
use Patch::SREZIC::Tk::IconList;

out "Tk::HList";
use Patch::SREZIC::Tk::HList;

out "Tk::DialogBox";
use Patch::SREZIC::Tk::DialogBox;

out "Tk::DragDrop";
use Patch::SREZIC::Tk::DragDrop;

out "Tk::DragDrop::XDNDSite";
use Patch::SREZIC::Tk::DragDrop::XDNDSite;

out "Tk::Menu";
use Patch::SREZIC::Tk::Menu;

out "Tk::Listbox";
use Patch::SREZIC::Tk::Listbox;

out "Tk::FileSelect";
use Patch::SREZIC::Tk::FileSelect;

out "Tk::LabFrame";
use Patch::SREZIC::Tk::LabFrame;

out "Tk::Scrollbar";
use Patch::SREZIC::Tk::Scrollbar;

## not yet:
#out "Tk::Text: nicer find/replace popup";
#use Patch::SREZIC::Tk::Text;

package
    Tk;

1;

__END__
