# -*- perl -*-

#
# $Id: Listbox.pm,v 1.4 2002/03/02 21:37:59 eserte Exp $
# Author: Slaven Rezic
#
# This is a patch against the original Tk/Listbox.pm. Please consult
# the Perl/Tk documentation and/or sources for copyrights.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

package Patch::SREZIC::Tk::Listbox;

use Tk::Listbox;
package
    Tk::Listbox;

sub ClassInit
{
 my ($class,$mw) = @_;
 $class->SUPER::ClassInit($mw);
 # Standard Motif bindings:
 $mw->bind($class,'<1>',['BeginSelect',Ev('index',Ev('@'))]);
 $mw->bind($class,'<B1-Motion>',['Motion',Ev('index',Ev('@'))]);
 $mw->bind($class,'<ButtonRelease-1>','ButtonRelease_1');
 ;
 $mw->bind($class,'<Shift-1>',['BeginExtend',Ev('index',Ev('@'))]);
 $mw->bind($class,'<Control-1>',['BeginToggle',Ev('index',Ev('@'))]);

 $mw->bind($class,'<B1-Leave>',['AutoScan',Ev('x'),Ev('y')]);
 $mw->bind($class,'<B1-Enter>','CancelRepeat');
 $mw->bind($class,'<Up>',['UpDown',-1]);
 $mw->bind($class,'<Shift-Up>',['ExtendUpDown',-1]);
 $mw->bind($class,'<Down>',['UpDown',1]);
 $mw->bind($class,'<Shift-Down>',['ExtendUpDown',1]);

 $mw->XscrollBind($class);
 $mw->bind($class,'<Next>',  sub {
	       my $w = shift;
	       $w->yview('scroll',1,'pages');
	       $w->activate('@0,0');
	   });
 $mw->bind($class,'<Prior>', sub {
	       my $w = shift;
	       $w->yview('scroll',-1,'pages');
	       $w->activate('@0,0');
	   });
 $mw->MouseWheelBind($class);

 $mw->bind($class,'<Control-Home>','Cntrl_Home');
 ;
 $mw->bind($class,'<Shift-Control-Home>',['DataExtend',0]);
 $mw->bind($class,'<Control-End>','Cntrl_End');
 ;
 $mw->bind($class,'<Shift-Control-End>',['DataExtend','end']);
 # $class->clipboardOperations($mw,'Copy');
 $mw->bind($class,'<space>',['BeginSelect',Ev('index','active')]);
 $mw->bind($class,'<Select>',['BeginSelect',Ev('index','active')]);
 $mw->bind($class,'<Control-Shift-space>',['BeginExtend',Ev('index','active')]);
 $mw->bind($class,'<Shift-Select>',['BeginExtend',Ev('index','active')]);
 $mw->bind($class,'<Escape>','Cancel');
 $mw->bind($class,'<Control-slash>','SelectAll');
 $mw->bind($class,'<Control-backslash>','Cntrl_backslash');
 ;
 # Additional Tk bindings that aren't part of the Motif look and feel:
 $mw->bind($class,'<2>',['scan','mark',Ev('x'),Ev('y')]);
 $mw->bind($class,'<B2-Motion>',['scan','dragto',Ev('x'),Ev('y')]);
 return $class;
}

sub BalloonInfo
{
 my ($listbox,$balloon,$X,$Y,@opt) = @_;
 my $e = $listbox->XEvent;
 return if !$e;
 my $index = $listbox->index('@' . $e->x . ',' . $e->y);
 foreach my $opt (@opt)
  {
   my $info = $balloon->GetOption($opt,$listbox);
   if ($opt =~ /^-(statusmsg|balloonmsg)$/ && UNIVERSAL::isa($info,'ARRAY'))
    {
     $balloon->Subclient($index);
     if (defined $info->[$index])
      {
       return $info->[$index];
      }
     return '';
    }
   return $info;
  }
}

1;

__END__
