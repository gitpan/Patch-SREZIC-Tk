# -*- perl -*-

#
# $Id: XDNDSite.pm,v 1.5 2001/11/18 10:07:49 eserte Exp $
# Author: Slaven Rezic
#
# This is a patch against the original Tk/DragDrop/XDNDSite.pm. Please consult
# the Perl/Tk documentation and/or sources for copyrights.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

package Patch::SREZIC::Tk::DragDrop::XDNDSite;

use Tk::DropSite;
use Tk::DragDrop::XDNDSite;
package
    Tk::DragDrop::XDNDSite;

sub XdndPosition
{
 my ($t,$sites) = @_;
 my $event = $t->XEvent;
 my ($src,$flags,$xy,$time,$action) = unpack('LLLLL',$event->A);
 my $X = $xy >> 16;
 my $Y = $xy & 0xFFFF;
 my $info = $t->{"XDND$src"};
 $info->{X}      = $X;
 $info->{Y}      = $Y;
 $info->{action} = $action;
 $info->{t}      = $time;
 my($wrapper) = $t->toplevel->wrapper;
 my $id    = $wrapper; #oct($t->id);
 my $sxy   = 0; 
 my $swh   = 0; 
 my $sflags = 0;
 my $saction = 0;
 my $over = $info->{site};
 foreach my $site (@$sites)
  {
   if ($site->Over($X,$Y))
    {
     $sxy = ($site->X << 16)     | $site->Y;    
     $swh = ($site->width << 16) | $site->height;
     $saction = $action;                        
     $sflags |= 1;                              
     if ($over)                                 
      {                                         
       if ($over == $site)                      
        {                                       
         $site->Apply(-motioncommand => $X, $Y);
        }                                       
       else                                     
        {                                       
         $over->Apply(-entercommand => $X, $Y, 0);
         $site->Apply(-entercommand => $X, $Y, 1);
        }                                       
      }                                         
     else                                       
      {                                         
       $site->Apply(-entercommand => $X, $Y, 1);
      }     
     $info->{site} = $site;                     
     last;
    }
  }
 unless ($sflags & 1)
  {
   if ($over)
    {
     $over->Apply(-entercommand => $X, $Y, 0) 
    }
   delete $info->{site};
  }
 my $data = pack('LLLLL',$id,$sflags,$sxy,$swh,$action);
 $t->SendClientMessage('XdndStatus',$src,32,$data);
}

sub XdndDrop
{
 my ($t,$sites) = @_;
 my $event = $t->XEvent;
 my ($src,$flags,$time,$res1,$res2) = unpack('LLLLL',$event->A);
 my $info   = $t->{"XDND$src"};        
 my $sflags = 0;
 if ($info)
  {         
   $info->{t} = $time;
   my $site = $info->{'site'};
   if ($site)
    {
     my $X = $info->{'X'};                  
     my $Y = $info->{'Y'};                  
     $site->Apply(-dropcommand => $Y, $Y, 'XdndSelection');
     $site->Apply(-entercommand => $X, $Y, 0);
    }
  }
 my($wrapper) = $t->toplevel->wrapper;
 my $data  = pack('LLLLL',$wrapper,$sflags,0,0,0);
 $t->SendClientMessage('XdndFinished',$src,32,$data);
}

sub NoteSites
{my ($class,$t,$sites) = @_;
 if (@$sites)
  {
   $t->BindClientMessage('XdndLeave',[\&XdndLeave,$sites]);
   $t->BindClientMessage('XdndEnter',[\&XdndEnter,$sites]);
   $t->BindClientMessage('XdndPosition',[\&XdndPosition,$sites]);
   $t->BindClientMessage('XdndDrop',[\&XdndDrop,$sites]);
   my($wrapper) = $t->toplevel->wrapper;
   $t->property('set','XdndAware','ATOM',32,[3],$wrapper);
  }
 else
  {
   #XXX ??? $t->property('delete','XdndAware');
  }
}

1;

__END__

notes on perl/Tk and Xdnd v3 interaction:
- the XdndAware property has to be in the wrapper window
  this also means that it's not easy to delete the xdndaware property,
  because it should only go away if there is no xdnd site in the
  system
- gnome mc seams to want the wrapper id in the XdndStatus message, not
  the site id
- the resulting selection is somewhat difficult to handle. konqueror
  seams to generate a STRING type (?), while gnome mc generates only
  text/uri-list, text/plain and such. These are returned as lists of
  integers instead of strings.

