#!perl

use v5.24;
use warnings;
use constant {
	FILENAME => 'input-test.txt',
	DEBUG    => !!0,
	PART_ONE => !!1,
	PART_TWO => !!1,
};
use experimental qw( signatures );
use match::simple qw( match );
use List::Util qw( min );
use Memoize qw( memoize flush_cache );
use utf8;

binmode( STDOUT, ':utf8' );

# Read valve info from file.
open my $fh, '<', FILENAME;
my @valves = map {
	/^Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.+)$/
		or die "Bad line: $_";
	{
		name  => $1,
		rate  => $2,
		paths => [ split /,\s+/, $3 ],
	};
} <$fh>;
my %valves = map +( $_->{name} => $_ ), @valves;

# Calculate distances between paths.
my %distance;
for my $valve ( @valves ) {
	$distance{ join ':', $valve->{name}, $_ } = 1 for $valve->{paths}->@*;
}
for my $i ( keys %valves ) {
	for my $j ( keys %valves ) {
		for my $k ( keys %valves ) {
			defined ( my $x = $distance{"$j:$i"} ) or next;
			defined ( my $y = $distance{"$i:$k"} ) or next;
			next if $j eq $k;
			$distance{"$j:$k"} = min(
				$x + $y,
				$distance{"$j:$k"} // 999_999_999,
			);
		}
	}
}

my @interesting = map $_->{name}, grep $_->{rate} > 0, @valves;

sub paths_from ( $name, $minutes_left, @been_to ) {
	my @next_been_to = sort( $name, @been_to );
	my @outward_paths =
		map {
			[ $name, $_->@* ];
		}
		map {
			my $dest = $_;
			my $time = $minutes_left - $distance{"$name:$dest"};
			$time-- if match $name, \@interesting;
			paths_from( $dest, $time, @next_been_to );
		}
		grep {
			my $dest = $_;
			$distance{"$name:$dest"} < $minutes_left
				and not match $dest, \@been_to;
		}
		grep $_ ne $name,
		@interesting;
	return ( [ $name ], @outward_paths );
}

memoize( 'paths_from' );

sub try_paths ( $time_limit, @xteam ) {
	my @team = map +{ 
		name   => $_->[0],
		path   => $_->[1],
		left   => [ $_->[1]->@* ],
		wait   => 0,
		at     => undef,
	}, @xteam;

	say "ATTEMPT:" if DEBUG;
	for ( @team ) {
		$_->{at} = shift( $_->{left}->@* );
		printf( "%s taking path %s.\n", $_->{name}, join '»', $_->{path}->@* ) if DEBUG;
	}

	my %valve_on;
	my $flow_rate = 0;
	my $flowed = 0;
	my $remaining = $time_limit;

	TICK: while ( $remaining ) {
		say "  $flow_rate flows. Total flowed: $flowed." if DEBUG;
		$flowed += $flow_rate;

		PLAYER: for my $player ( @team ) {
			my $player_name = $player->{name};
			if ( $player->{wait} ) {
				say "  $player_name is travelling." if DEBUG;
				--$player->{wait};
				if ( $player->{wait} == 0 ) {
					say "  $player_name arrives at ", $player->{dest} if DEBUG;
					$player->{at} = delete $player->{dest};
				}
				else {
					next PLAYER;
				}
			}
			my $at = $player->{at};
			if ( exists( $valve_on{$at} ) or $valves{$at}{rate} == 0 ) {
				my $dest = shift( $player->{left}->@* );
				if ( $dest ) {
					my $distance = $distance{"$at:$dest"};
					say "  $player_name starts travelling from $at to $dest (distance: $distance)." if DEBUG;
					$player->{wait} = $distance;
					$player->{dest} = $dest;
					next PLAYER;
				}
				else {
					say "  $player_name has nowhere to go." if DEBUG;
					next PLAYER;
				}
			}
			else {
				my $rate = $valves{$at}{rate};
				say "  $player_name turns valve $at with rate $rate on." if DEBUG;
				$flow_rate += $rate;
				$valve_on{$at} = 1;
				say "  Total flow rate is now $flow_rate." if DEBUG;
				next PLAYER;
			}
		}

		--$remaining;
		say "  !!!TICK!!! Remaining: $remaining." if DEBUG;
	}

	say "  RESULT: $flowed" if DEBUG;
	return $flowed;
}

if ( PART_ONE ) {
	my $minutes = 30;
	my @paths = paths_from( 'AA', $minutes );
	say "Part 1 number of paths: ", scalar(@paths);
	my $best_path;
	my $best_flow = -1;
	my $count;
	for my $path ( @paths ) {
		++$count;
		my $flow = try_paths(
			$minutes,
			[ Human => $path ],
		);
		if ( $flow > $best_flow ) {
			$best_flow = $flow;
			$best_path = $path;
		}
	}
	say "Part 1 best flow was $best_flow using path @$best_path";
	say "Searched $count possibilities.";
}

if ( PART_TWO ) {
	my $minutes = 26;
	my @paths = paths_from( 'AA', $minutes );
	say "Part 2 number of paths: ", scalar(@paths);
	my ( $best_path, $best_path2 );
	my $best_flow = -1;
	my ( $count, $outer_count, $real_count );
	OUTER: for my $path ( @paths ) {
		++$outer_count;
		say "  outer count: $outer_count" unless $outer_count % 1_000;
		flush_cache 'paths_from';
		my @paths2 = paths_from( 'AA', $minutes, sort(@$path) );
		INNER: for my $elephant_path ( @paths2 ) {
			++$count;
			next OUTER if @$path < 2;
			next INNER if @$elephant_path < 2;
			next INNER if "@$path" le "@$elephant_path";
			++$real_count;
			my $flow = try_paths(
				$minutes,
				[ Human    => $path ],
				[ Elephant => $elephant_path ],
			);
			if ( $flow > $best_flow ) {
				$best_flow = $flow;
				$best_path = $path;
				$best_path2 = $elephant_path;
			}
		}
	}
	say "Part 2 best flow was $best_flow using path @$best_path and @$best_path2";
	say "Searched $count possibilities. (Only $real_count were seriously considered.)";
}
