#!perl

use v5.16;
use warnings;
use constant FILENAME => $ENV{ADVENT_INPUT};

my $i = 0;
my %priorities = map { $_ => ++$i } 'a'..'z', 'A'..'Z';

PART1: {
	local @ARGV = FILENAME;
	my $total = 0;
	while ( <> ) {
		chomp;
		my @parts = ( substr( $_, 0, length()/2 ), substr( $_, length()/2 ) );
		my $re = qr/[^$parts[1]]/;
		$total += $priorities{ substr( $parts[0] =~ s/$re//gr, 0, 1 ) };
	}
	say "PART1: $total";
}

PART2: {
	local @ARGV = FILENAME;
	my $total = 0;
	while () {
		chomp( my $e1 = <> // last );
		chomp( my $e2 = <> );
		chomp( my $e3 = <> );
		for my $letter ( 'a'..'z', 'A'..'Z' ) {
			next unless (
				index( $e1, $letter ) >= 0 and
				index( $e2, $letter ) >= 0 and
				index( $e3, $letter ) >= 0
			);
			$total += $priorities{$letter};
		}
	}
	say "PART2: $total";
}
