#!perl
use v5.24;
use warnings;
use experimental qw( signatures );
use constant FILENAME => $ENV{ADVENT_INPUT};

use constant {
	VOID    => 0,
	PATH    => 1,
	WALL    => 2,
};

use constant {
	FACING_RIGHT => 0,
	FACING_DOWN  => 1,
	FACING_LEFT  => 2,
	FACING_UP    => 3,
};

# Working these out on the fly would be nice, but effort!
use constant $ENV{ADVENT_DATASET} eq 'test'
	? {
		CUBE_FACE_LENGTH => 4,
		CUBE_FACES => [
			[  0 ,  0 , 'A',  0  ],
			[ 'B', 'C', 'D',  0  ],
			[  0 ,  0 , 'E', 'F' ],
		],
		FACE_COORDS => {
			'A' => [ 0, 2 ],
			'B' => [ 1, 0 ],
			'C' => [ 1, 1 ],
			'D' => [ 1, 2 ],
			'E' => [ 2, 2 ],
			'F' => [ 2, 3 ],
		},
		# Keys are a current_face + current_direction pair.
		CUBE_TRANSITIONS => {
			# Unremarkable cube transitions. Value is just zero.
			'A1' => 0,
			'B0' => 0,
			'C0' => 0, 'C2' => 0,
			'D1' => 0, 'D2' => 0, 'D3' => 0,
			'E0' => 0, 'E3' => 0,
			'F2' => 0,
			# Interesting cube transitions. Value is the next face's letter,
			# followed by the number of clockwise rotations necessary.
			'A0' => 'F2', 'A2' => 'C3', 'A3' => 'B2',
			'B1' => 'A2', 'B2' => 'F1', 'B3' => 'E2',
			'C1' => 'E3', 'C3' => 'A1',
			'D0' => 'F1',
			'E1' => 'B2', 'E2' => 'C1',
			'F0' => 'A2', 'F1' => 'B3', 'F3' => 'D3',
		},
	}
	: {
		CUBE_FACE_LENGTH => 50,
		CUBE_FACES => [
			[  0 , 'A', 'B' ],
			[  0 , 'C',  0  ],
			[ 'D', 'E',  0  ],
			[ 'F',  0 ,  0  ],
		],
		FACE_COORDS => {
			'A' => [ 0, 1 ],
			'B' => [ 0, 2 ],
			'C' => [ 1, 1 ],
			'D' => [ 2, 0 ],
			'E' => [ 2, 1 ],
			'F' => [ 3, 0 ],
		},
		CUBE_TRANSITIONS => {
			'A0' => 0, 'A1' => 0,
			'B2' => 0,
			'C1' => 0, 'C3' => 0,
			'D0' => 0, 'D1' => 0,
			'E2' => 0, 'E3' => 0,
			'F3' => 0,
			'A2' => 'D2', 'A3' => 'F1',
			'B0' => 'E2', 'B1' => 'C1', 'B3' => 'F0',
			'C0' => 'B3', 'C2' => 'D3',
			'D2' => 'A2', 'D3' => 'C1',
			'E0' => 'B2', 'E1' => 'F1',
			'F0' => 'E3', 'F1' => 'B0', 'F2' => 'A3',
		},
	};

sub read_map_and_journey () {
	my ( @map, @journey );
	my %char = (
		q[ ] => VOID,
		q[.] => PATH,
		q[#] => WALL,
	);
	my $map_finished;

	open my $fh, '<', FILENAME or die("Could not open file");
	while ( <$fh> ) {
		chomp;
		if ( not length ) {
			$map_finished = 1;
			next;
		}
		if ( $map_finished ) {
			@journey = ( /(\d+|R|L)/g );
		}
		else {
			push @map, [ map $char{$_}//die("???"), split // ];
		}
	}

	( \@map, \@journey )
}

sub initial_position ( $map ) {
	my $col;
	for my $i ( 0 .. $#{ $map->[0] } ) {
		if ( $map->[0][$i] == PATH ) {
			$col = $i;
			last;
		}
	}
	return [ FACING_RIGHT, 0, $col ];
}

sub part1_pace_calc ( $map, $position ) {
	my ( $facing, $row, $col ) = $position->@*;

	if ( $facing == FACING_RIGHT ) {
		$col++;
		$col = 0 if $col > $#{ $map->[$row] };
		while ( ( $map->[$row][$col] // VOID ) == VOID ) {
			$col++;
			$col = 0 if $col > $#{ $map->[$row] };
		}
	}

	if ( $facing == FACING_LEFT ) {
		$col--;
		$col = $#{ $map->[$row] } if $col < 0;
		while ( ( $map->[$row][$col] // VOID ) == VOID ) {
			$col--;
			$col = $#{ $map->[$row] } if $col < 0;
		}
	}

	if ( $facing == FACING_UP ) {
		$row--;
		$row = $#{ $map } if $row < 0;
		while ( ( $map->[$row][$col] // VOID ) == VOID ) {
			$row--;
			$row = $#{ $map } if $row < 0;
		}
	}

	if ( $facing == FACING_DOWN ) {
		$row++;
		$row = 0 if $row > $#{ $map };
		while ( ( $map->[$row][$col] // VOID ) == VOID ) {
			$row++;
			$row = 0 if $row > $#{ $map };
		}
	}

	( $facing, $row, $col );
}

sub part2_pace_calc ( $map, $position ) {
	my ( $facing, $row, $col ) = $position->@*;

	# Perform naive calculation.
	my @naive = part1_pace_calc( $map, $position );
	my ( $next_facing, $next_row, $next_col ) = @naive;

	# Known safe directions to travel. Naive calculation is fine.
	my $current_face = CUBE_FACES->[ int( $row / CUBE_FACE_LENGTH ) ][ int( $col / CUBE_FACE_LENGTH ) ];
	if ( CUBE_TRANSITIONS->{$current_face.$facing} eq 0 ) {
		return @naive;
	}

	# Risky direction but haven't reached an edge, so naive calculation is
	# still correct (very common case!)
	my $next_face = CUBE_FACES->[ int( $next_row / CUBE_FACE_LENGTH ) ][ int( $next_col / CUBE_FACE_LENGTH ) ];
	if ( $current_face eq $next_face
	and abs( $row - $next_row ) <= 1
	and abs( $col - $next_col ) <= 1 ) {
		return @naive;
	}

	defined CUBE_TRANSITIONS->{$current_face.$facing} or die;

	# Figure out rotation and proper next face!
	my $rotation;
	( $next_face, $rotation ) = ( CUBE_TRANSITIONS->{$current_face.$facing} =~ /^(.)(.)$/ );

	my $distance_along_edge = ( $facing % 2 ) ? ( $col % CUBE_FACE_LENGTH ) : ( $row % CUBE_FACE_LENGTH );
	$distance_along_edge = CUBE_FACE_LENGTH - ( $distance_along_edge + 1 ) if $facing==1 || $facing==2;

	$next_facing = ( $facing + $rotation ) % 4; 

	my ( $f_row, $f_col ) = map $_ * CUBE_FACE_LENGTH, @{ FACE_COORDS->{$next_face} };

	if ( $next_facing == FACING_RIGHT ) {
		( $next_row, $next_col ) = ( $f_row + $distance_along_edge, $f_col );
	}
	elsif ( $next_facing == FACING_DOWN ) {
		( $next_row, $next_col ) = ( $f_row, $f_col + CUBE_FACE_LENGTH - ( $distance_along_edge + 1 ) );
	}
	elsif ( $next_facing == FACING_LEFT ) {
		( $next_row, $next_col ) = ( $f_row + CUBE_FACE_LENGTH - ( $distance_along_edge + 1 ), $f_col + CUBE_FACE_LENGTH - 1 );
	}
	elsif ( $next_facing == FACING_UP ) {
		( $next_row, $next_col ) = ( $f_row + CUBE_FACE_LENGTH - 1, $f_col + $distance_along_edge );
	}

	( $next_facing, $next_row, $next_col );
}

sub follow_path ( $map, $journey, $position, $pace_calc ) {
	INSTRUCTION: while ( $journey->@* ) {
		my $instruction = shift $journey->@*;

		# Handle turning.
		if ( $instruction eq 'R' ) {
			$position->[0]++;
			$position->[0] %= 4;
			next;
		}
		elsif ( $instruction eq 'L' ) {
			$position->[0]--;
			$position->[0] %= 4;
			next;
		}

		my $paces = $instruction;
		PACE: while ( $paces > 0 ) {
			my ( $next_facing, $next_row, $next_col ) = $pace_calc->( $map, $position );
			if ( $map->[$next_row][$next_col] == WALL ) {
				last PACE;
			}
			else {
				$position->@* = ( $next_facing, $next_row, $next_col );
				--$paces;
				next PACE;
			}
		}
	}
}

sub generate_password ( $position ) {
	my ( $facing, $row, $col ) = $position->@*;
	1000*($row+1) + 4*($col+1) + $facing;
}

sub part1 () {
	my ( $map, $journey ) = read_map_and_journey();
	my $position = initial_position( $map );
	follow_path( $map, $journey, $position, \&part1_pace_calc );
	say "PART1: ", generate_password( $position );
}

sub part2 () {
	my ( $map, $journey ) = read_map_and_journey();
	my $position = initial_position( $map );
	follow_path( $map, $journey, $position, \&part2_pace_calc );
	say "PART2: ", generate_password( $position );
}

unless ( caller ) {
	part1();
	part2();
}
