#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: Makefile.PL,v 1.12 2003/04/23 22:07:19 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 2001, 2002, 2003 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: slaven@rezic.de
# WWW:  http://www.rezic.de/eserte/
#

use ExtUtils::MakeMaker;
use Cwd;

WriteMakefile
  (
   'NAME'	   => 'Patch::SREZIC::Tk',
   'VERSION'       => '800_024.010',
   'PREREQ_PM'     => { Tk => 800.024 },

   'dist' => {'POSTOP'=>'-$(CHMOD) 644 $(DISTVNAME).tar$(SUFFIX)'},

   'ABSTRACT_FROM' => '',
   'AUTHOR'        => 'Slaven Rezic (slaven@rezic.de)',
  );

sub MY::install {
    <<EOF;
install:
	\@echo ""
	\@echo "*** You have to apply the patches manually."
	\@echo "*** 1. Grab the Tk-800.024 distribution from CPAN"
	\@echo "       (directory authors/id/N/NI/NI-S)"
	\@echo "*** 2. Extract the distribution into a random directory"
	\@echo "*** 3. Install the makepatch package from CPAN"
	\@echo "       (directory authors/id/J/JV/JV)"
	\@echo "*** 4. Change directory to the extracted Tk distribution"
	\@echo "*** 5. Execute"
	\@echo "***    applypatch < /path/to/patch-srezic-tk800.patch"
	\@echo "*** 6. Build and install the patched Tk distribution as usual."
	\@sleep 1

EOF
}

sub MY::postamble {
    return if $ENV{USER} ne 'eserte';
    <<'EOF';
release:	dist
	cpan-upload Patch-SREZIC-Tk-$(VERSION).tar.gz

makepatch:
	makepatch -descr "" -diff "gdiff -up" /usr/local/src/Tk800.024 /usr/local/src/work/Tk800 > patch-srezic-tk800.patch

EOF
}

__END__
