--- Tk800.023/demos/demos/widget_lib/menus.pl	Tue Jul 27 20:20:16 1999
+++ new.Tk800.023/demos/demos/widget_lib/menus.pl	Tue Nov 27 01:23:21 2001
@@ -159,8 +159,10 @@
     $menubar->bind('<<MenuSelect>>' => sub {
 	my $label = undef;
 	my $w = $Tk::event->W;
-	$label = $w->entrycget('active', -label);
-	$status_bar = $label;
+	eval {local $SIG{__DIE__};
+	      $label = $w->entrycget('active', -label);
+	      $status_bar = $label;
+	};
 	$TOP->idletasks;
     });
 
