#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: wm-post.t,v 1.3 2002/02/19 22:01:45 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 2001 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

use Test;
BEGIN { plan tests => 3 }

BEGIN { $Patch::SREZIC::Tk::VERBOSE = 0 }
use Patch::SREZIC::Tk;
use Tk;

my $mw = new MainWindow;

$mw->after(1000, sub { $mw->Walk(sub { eval { $_[0]->invoke } }) })
    if $ENV{BATCH};

$mw->messageBox(-icon => "info",
		-message => "test");
ok(1);

$mw->after(1000, sub { $mw->Walk(sub { eval { $_[0]->invoke } }) })
    if $ENV{BATCH};

$mw->messageBox(-icon => "info",
		-message => "test");
ok(1);

$mw->after(1000, sub { $mw->Walk(sub { eval { $_[0]->invoke } }) })
    if $ENV{BATCH};

$mw->Dialog->Show;
ok(1);

#MainLoop;

__END__
