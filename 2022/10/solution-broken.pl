#!perl
use v5.24;
use warnings;
use List::Util qw(sum);

my @X = ( 0, 1 );
local @ARGV = 'input-test.txt';
while ( <> ) {
	chomp;
	if ( /^noop$/ ) {
		push @X, $X[-1];
	}
	elsif ( /^addx (.+)$/ ) {
		my $n = $1;
		push @X, $X[-1], $X[-1] + $n;
	}
}

# Part 1
my $total = sum map {
	my $cycle_n = 40 * $_ - 20;
	$cycle_n * $X[$cycle_n]
} 1 .. 6;
say "Sum of six strengths: $total";

# Part 2
my @pixels = ( '.' ) x 240;
for my $cycle ( 1..240 ) {
	my $x = $X[$cycle];
	my %sprite; $sprite{$_} = 1 for $x-1..$x+1;
	$pixels[$cycle] = '#' if $sprite{$cycle};
}
say join( '', @pixels[ $_*40 .. $_*40+39 ] ) for 0..5;
