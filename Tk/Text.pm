# -*- perl -*-

#
# $Id: Text.pm,v 1.2 2002/01/30 18:51:10 eserte Exp $
# Author: Slaven Rezic
#
# This is a patch against the original Tk/Text.pm. Please consult
# the Perl/Tk documentation and/or sources for copyrights.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

package Patch::SREZIC::Tk::Text;

use Tk::Text;
package
    Tk::Text;

sub findandreplacepopup{my($w,$find_only)=@_;
my$pop=$w->Toplevel;
if($find_only){$pop->title("Find");}else{$pop->title("Find and/or Replace");}my$frame=$pop->Frame->pack(-anchor=>'nw');
$frame->Label(text=>"Direction:")->grid(-row=>1,-column=>1,-padx=>20,-sticky=>'nw');
my$direction='-forward';
$frame->Radiobutton(variable=>\$direction,text=>'-forward',value=>'-forward')->grid(-row=>2,-column=>1,-padx=>20,-sticky=>'nw');
$frame->Radiobutton(variable=>\$direction,text=>'-backward',value=>'-backward')->grid(-row=>3,-column=>1,-padx=>20,-sticky=>'nw');
$frame->Label(text=>"Mode:")->grid(-row=>1,-column=>2,-padx=>20,-sticky=>'nw');
my$mode='-exact';
$frame->Radiobutton(variable=>\$mode,text=>'-exact',value=>'-exact')->grid(-row=>2,-column=>2,-padx=>20,-sticky=>'nw');
$frame->Radiobutton(variable=>\$mode,text=>'-regexp',value=>'-regexp')->grid(-row=>3,-column=>2,-padx=>20,-sticky=>'nw');
$frame->Label(text=>"Case:")->grid(-row=>1,-column=>3,-padx=>20,-sticky=>'nw');
my$case='-case';
$frame->Radiobutton(variable=>\$case,text=>'-case',value=>'-case')->grid(-row=>2,-column=>3,-padx=>20,-sticky=>'nw');
$frame->Radiobutton(variable=>\$case,text=>'-nocase',value=>'-nocase')->grid(-row=>3,-column=>3,-padx=>20,-sticky=>'nw');
my$find_entry=$pop->Entry(width=>25);
my$button_find=$pop->Button(text=>'Find',command=>sub{$w->FindNext($direction,$mode,$case,$find_entry->get()),})->pack(-anchor=>'nw');
$find_entry->pack(-anchor=>'nw','-expand'=>'yes',-fill=>'x');
my@ranges=$w->tagRanges('sel');
if(@ranges){my$first=shift(@ranges);
my$last=shift(@ranges);
my($first_line,$first_col)=split(/\./,$first);
my($last_line,$last_col)=split(/\./,$last);
unless($first_line==$last_line){$last=$first.' lineend';}$find_entry->insert('insert',$w->get($first,$last));}else{my$selected;
eval{$selected=$w->SelectionGet(-selection=>"PRIMARY");};
if($@){}elsif(defined($selected)){$find_entry->insert('insert',$selected);}}my($replace_entry,$button_replace,$button_replace_all);
unless($find_only){$replace_entry=$pop->Entry(width=>25);
$button_replace=$pop->Button(text=>'Replace',command=>sub{$w->ReplaceSelectionsWith($replace_entry->get());})->pack(-anchor=>'nw');
$replace_entry->pack(-anchor=>'nw','-expand'=>'yes',-fill=>'x');}$pop->Label(text=>" ")->pack();
unless($find_only){$button_replace_all=$pop->Button(text=>'Replace All',command=>sub{$w->FindAndReplaceAll($mode,$case,$find_entry->get(),$replace_entry->get());})->pack(-side=>'left');}my$button_find_all=$pop->Button(text=>'Find All',command=>sub{$w->FindAll($mode,$case,$find_entry->get());})->pack(-side=>'left');
my$button_cancel=$pop->Button(text=>'Cancel',command=>sub{$pop->destroy()})->pack(-side=>'left');
$pop->resizable('yes','no');
return$pop;}

1;

__END__
