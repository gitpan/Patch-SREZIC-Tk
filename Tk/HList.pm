# -*- perl -*-

#
# $Id: HList.pm,v 1.9 2002/03/01 09:17:05 eserte Exp $
# Maintainer: Slaven Rezic
#
# This is a patch against the original Tk/HList.pm. Please consult
# the Perl/Tk documentation and/or sources for copyrights.
#
# Most by Rob Seegel from: http://members.aol.com/robseegel/tk/hlist.tar.gz
#

package Patch::SREZIC::Tk::HList;

package
    Tk::HList;
# to avoid Tk::HList from being loaded...
$INC{"Tk/HList.pm"} = $INC{"Patch/SREZIC/Tk/HList.pm"};

use vars qw($VERSION);
$VERSION = '3.038';

use Tk qw(Ev $XS_VERSION);

require Tk::Derived;
use base  qw(Tk::Derived Tk::Widget);
use strict;

bootstrap Tk::HList;

sub Tk_cmd { \&Tk::hlist }

Tk::Widget->Construct('HList');

## Removed anchor, info and nearest from Methods (they are called from
## within defined methods of the same name below.) (RCS)

Tk::Methods qw(add addchild column delete dragsite dropsite entrycget
               entryconfigure geometryinfo indicator header hide item
               see select selection show xview yview);

use Tk::Submethods (
  'active'    => [qw(clear set)],
  'anchor'    => [qw(clear set)],
  'column'    => [qw(width)],
  'delete'    => [qw(all entry offsprings siblings)],
  'header'    => [qw(configure cget create delete exists size)],
  'hide'      => [qw(entry)],
  'indicator' => [qw(configure cget create delete exists size)],
  'info'      => [qw(active anchor bbox children data dragsite
                     dropsite exists hidden item next parent prev
                     selection)],
  'item'      => [qw(configure cget create delete exists)],
  'selection' => [qw(clear get includes set)],

);

sub ClassInit {
  my ($class,$mw) = @_;

  $mw->bind($class,'<B1-Enter>',       'B1_Enter');
  $mw->bind($class,'<B1-Leave>',       'AutoScan' );
  $mw->bind($class,'<B1-Motion>',      'Button1Motion' );
  $mw->bind($class,'<ButtonPress-1>',  'Button1'  );
  $mw->bind($class,'<ButtonRelease-1>','ButtonRelease_1');

  $mw->bind($class,'<Control-backslash>',           'SelectNone');
  $mw->bind($class,'<Control-ButtonPress-1>',       'CtrlButton1');
  $mw->bind($class,'<Control-Double-ButtonPress-1>','CtrlButton1');
  $mw->bind($class,'<Control-End>',                 'CtrlEnd');
  $mw->bind($class,'<Control-Home>',                'CtrlHome');
  $mw->bind($class,'<Control-slash>',               'SelectAll');
  $mw->bind($class,'<Double-ButtonPress-1>',        'Double1');

  $mw->bind($class,'<Down>',                ['UpDown', 'next']);
  $mw->bind($class,'<FocusIn>',             'FocusIn');
  $mw->bind($class,'<FocusOut>',            'FocusOut');
  $mw->bind($class,'<Return>',              'KeyboardActivate');
  $mw->bind($class,'<Shift-ButtonPress-1>', 'ShiftButton1' );
  $mw->bind($class,'<Shift-Up>',            ['ShiftUpDown', 'prev']);
  $mw->bind($class,'<Shift-Down>',          ['ShiftUpDown', 'next']);
  $mw->bind($class,'<space>',               'KeyboardSelect');
  $mw->bind($class,'<Up>',                  ['UpDown', 'prev']);

  $mw->PriorNextBind($class);
  return $class;
}

sub CreateArgs {
    my ($package, $parent, $args) = @_;
    my @result = $package->SUPER::CreateArgs($parent,$args);
    my $columns = delete $args->{-columns};
    push(@result, '-columns' => $columns) if (defined $columns);
    return @result;
}

sub Populate {
  my ($w, $args) = @_;

  $w->{m_prev} = undef;      ## Previous selected Entry
  $w->{m_selected} = [];     ## Currently selected Entries 
  $w->{m_tixindicator} = "";

  $w->ConfigSpecs(
    -foreground =>       [qw/SELF foreground Foreground black/, ],
    -background =>       [qw/SELF background Background/, Tk::NORMAL_BG],
    -selectbackground => [qw/SELF selectBackground Background/, Tk::SELECT_BG ],
    -selectforeground => [qw/SELF selectForeground Foreground/, Tk::SELECT_FG ],
    -showactive =>       [qw/METHOD showActive ShowActive 1/]
  );
}

############################################################
## Public methods
############################################################

## This method takes the place of anchor, and calls the tix
## HList anchor routines in their place. Active now has nothing
## to do with the anchor mechanism now, and only involves the
## the highlighting. If -showactive is set to anything but 0, then the
## default C anchor will be used. Otherwise, it's not. This is a 
## quick way to toggle on/off the dashed box that represents an 
## anchored entry. (RCS)

sub active {
  my $w = shift;
  my $cmd = shift;

  if ($cmd eq "clear") {
    $w->{m_active} = undef;
    $w->WidgetMethod('anchor', 'clear') if $w->cget('-showactive');

  } elsif ($cmd eq "set") {
    my $ent = shift;
    if (defined($ent)) {
      $w->{m_active} = $ent;

      $w->WidgetMethod('anchor', 'set', $ent)
        if ($w->cget('-showactive') && $w->focusCurrent == $w);
    }
  }
}

## This takes the place of the tix anchor command and
## has _nothing_ to do with highlighting.

sub anchor {
  my ($w, $cmd, $ent) = @_;
  if ($cmd eq "clear") {
    $w->{m_anchor} = undef;
    $w->active('clear') if $w->cget('-showactive');

  } elsif ($cmd eq "set") {
    $w->{m_anchor} = $ent if (defined($ent));
    $w->active('set' => $ent) if $w->cget('-showactive');
  }
}

## Tix has core-tk window(s) that are not a widget(s)
## The generic code returns these as undef

sub children {
  my $w = shift;
  my @info = grep(defined($_),$w->winfo('children'));
  @info;
}

## This probably seems excessive - I substitute my own
## implementation for info anchor, and use the base 
## info implementation for everything else. This is so 
## that $w->info("anchor") and $w->infoAnchor will work 
## identically. (RCS)

sub info {
  my ($w, $cmd, @args) = @_;
  if ($cmd eq "active") {
    return $w->{m_active};

  } elsif ($cmd eq "anchor") {
    return $w->{m_anchor};

  } else {
    return $w->WidgetMethod("info", $cmd, @args);
  }
}

## This used to be GetNearest, but I thought that the functionality
## that it offered was too useful not to make available to 
## anyone who wished to use it. (RCS)

sub nearest {
  my ($w, $y,$undefafterend) = @_;
  my $ent = $w->WidgetMethod('nearest', $y);
  if (defined $ent) {

    if ($undefafterend) {
      my $borderwidth = $w->cget('-borderwidth');
      my $highlightthickness = $w->cget('-highlightthickness');
      my $bottomy = ($w->infoBbox($ent))[3];
      $bottomy += $borderwidth + $highlightthickness;
      if ($w->header('exist', 0)){ $bottomy += ($w->header('size', 0))[1]; };
      if ($y > $bottomy){ return undef; }
    }

    my $state = $w->entrycget($ent, '-state');
    return $ent if (!defined($state) || $state ne 'disabled');
  }
  return undef;
}

# for backward compatibility
*GetNearest = \&nearest;

## sets whether or not the standard tixanchor is displayed or
## not. It's a method so that it will behave more dynamically (RCS)

sub showactive {
  my ($w, $value) = @_;
  return $w->{Configure}{-showactive} unless defined $value;

  my $ent = $w->infoActive;
  if ($value eq "0") {
     $w->WidgetMethod('anchor', 'clear') if defined($ent);

  } else {
    $w->WidgetMethod('anchor', 'set', $ent) if
      defined($ent) && $w->focusCurrent eq $w;
  }
}

############################################################
## Private methods
############################################################

## This routine combines a check for disabled state, and 
## hidden site, and further checks to see if an entry is
## not visible only because it's parent is. (RCS)

sub _isHiddenOrDisabled {
  my ($w, $ent) = @_;
  return 1 
    if (($w->entrycget($ent, '-state') eq 'disabled') ||
        ($w->infoHidden($ent)) ||
        ($w->_parentHidden($ent)));
  return 0;
}

## This method is used to fix a bug reported 
## by Andrew Leppard (aleppard@austrics.com.au) in 
## thread "Bug in Tk::Tree?" where the UpDown was
## incorrectly moving the cursor to child elements,
## that, while not set to hidden themselves, were
## not visible because their parent was hidden. This
## method checks to see if their parent (or parent's
## parent) is hidden. (RCS)

sub _parentHidden {
    my ($w, $ent) = @_;
    my $hidden = 0;
    my $parent = $w->infoParent($ent) || ""; 
    while ($hidden == 0 && $parent ne "") {
        $hidden = 1 if $w->infoHidden($parent);
        $parent = $w->infoParent($parent) || "";
    } 
    return $hidden;
}

############################################################
## Event Handlers (in alphabetical order)
############################################################

sub AutoScan {
  my ($w,$x,$y) = @_;

  return if ($w->cget('-selectmode') eq 'dragdrop');

  if (@_ < 3) {
    my $Ev = $w->XEvent;
    return unless defined $Ev;
    $y = $Ev->y;
    $x = $Ev->x;
  }

  if($y >= $w->height) {
    $w->yview('scroll', 1, 'units');
 
  } elsif($y < 0) {
    $w->yview('scroll', -1, 'units');

  } elsif($x >= $w->width) {
    $w->xview('scroll', 2, 'units');

  } elsif($x < 0) {
    $w->xview('scroll', -2, 'units');

  } else {
    return;
  }
  $w->RepeatId($w->SUPER::after(50,[ AutoScan => $w, $x, $y ]));
  $w->Button1Motion;
}

sub B1_Enter {
  my $w = shift;
  $w->CancelRepeat
    if($w->cget('-selectmode') ne 'dragdrop');
}

sub Button1 {
  my $w = shift;

  my $Ev = $w->XEvent;
  my $ent = $w->nearest($Ev->y, 1);
  my $browsecmd = 1;

  ## Ignore selections that are not entries
  return if (!defined($ent) && !length($ent));

  delete $w->{tixindicator};

  $w->anchorClear if ($w->infoAnchor);

  my $mode = $w->cget('-selectmode');

  ## Ignore Drag and Drop 
  if ($mode eq 'dragdrop') {
    # $w->Send_WaitDrag($Ev->y);
    return;
  }

  my @info = $w->infoItem($Ev->x, $Ev->y);
  if (@info) { 
    die 'Assert' unless $info[0] eq $ent;
  } else {
    @info = $ent;
  }
  if (defined($info[1]) && $info[1] eq 'indicator') {
    $w->{tixindicator} = $ent;
    $w->Callback(-indicatorcmd => $ent, '<Arm>');
    $w->focus() if($w->cget('-takefocus'));
    $browsecmd = 0;
  }

  ## For Button1, multiple mode toggles selection of
  ## current entry only. All other modes clear everything
  ## and then select the current entry.

  if ($mode eq 'multiple') {

    if ($w->selectionIncludes($ent)) {

      ## I was wrestling with putting code in so that browsecmd would not 
      ## be called when deselecting an entry, but decided against it for
      ## now. It's easy to trap this in a browsecmd subroutine if desired
      $w->selectionClear($ent);

    } else {
      $w->selectionSet($ent);
    }

  } else {
    $w->selectionClear;
    $w->selectionSet($ent);
    $w->anchorSet($ent);
    $w->{m_selection} = [];
    $w->{m_prev} = $ent;
  }
  $w->focus() if($w->cget('-takefocus'));

  ## One could argue that browsecmd only be called for <ButtonRelease> 
  ## That's one approach. The important thing here is that it only be
  ## called once either for ButtonPress or Release, and doing so for
  ## release requires a bit of extra work because of <Motion-1>. I think 
  ## that -browsecmd works better when triggered by ButtonPress, since 
  ## for browse and extended it will be called while the button is 
  ## pressed and dragging - not while when button is released. It seems 
  ## more consistant internally not to trigger it on release. (RCS)
  $w->Callback(-browsecmd => @info) if $browsecmd;
}

sub ButtonRelease_1 {
  my $w = shift;
  my $Ev = $w->XEvent;
  my ($x, $y) = ($Ev->x, $Ev->y);

  my $ent = $w->nearest($y); 
  my $mode = $w->cget('-selectmode');

  $w->CancelRepeat if($mode ne 'dragdrop');
  
  if ($mode eq 'dragdrop') {
#   $w->Send_DoneDrag();
    return;
  }

  if (exists $w->{tixindicator}) {
    return unless delete($w->{tixindicator}) eq $ent;
    my @info = $w->infoItem($x, $y);
    if(defined($info[1]) && $info[1] eq 'indicator') {
      $w->Callback(-indicatorcmd => $ent, '<Activate>');
    }
  }

  if (defined($ent)) {
    $w->activeSet($ent);
  }
}

## Modified to behave a bit more like listbox, using some
## Listbox code - the structure is borrowed from Listbox. The 
## old method treated single mode like browse and vice versa and 
## treated multiple and extended more or less the same (RCS)

sub Button1Motion {
  my $w = shift;
  my $Ev = $w->XEvent;

  my $curr;                ## current hlist entrypath
  my $prev = $w->{m_prev}; ## previous entry
  my $browseExtended = 0;  ## if 1, call browsecmd at the end

  my $anchor = $w->infoAnchor;
  my $mode = $w->cget('-selectmode');
  $browseExtended = 1 if
    ($mode =~ /^(browse|extended)/);

  ## Ignore Drag and Drop
  if ($mode eq 'dragdrop') {
    # $w->Send_StartDrag();
    return;
  }

  if (defined $anchor) {
    $curr = $w->nearest($Ev->y);

  } else {
    $curr = $w->nearest($Ev->y, 1);
  }

  ## Do not perform motion on non-entries
  return unless (defined($curr) && length($curr) > 0);

  ## Do not repeat while moving within the same entry (important!)
  if (defined($prev) && $curr eq $prev) {
    return;
  }

  if ($mode eq 'browse') {
    $w->selectionClear;
    $w->selectionSet($curr);
    $w->{m_prev} = $curr;

  } elsif ($mode eq 'extended') {

    if (defined($anchor) && defined($prev)) {

      if ($w->selectionIncludes($anchor)) {
        $w->selectionClear($prev, $curr);
        $w->selectionSet($anchor, $curr);

      } else {
        $w->selectionClear($prev, $curr);
        $w->selectionClear($anchor, $curr);
      }
    }

    ## Brute force approach to ensuring all previously
    ## selected entries aren't deselected - I'm certain
    ## a more efficient way can be found, I tried doing
    ## it one at a time using a hash, but inevitably missed 
    ## some if I was moving the mouse quickly.
    for (@{$w->{m_selection}}) {
      $w->selectionSet($_);
    }
    $w->{m_prev} = $curr;
  }
  if ($browseExtended) {
    $w->Callback(-browsecmd => $curr);
  }
}

sub CtrlButton1 {
  my $w = shift;
  my $Ev = $w->XEvent;
  my $ent = $w->nearest($Ev->y, 1);
  $w->anchorClear if $w->infoAnchor;

  return unless (defined($ent) and length($ent));

  if ($w->cget('-selectmode') eq 'extended') {

    my @sel = $w->infoSelection;
    $w->{m_selection} = \@sel;

    $w->{m_prev} = $ent;
    $w->anchorSet($ent);

    if ($w->selectionIncludes($ent)) {
      $w->selectionClear($ent);

    } else {
      $w->selectionSet($ent);
    }
  }
}


sub CtrlHome {
  my $w = shift;
  $w->selectionClear;
  $w->activeClear;
  $w->UpDown("next");
  $w->selectionSet($w->infoActive());
}

sub CtrlEnd {
  my $w = shift;
  my @c = $w->infoChildren;
  my $last = $c[$#c] || '';
  return unless (defined($last) && $last ne '');
  $w->anchorSet($last);
  $w->activeSet($last);
  $w->see($last);
  $w->selectionClear;
  $w->selectionSet($last);
}

sub Double1 {
  my $w = shift;
  my $Ev = $w->XEvent;
  $w->activeClear;

  my $ent = $w->nearest($Ev->y, 1);
  return unless (defined($ent) and length($ent));

  $w->activeSet($ent);
  $w->anchorSet($ent);
  $w->selectionSet($ent);
  $w->Callback(-command => $ent) if ($w->cget(-command));
}


## Show the ugly anchor, if it's enabled when focus
## is on widget. Custom anchor method preserves
## anchor position

sub FocusIn {
  my $w = shift;
  my $ent = $w->infoActive();
  if (defined($ent) && length($ent)) {
    $w->WidgetMethod('anchor', 'set', $ent) if $w->cget('-showactive');
  }
}

## Hide the ugly anchor if focus leaves the widget.
## Custom anchor method preserves anchor position

sub FocusOut {
  my $w = shift;
  if (defined($w->infoActive()) && $w->cget('-showactive')) {
    $w->WidgetMethod('anchor', 'clear');
  }
}

## Keyboard equivalent of a Double Button Press
sub KeyboardActivate {
  my $w = shift;
  my $active = $w->infoActive;
  return unless (defined($active) and length($active));

  if($w->cget('-selectmode')) {
    $w->selectionClear;
    $w->selectionSet($active);
  }
  $w->Callback(-command => $active);
}

## Keyboard equivalent of Button1 (Press)
sub KeyboardSelect {
  my $w = shift;
  my $ent = $w->infoActive;

  return unless (defined($ent) and length($ent));

  if ($w->indicatorExists($ent)) {
    $w->Callback(-indicatorcmd => $ent, '<Activate>');
  }

  if ($w->cget('-selectmode') eq 'multiple') {

    if ($w->selectionIncludes($ent)) {
      $w->selectionClear($ent);
    } else {
      $w->selectionSet($ent);
    }

  ## The only two modes that need to set an entry are
  ## multiple and single. browse and extended both 
  ## select an entry automatically, but it doesn't hurt 
  ## to set the entry  again.  
  } else {
     $w->selectionClear;
     $w->selectionSet($ent);
  }
  $w->Callback(-browsecmd => $ent);
}

sub SelectAll {
  my $w = shift;
  my $mode = $w->cget('-selectmode');
  if ($mode eq 'single' || $mode eq 'browse') {
    $w->selectionClear;
    my $ent = $w->infoActive;
    $w->selectionSet($ent) if defined($ent);

  } else {
    my @children = $w->infoChildren();
    $w->selectionSet($children[0], $children[$#children])
  }
}

sub SelectNone { 
  my $w = shift;
  $w->selectionClear if $w->cget('-selectmode') ne 'single';
}


sub ShiftButton1 {
  my $w = shift;
  my $Ev = $w->XEvent;
  my $to = $w->nearest($Ev->y, 1);

  delete $w->{tixindicator};
  return unless (defined($to) and length($to));

  if($w->cget('-selectmode') eq 'extended') {    
    my $from = $w->infoAnchor();

    if(defined $from) {
      $w->selectionClear;
      $w->selectionSet($from, $to);

    } else {
      $w->anchorSet($to);
      $w->selectionClear;
      $w->selectionSet($to);
    }
    $w->{m_prev} = $to;
  }
}

## Somewhat different than UpDown, this method makes
## use of the m_shiftanchor as a substitute for the
## regular anchor. This is so that the regular anchor
## can be used like an "active" Listbox element.

sub ShiftUpDown {
  my $w = shift;
  my $spec = shift;

  return 
    unless $w->cget('-selectmode') eq "extended";
 
  my $active = $w->infoActive;
  return $w->UpDown($spec) 
    unless (defined($active) and length($active));

  $w->anchorSet($active) unless defined ($w->infoAnchor());
  my $anchor = $w->infoAnchor();
  my $ent = $active;

  while(1) {
    $ent = $w->info($spec, $ent);
    last unless( defined $ent );
    next if ($w->_isHiddenOrDisabled($ent));
    last;
  }

  ## Not quite sure why this is necessary, but left it in
  ## for now
  unless( $ent ) {
    $w->yview('scroll', $spec eq 'prev' ? -1 : 1, 'unit');
    return;
  }

  $w->selectionClear;
  $w->selectionSet($anchor, $ent);
  $w->see($ent);
  $w->activeSet($ent);
  $w->Callback(-browsecmd =>$ent) if $w->cget('-browsecmd');
}

sub UpDown {
  my $w = shift;
  my $spec = shift;              ## next(down)/prev(up)
  my $from = $w->infoActive;     ## start
  my $to;                        ## destination 
  my $done = 0;

  ## starting position is undefined, the search will be for
  ## a place to start from, beginning at the top of the list.
  ## If the first element is good, then the search will be 
  ## unecessary

  if (! defined $from ) {
    $from = ($w->infoChildren)[0] || '';
    return unless (defined($from) and length($from));

    if ($w->_isHiddenOrDisabled($from)) {
      $spec = "next"

    } else {
      $done = 1;
    }
  }
  $to = $from;
  
  ## if not finished finding a place to jump to
  ## then move in one direction until a suitable
  ## element is found 
  while( !$done ) {
    $to = $w->info($spec, $to);
    last unless( defined $to );             ## End of the list
    next if ($w->_isHiddenOrDisabled($to)); ## Unsuitable position
    last;
  }

  unless( defined $to ) {
    $w->yview('scroll', $spec eq 'prev' ? -1 : 1, 'unit');
    return;
  }
  $w->anchorSet($to);
  $w->activeSet($to);
  $w->see($to);

  if ($w->cget('-selectmode') =~ /^(browse|extended)/ ) {
    $w->selectionClear;
    $w->selectionSet($to);
    $w->{m_prev} = $to;
    $w->{m_selection} = [];
    $w->Callback(-browsecmd => $to) if ($w->cget('-browsecmd'));
  }
}

1;

__END__
