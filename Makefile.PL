#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: Makefile.PL,v 1.8 2002/04/17 21:52:37 eserte Exp eserte $
# Author: Slaven Rezic
#
# Copyright (C) 2001, 2002 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

use ExtUtils::MakeMaker;
use Cwd;

WriteMakefile
  (
   'NAME'	   => 'Patch::SREZIC::Tk',
   'VERSION'       => '800_024.007',
   'PMLIBDIRS'     => ['Tk'],
   'PREREQ_PM'     => { Tk => 800.024 },

   'dist' => {'POSTOP'=>'-$(CHMOD) 644 $(DISTVNAME).tar$(SUFFIX)'},

   'ABSTRACT_FROM' => '',
   'AUTHOR'        => 'Slaven Rezic (slaven.rezic@berlin.de)',
  );

sub MY::install {
    <<EOF;
install:
	\@echo ""
	\@echo "*** It is not recommended to install this package, as it"
	\@echo "*** would override parts of the original Tk installation."
	\@echo "*** It is better to add"
	\@echo ""
	\@echo "        use blib \\"@{[ cwd ]}\\";"
	\@echo "        use Patch::SREZIC::Tk;"
	\@echo ""
	\@echo "*** to scripts which should use the patches."
	\@echo ""
	\@sleep 1

EOF
}

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

PATCHIT=./helpers/patchit

makemodules:
	$(PATCHIT) \
		Entry/Entry.pm Entry.pm.diff Entry.pm \
		pod/Balloon.pod Balloon.pod.diff Balloon.pod \
		Tixish/DialogBox.pm DialogBox.pm.diff DialogBox.pm \
		pod/DialogBox.pod DialogBox.pod.diff DialogBox.pod \
		/dev/null FBox.pod.diff FBox.pod \
		/dev/null IconList.pod.diff IconList.pod \
		Tk/FileSelect.pm FileSelect.pm.diff FileSelect.pm \
		Tixish/LabFrame.pm LabFrame.pm.diff LabFrame.pm \
		pod/LabFrame.pod LabFrame.pod.diff LabFrame.pod \
		Listbox/Listbox.pm Listbox.pm.diff Listbox.pm \
		Tk/Menu.pm Menu.pm.diff Menu.pm \
		Tk/Pane.pm Pane.pm.diff Pane.pm \
		Text/Text.pm Text.pm.diff Text.pm \
		Tk/Widget.pm Widget.pm.diff Widget.pm \
		Tk/Wm.pm Wm.pm.diff Wm.pm \
		Scrollbar/Scrollbar.pm Scrollbar.pm.diff Scrollbar.pm \
		Tk/IconList.pm IconList.pm.diff IconList.pm \
		Tk/FBox.pm FBox.pm.diff FBox.pm \
		DragDrop/DragDrop.pm DragDrop.pm.diff DragDrop.pm \
		Tixish/NoteBook.pm NoteBook.pm.diff NoteBook.pm \
		pod/NoteBook.pod NoteBook.pod.diff NoteBook.pod \


alt-dist:
	tar --exclude "*,v" -cvz -f Patch-SREZIC-Tk-$(VERSION).tar.gz \
	    README.patches patches patches-perl patches-t

EOF
}

__END__
