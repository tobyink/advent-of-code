#!perl
use v5.24;
use warnings;

use Instruction;
use Machine;

use constant FILENAME => $ENV{ADVENT_INPUT};

PART_1: {
	my $total = 0;
	my $machine = Machine->new->load_instructions( FILENAME );
	$machine->register->{x} = 1;
	$machine->run( sub {
		my ( $machine, $instruction, $cycle_number ) = @_;
		if ( 0 == ($cycle_number+20) % 40 ) {
			$total += $cycle_number * $machine->register->{x};
		}
	} );
	say "PART1: $total\n";
}

# There are some bugs in the final column of the output, but it's readable.
PART_2: {
	my @pixels = ( '.' ) x 40;
	my $machine = Machine->new->load_instructions( FILENAME  );
	$machine->register->{x} = 1;
	$machine->run( sub {
		my ( $machine, $instruction, $cycle_number ) = @_;
		my $x = $machine->register->{x};
		$cycle_number %= 40;
		if ( $cycle_number == 0 ) {
			say join '', @pixels;
			@pixels = ( '.' ) x 40;
		}
		my %sprite = map +( $_ => 1 ), $x .. $x+2;
		$pixels[$cycle_number-1] = $sprite{$cycle_number} ? '#' : '.';
	} );
}
