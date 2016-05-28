# revok
package window;

use strict;
use Plugins;

# Register plugin
Plugins::register("window", "kore windows management", \&on_unload, \&on_reload);
my $commands_hooks = Commands::register(
	['min', 'minimize kore window', \&w_manage],
	['max', 'restore kore window', \&w_manage]
);

my $hw; # global
get_hw(); # avoid that small delay later.

sub get_hw {
	if (!$hw){
		require Win32::API;
		my $gct = new Win32::API('kernel32', 'GetConsoleTitle', 'PN', 'N');
		my $sct = new Win32::API('kernel32', 'SetConsoleTitle', 'P',  'N');
		my $fw  = new Win32::API('user32',   'FindWindow',      'PP', 'N');
		my $bkpt = " " x 1024;
		$gct->Call($bkpt, 1024);
		my $ttitle = time-rand(999);
		$sct->Call($ttitle);
		sleep(0.5);
		$hw = $fw->Call(0, $ttitle);
		$sct->Call($bkpt);
	}
	return $hw;
}

sub w_manage {
	require Win32::API;
	use constant SW_HIDE       	=> 0;
	use constant SW_SHOWNORMAL 	=> 1;
	use constant SW_MINIMIZE 	=> 6;
	my $ShowWindow      = new Win32::API('user32',   'ShowWindow',      'NN', 'N');
	$ShowWindow->Call(get_hw, 
		{
			'min' => SW_MINIMIZE,
			'max' => SW_SHOWNORMAL
		}->{$_[0]}
	);
}

sub on_unload {
	Commands::unregister($commands_hooks);
	undef $commands_hooks;
}

sub on_reload {
	&on_unload;
}

1;