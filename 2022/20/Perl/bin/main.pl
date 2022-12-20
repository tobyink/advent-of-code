#!perl

use v5.24;
use warnings;
use List::Util qw( min sum first );

use constant FILENAME => $ENV{ADVENT_INPUT};

use constant {
	VALUE      => 0,
	ORIG_INDEX => 1,
	CURR_INDEX => 2,
};

sub read_numbers {
	local @ARGV = shift;
	my $ix = -1;
	map {
		chomp( my $n = $_ );
		++$ix;
		length $n or die;
		[ $n, $ix, $ix ];
	} <>;
}

sub dump_numbers         { join q{, },  map $_->[VALUE],                 @_ }
sub dump_numbers_verbose { join qq{\n}, map sprintf('%d [%d->%d]', @$_), @_ }

sub mix_number {
	my ( $n, $all ) = @_;
	my ( $min, $max ) = move_places( $n->[CURR_INDEX], $n->[VALUE] || return, $all );
	# The move breaks CURR_INDEX for a range of the array. Luckily,
	# move_places returns the indices for that range. :)
	for my $ix ( $min .. $max ) {
		$all->[$ix][CURR_INDEX] = $ix;
	}
}

sub move_places {
	my ( $index, $places, $array ) = @_;
	my $temp_size = @$array - 1;

	# Shortcut
	return ( $index, $index ) if $places % $temp_size == 0;

	# Remove value from array, in the process shrinking it to temp_size
	my ( $value ) = splice( @$array, $index, 1 );

	# Insert the value into its new location.
	my $new_index = ( $index + $places ) % $temp_size;
	splice( @$array, $new_index, 0, $value );

	# Return range of affected elements.
	sort { $a <=> $b } $index, $new_index;
}


sub find_number {
	my ( $test, $value, $all ) = @_;
	return first { $_->[$test] == $value } @$all;
}

sub coords {
	my ( $all ) = @_;

	my @indices = ( 1000, 2000, 3000 );

	my $zero = find_number VALUE, 0, $all;
	return map {
		my $index = $zero->[CURR_INDEX] + $_;
		$all->[ $index % @$all ];
	} @indices;
}

sub inflate_values {
	my ( $multiplier, $all ) = @_;
	$_->[VALUE] *= $multiplier for @$all;
}

PART1: {
	my @numbers = read_numbers( FILENAME );
	my @orig_order = @numbers;
	for my $number ( @orig_order ) {
		mix_number $number, \@numbers;
	}
	my @found = coords \@numbers;
	say "PART1: ", sum map $_->[VALUE], @found;
};

PART2: {
	my @numbers = read_numbers( FILENAME );
	my @orig_order = @numbers;
	inflate_values 811589153, \@numbers;
	for my $r ( 1 .. 10 ) {
		for my $number ( @orig_order ) {
			mix_number $number, \@numbers;
		}
	}
	my @found = coords \@numbers;
	say "PART2: ", sum map $_->[VALUE], @found;
};
