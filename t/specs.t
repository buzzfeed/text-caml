use strict;
use warnings;

use File::Path qw(make_path remove_tree);
use FindBin '$Bin';
use Test::More tests => 124;
use Text::Caml;
use YAML::Syck;

my $PARTS_DIR = "$Bin/partials/";
my $engine = Text::Caml->new;

sub startup {
	my $filename = shift;

	# remove partials directory
	&shutdown($filename);

	# create partials directory
	unless ( make_path($PARTS_DIR) ) {
		die "Can't create [$PARTS_DIR] for [$filename]";
	}

	$engine->set_templates_path( $PARTS_DIR );
}

sub setup {
	my $t = shift;

	# create and fill the partials files
	foreach my $k ( keys %{ $t->{partials} } ) {
		my $parts_filename = $PARTS_DIR . $k;

		open my $fh, '>', $parts_filename
			or die "Can't create [$parts_filename]";
		print $fh $t->{partials}->{$k};
		close $fh;
	}
}

sub teardown { }

sub shutdown {
	my $filename = shift;

	# remove partials directory
	remove_tree($PARTS_DIR, { error => \my $err_list } );

	if ( scalar(@{$err_list}) ) {
		die "Can't remove [$PARTS_DIR] for [$filename]";
	}
}

while ( my $filename = <$Bin/../ext/spec/specs/*.yml> ) {
	startup($filename);

	my $spec  = LoadFile($filename);
	my $tests = $spec->{tests};

	note "\n---------\n$spec->{overview}";

	foreach my $t ( @{$tests} ) {
		setup($t);

		$t->{signature} = "$t->{name}\n$t->{desc}\n";
		my $out = '';

		eval {
			$out = $engine->render( $t->{template}, $t->{data} );
		};
		if ( $@ ) {
			fail( $t->{signature} . "ERROR: $@" );
		}
		else {
			is $out => $t->{expected}, $t->{signature};
		}

		teardown($t);
	}

	&shutdown($filename);
}
