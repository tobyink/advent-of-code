#!perl

use v5.14;
use warnings;

my @calories = do {
	local @ARGV = 'input.txt';
	my ( $i, @data ) = 0;
	while ( <> ) {
		chomp;
		/[0-9]/ ? ( $data[$i] += $_ ) : ++$i;
	}
	@data;
};

my @sorted =
	sort { $b->[1] <=> $a->[1] }
	map { [ $_, $calories[$_] ] }
	0 .. $#calories;

printf( "Elf %d has %d calories.\n", $sorted[0][0], $sorted[0][1] );

my $total = 0;
$total += $sorted[$_][1] for 0..2;
printf( "The top three elves have %d calories total.\n", $total );
