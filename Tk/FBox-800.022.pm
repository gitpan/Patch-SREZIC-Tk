# -*- perl -*-

#
# $Id: FBox-800.022.pm,v 1.8 2001/11/18 10:07:46 eserte Exp $
# Author: Slaven Rezic
#
# This is a patch against the original Tk/FBox.pm. Please consult
# the Perl/Tk documentation and/or sources for copyrights.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

package Patch::SREZIC::Tk::FBox;

use Tk::FBox;
package
    Tk::FBox;

sub Populate {
    my($w, $args) = @_;

    require Tk::IconList;
    require File::Basename;
    require Cwd;

    $w->SUPER::Populate($args);

    # f1: the frame with the directory option menu
    my $f1 = $w->Frame;
    my $lab = $f1->Label(-text => 'Directory:', -underline => 0);
    $w->{'dirMenu'} = my $dirMenu =
      $f1->Optionmenu(-variable => \$w->{'selectPath'},
		      -command => ['SetPath', $w]);
    my $upBtn = $f1->Button;
    my $mw = $w->MainWindow; # main window of current FBox
    if (!defined $updirImage->{$mw}) {
	$updirImage->{$mw} = $w->Bitmap(-data => "#define updir_width 28\n" .
	                                  "#define updir_height 16\n" .
				          <<EOF);
static char updir_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x80, 0x1f, 0x00, 0x00, 0x40, 0x20, 0x00, 0x00,
   0x20, 0x40, 0x00, 0x00, 0xf0, 0xff, 0xff, 0x01, 0x10, 0x00, 0x00, 0x01,
   0x10, 0x02, 0x00, 0x01, 0x10, 0x07, 0x00, 0x01, 0x90, 0x0f, 0x00, 0x01,
   0x10, 0x02, 0x00, 0x01, 0x10, 0x02, 0x00, 0x01, 0x10, 0x02, 0x00, 0x01,
   0x10, 0xfe, 0x07, 0x01, 0x10, 0x00, 0x00, 0x01, 0x10, 0x00, 0x00, 0x01,
   0xf0, 0xff, 0xff, 0x01};
EOF
    }
    $upBtn->configure(-image => $updirImage->{$mw});
    $dirMenu->configure(-takefocus => 1, -highlightthickness => 2);
    $upBtn->pack(-side => 'right', -padx => 4, -fill => 'both');
    $lab->pack(-side => 'left', -padx => 4, -fill => 'both');
    $dirMenu->pack(-expand => 'yes', -fill => 'both', -padx => 4);

    $w->{'icons'} = my $icons =
      $w->IconList(-browsecmd => ['ListBrowse', $w],
		   -command   => ['ListInvoke', $w],
		  );

    # f2: the frame with the OK button and the "file name" field
    my $f2 = $w->Frame(-bd => 0);
    my $f2_lab = $f2->Label(-text => 'File name:', -anchor => 'e',
			    -width => 14, -underline => 5, -pady => 0);
    $w->{'ent'} = my $ent = $f2->Entry;

    # The font to use for the icons. The default Canvas font on Unix
    # is just deviant.
#    $w->{'icons'}{'font'} = $ent->cget(-font);
    $w->{'icons'}->configure(-font => $ent->cget(-font));

    # f3: the frame with the cancel button and the file types field
    my $f3 = $w->Frame(-bd => 0);

    # The "File of types:" label needs to be grayed-out when
    # -filetypes are not specified. The label widget does not support
    # grayed-out text on monochrome displays. Therefore, we have to
    # use a button widget to emulate a label widget (by setting its
    # bindtags)
    $w->{'typeMenuLab'} = my $typeMenuLab = $f3->Button
      (-text => 'Files of type:',
       -anchor  => 'e',
       -width => 14,
       -underline => 9,
       -bd => $f2_lab->cget(-bd),
       -highlightthickness => $f2_lab->cget(-highlightthickness),
       -relief => $f2_lab->cget(-relief),
       -padx => $f2_lab->cget(-padx),
       -pady => $f2_lab->cget(-pady),
      );
    $typeMenuLab->bindtags([$typeMenuLab, 'Label',
			    $typeMenuLab->toplevel, 'all']);
    $w->{'typeMenuBtn'} = my $typeMenuBtn =
      $f3->Menubutton(-indicatoron => 1, -tearoff => 0);
    $typeMenuBtn->configure(-takefocus => 1,
			    -highlightthickness => 2,
			    -relief => 'raised',
			    -bd => 2,
			    -anchor => 'w',
			   );

    # the okBtn is created after the typeMenu so that the keyboard traversal
    # is in the right order
    $w->{'okBtn'} = my $okBtn = $f2->Button
      (-text => 'OK',
       -underline => 0,
       -width => 6,
       -default => 'active',
       -pady => 3,
      );
    my $cancelBtn = $f3->Button
      (-text => 'Cancel',
       -underline => 0,
       -width => 6,
       -default => 'normal',
       -pady => 3,
      );

    # pack the widgets in f2 and f3
    $okBtn->pack(-side => 'right', -padx => 4, -anchor => 'e');
    $f2_lab->pack(-side => 'left', -padx => 4);
    $ent->pack(-expand => 'yes', -fill => 'x', -padx => 2, -pady => 0);
    $cancelBtn->pack(-side => 'right', -padx => 4, -anchor => 'w');
    $typeMenuLab->pack(-side => 'left', -padx => 4);
    $typeMenuBtn->pack(-expand => 'yes', -fill => 'x', -side => 'right');

    # Pack all the frames together. We are done with widget construction.
    $f1->pack(-side => 'top', -fill => 'x', -pady => 4);
    $f3->pack(-side => 'bottom', -fill => 'x');
    $f2->pack(-side => 'bottom', -fill => 'x');
    $icons->pack(-expand => 'yes', -fill => 'both', -padx => 4, -pady => 1);

    # Set up the event handlers
    $ent->bind('<Return>',[$w,'ActivateEnt']);
    $upBtn->configure(-command => ['UpDirCmd', $w]);
    $okBtn->configure(-command => ['OkCmd', $w]);
    $cancelBtn->configure(-command, ['CancelCmd', $w]);

    $w->bind('<Alt-d>',[$dirMenu,'focus']);
    $w->bind('<Alt-t>',sub  {
                             if ($typeMenuBtn->cget(-state) eq 'normal') {
                             $typeMenuBtn->focus;
                             } });
    $w->bind('<Alt-n>',[$ent,'focus']);
    $w->bind('<KeyPress-Escape>',[$cancelBtn,'invoke']);
    $w->bind('<Alt-c>',[$cancelBtn,'invoke']);
    $w->bind('<Alt-o>',['InvokeBtn','Open']);
    $w->bind('<Alt-s>',['InvokeBtn','Save']);
    $w->protocol('WM_DELETE_WINDOW', ['CancelCmd', $w]);
    $w->OnDestroy(['CancelCmd', $w]);

    # Build the focus group for all the entries
    $w->FG_Create;
    $w->FG_BindIn($ent, ['EntFocusIn', $w]);
    $w->FG_BindOut($ent, ['EntFocusOut', $w]);

    $w->SetPath(_cwd());

    $w->ConfigSpecs(-defaultextension => ['PASSIVE', undef, undef, undef],
		    -filetypes        => ['PASSIVE', undef, undef, undef],
		    -initialdir       => ['PASSIVE', undef, undef, undef],
		    -initialfile      => ['PASSIVE', undef, undef, undef],
		    -title            => ['PASSIVE', undef, undef, undef],
		    -type             => ['PASSIVE', undef, undef, 'open'],
		    -filter           => ['PASSIVE', undef, undef, '*'],
		    -force            => ['PASSIVE', undef, undef, 0],
		    'DEFAULT'         => [$icons],
		   );
    # So-far-failed attempt to break reference loops ...
    $w->_OnDestroy(qw(dirMenu icons typeMenuLab typeMenuBtn okBtn ent updateId));
    $w;
}

sub Show {
    my $w = shift;

    $w->configure(@_);

    $w->transient($w->Parent);

    # set the default directory and selection according to the -initial
    # settings
    {
	my $initialdir = $w->cget(-initialdir);
	if (defined $initialdir) {
	    eval {
		require File::Spec;
		if (!File::Spec->file_name_is_absolute($initialdir)) {
		    $initialdir = File::Spec->canonpath(File::Spec->catdir(_cwd(), $initialdir));
		}
	    };
	    if ($@) {
		if ($initialdir !~ m|^/|) {
		    $initialdir = _cwd() . "/$initialdir";
		}
	    }

	    if (-d $initialdir) {
		$w->{'selectPath'} = $initialdir;
	    } else {
		$w->Error("\"$initialdir\" is not a valid directory");
	    }
	}
	$w->{'selectFile'} = $w->cget(-initialfile);
    }

    # Initialize the file types menu
    my $typeMenuBtn = $w->{'typeMenuBtn'};
    my $typeMenuLab = $w->{'typeMenuLab'};
    if (defined $w->cget('-filetypes')) {
	my(@filetypes) = GetFileTypes($w->cget('-filetypes'));
	my $typeMenu = $typeMenuBtn->cget(-menu);
	$typeMenu->delete(0, 'end');
	foreach my $ft (@filetypes) {
	    my $title  = $ft->[0];
	    my $filter = join(' ', @{ $ft->[1] });
	    $typeMenuBtn->command
	      (-label => $title,
	       -command => ['SetFilter', $w, $title, $filter],
	      );
	}
	$w->SetFilter($filetypes[0]->[0], join(' ', @{ $filetypes[0]->[1] }));
	$typeMenuBtn->configure(-state => 'normal');
	$typeMenuLab->configure(-state => 'normal');
    } else {
	$w->configure(-filter => '*');
	$typeMenuBtn->configure(-state => 'disabled',
				-takefocus => 0);
	$typeMenuLab->configure(-state => 'disabled');
    }
    $w->UpdateWhenIdle;

    # Withdraw the window, then update all the geometry information
    # so we know how big it wants to be, then center the window in the
    # display and de-iconify it.
    $w->withdraw;
    $w->idletasks;
    my $x = int($w->screenwidth / 2 - $w->reqwidth / 2 - $w->parent->vrootx);
    my $y = int($w->screenheight / 2 - $w->reqheight / 2 - $w->parent->vrooty);
    $w->geometry("+$x+$y");

    {
	my $title = $w->cget(-title);
	if (!defined $title) {
	    $title = ($w->cget(-type) eq 'open' ? 'Open' : 'Save As');
	}
	$w->title($title);
    }

    $w->deiconify;
    # Set a grab and claim the focus too.
    my $oldFocus = $w->focusCurrent;
    my $oldGrab = $w->grabCurrent;
    my $grabStatus = $oldGrab->grabStatus if ($oldGrab);
    $w->grab;
    my $ent = $w->{'ent'};
    $ent->focus;
    $ent->delete(0, 'end');
    $ent->insert(0, $w->{'selectFile'});
    $ent->selectionFrom(0);
    $ent->selectionTo('end');
    $ent->icursor('end');

    # 8. Wait for the user to respond, then restore the focus and
    # return the index of the selected button.  Restore the focus
    # before deleting the window, since otherwise the window manager
    # may take the focus away so we can't redirect it.  Finally,
    # restore any grab that was in effect.
    $w->waitVariable(\$w->{'selectFilePath'});
    eval {
	$oldFocus->focus if $oldFocus;
    };
    if (Tk::Exists($w)) { # widget still exists
	$w->grabRelease;
	$w->withdraw;
    }
    if ($oldGrab) {
	if ($grabStatus eq 'global') {
	    $oldGrab->grabGlobal;
	} else {
	    $oldGrab->grab;
	}
    }
    return $w->{'selectFilePath'};
}

sub Update {
    my $w = shift;
    my $dataName = $w->name;

    # This proc may be called within an idle handler. Make sure that the
    # window has not been destroyed before this proc is called
    if (!Tk::Exists($w) || $w->class ne 'FBox') {
	return;
    } else {
	delete $w->{'updateId'};
    }
    my $mw = $w->MainWindow; # main window of current FBox
    unless (defined $folderImage->{$mw}) {
	require Tk::Pixmap;
	$folderImage->{$mw} = $w->Pixmap(-file => Tk->findINC('folder.xpm'));
	$fileImage->{$mw}   = $w->Pixmap(-file => Tk->findINC('file.xpm'));
    }
    my $folder = $folderImage->{$mw};
    my $file   = $fileImage->{$mw};
    my $appPWD = _cwd();
    if (!ext_chdir($w->{'selectPath'})) {
	# We cannot change directory to $data(selectPath). $data(selectPath)
	# should have been checked before tkFDialog_Update is called, so
	# we normally won't come to here. Anyways, give an error and abort
	# action.
	$w->messageBox(-type => 'OK',
		       -message => 'Cannot change to the directory "' .
		       $w->{'selectPath'} . "\".\nPermission denied.",
		       -icon => 'warning',
		      );
	ext_chdir($appPWD);
	return;
    }

    # Turn on the busy cursor. BUG?? We haven't disabled X events, though,
    # so the user may still click and cause havoc ...
    my $ent = $w->{'ent'};
    my $entCursor = $ent->cget(-cursor);
    my $dlgCursor = $w->cget(-cursor);
    $ent->configure(-cursor => 'watch');
    $w->configure(-cursor => 'watch');
    $w->idletasks;
    my $icons = $w->{'icons'};
    $icons->DeleteAll;

    # Make the dir & file list
    my $flt = join('|', split(' ', $w->cget(-filter)) );
    $flt =~ s!([\.\+])!\\$1!g;
    $flt =~ s!\*!.*!g;
    local *FDIR;
    if( opendir( FDIR,  _cwd() )) {
      my @files;
        foreach my $f (sort { lc($a) cmp lc($b) } readdir FDIR) {
          next if $f eq '.' or $f eq '..';
          if (-d $f) { $icons->Add($folder, $f); }
          elsif( $f =~ m!$flt$! ) { push( @files, $f ); }
	}
      closedir( FDIR );
      foreach my $f ( @files ) { $icons->Add($file, $f); }
    }

    $icons->Arrange;

    # Update the Directory: option menu
    my @list;
    my $dir = '';
    foreach my $subdir (TclFileSplit($w->{'selectPath'})) {
	$dir = TclFileJoin($dir, $subdir);
	push @list, $dir;
    }
    my $dirMenu = $w->{'dirMenu'};
    $dirMenu->configure(-options => \@list);

    # Restore the PWD to the application's PWD
    ext_chdir($appPWD);

    # Restore the Save label
    if ($w->cget(-type) eq 'save') {
	$w->{'okBtn'}->configure(-text => 'Save');
    }

    # turn off the busy cursor.
    $ent->configure(-cursor => $entCursor);
    $w->configure(-cursor =>  $dlgCursor);
}

sub CancelCmd {
    my $w = shift;
    undef $w->{'selectFilePath'};
}

sub ListInvoke {
    my($w, $text) = @_;
    return if ($text eq '');
    my $file = JoinFile($w->{'selectPath'}, $text);
    if (-d $file) {
	my $appPWD = _cwd();
	if (!ext_chdir($file)) {
	    $w->messageBox(-type => 'OK',
			   -message => "Cannot change to the directory \"$file\".\nPermission denied.",
			   -icon => 'warning');
	} else {
	    ext_chdir($appPWD);
	    $w->SetPath($file);
	}
    } else {
	my($flag, $path, $file) = ResolveFile($w->{'selectPath'}, $text);
	if ($flag ne 'OK') {
	    $w->messageBox(-type => 'OK',
			   -message => "Cannot resolve $w->{'selectPath'}/$text.",
			   -icon => 'error');
	} else {
	    $path = JoinFile($path, $file);
	    return unless $w->CheckSaveFile($path);
	    $w->Done($path);
	}
    }
}

sub CheckSaveFile {
    my($w, $filename) = @_;
    if (-e $filename and
	$w->cget(-type) eq 'save' and
	!$w->cget(-force)) {
	my $reply = $w->messageBox
	    (-icon => 'warning',
	     -type => 'YesNo',
	     -message => "File \"$filename\" already exists.\nDo you want to overwrite it?");
	return 0 unless (lc($reply) eq 'yes');
    }
    1;
}

sub Done {
    my $w = shift;
    my $_selectFilePath = (@_) ? shift : '';
    if ($_selectFilePath eq '') {
	$_selectFilePath = JoinFile($w->{'selectPath'}, $w->{'selectFile'});
	return unless $w->CheckSaveFile($_selectFilePath);
    }
    $w->{'selectFilePath'} = ($_selectFilePath ne '' ? $_selectFilePath : undef);
}

1;

__END__
