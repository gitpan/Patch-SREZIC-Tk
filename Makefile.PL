#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: Makefile.PL,v 1.5 2002/03/02 20:19:48 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 2001 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

use ExtUtils::MakeMaker;

WriteMakefile
  (
   'NAME'	   => 'Patch::SREZIC::Tk',
   'VERSION_FROM'  => 'Tk.pm',
   'PMLIBDIRS'     => ['Tk'],
   'PREREQ_PM'     => { Tk => undef },

   'dist' => {'POSTOP'=>'-$(CHMOD) 644 $(DISTVNAME).tar$(SUFFIX)'},

   'ABSTRACT_FROM' => '',
   'AUTHOR'        => 'Slaven Rezic (eserte@onlineoffice.de)',
  );

sub MY::postamble {
    return if $ENV{USER} ne 'eserte';
    <<'EOF';
release:	dist
	cpan-upload Patch-SREZIC-Tk-$(VERSION).tar.gz

silenttest :: pure_all
	Xnest -geometry 640x400 :121 & \
	_XVFB_PID=$$!; \
	DISPLAY=:121; \
	BATCH=yes $(MAKE) test; \
	echo Kill process $$_XVFB_PID; \
	kill -TERM $$_XVFB_PID

EOF
}

__END__
