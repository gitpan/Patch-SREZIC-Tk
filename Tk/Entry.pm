# -*- perl -*-

#
# $Id: Entry.pm,v 1.2 2001/11/18 10:07:45 eserte Exp $
# Author: Slaven Rezic
#
# This is a patch against the original Tk/Entry.pm. Please consult
# the Perl/Tk documentation and/or sources for copyrights.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

package Patch::SREZIC::Tk::Entry;

use Tk::Entry;
package
    Tk::Entry;

Tk::Methods('validate');

1;

__END__
