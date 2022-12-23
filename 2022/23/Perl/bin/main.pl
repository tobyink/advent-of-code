#!perl
use v5.24;
use warnings;
use experimental qw( signatures );
use constant FILENAME => $ENV{ADVENT_INPUT};

use constant {
	NORTH  => 0,
	SOUTH  => 1,
	WEST   => 2,
	EAST   => 3,
};

use constant {
	ELF_ROW => 0,
	ELF_COL => 1,
	ELF_CONSIDERING => 2,
};

use constant {
	SQ_ELF => 0,
	SQ_CONSIDERED_BY => 1,
};

sub dump_grid ( $grid ) {
	join "\n", map {
		join "", map {
			my $cell = $_;
			$cell->[SQ_CONSIDERED_BY]->@*
				? '?'
				: $cell->[SQ_ELF]
					? dump_elf($cell->[SQ_ELF])
					: '.'
		} @$_;
	} @$grid;
}

sub dump_elf ( $elf ) {
	return '#' if not defined $elf->[ELF_CONSIDERING];

	return '^' if $elf->[ELF_CONSIDERING] == NORTH;
	return 'v' if $elf->[ELF_CONSIDERING] == SOUTH;
	return '<' if $elf->[ELF_CONSIDERING] == WEST;
	return '>' if $elf->[ELF_CONSIDERING] == EAST;

	'!';
}

sub read_grid () {
	my ( $row, $g, $e ) = ( 0, [], [] );
	open my $fh, '<', FILENAME or die;
	while ( <$fh> ) {
		chomp;
		my ( $col, $l ) = ( 0, [] );
		for ( split // ) {
			my $elf = m/#/ ? [ $row, $col, undef ] : undef;
			push @$l, [ $elf, [] ];
			push @$e, $elf if defined $elf;
			++$col;
		}
		push @$g, $l;
		++$row;
	}
	return ( $g, $e );
}

sub grid_needs_expansion ( $grid ) {
	# Grid needs expansion if there's any elves in the first or last row.
	for my $square ( $grid->[0]->@*, $grid->[-1]->@* ) {
		return 1 if defined $square->[SQ_ELF];
	}
	# Grid needs expansion if there's any elves in the first or last square of
	# any row.
	for my $row ( $grid->@* ) {
		return 1 if defined $row->[0]->[SQ_ELF];
		return 1 if defined $row->[-1]->[SQ_ELF];
	}
	return 0;
}

sub expand_grid ( $grid ) {
	my $expand_by = 2;
	my $height = scalar( $grid->@* );
	my $width = scalar( $grid->[0]->@* );
	my $new_width = $width + $expand_by + $expand_by;
	for my $row ( $grid->@* ) {
		unshift $row->@*, map [ undef, [] ], 1 .. $expand_by;
		push $row->@*, map [ undef, [] ], 1 .. $expand_by;
	}
	unshift $grid->@*, map [ map [ undef, [] ], 1 .. $new_width ], 1 .. $expand_by;
	push $grid->@*, map [ map [ undef, [] ], 1 .. $new_width ], 1 .. $expand_by;
	fix_elf_coords( $grid );
}

sub fix_elf_coords ( $grid ) {
	my $height = scalar( $grid->@* );
	my $width = scalar( $grid->[0]->@* );
	for my $row ( 0 .. $height - 1 ) {
		for my $col ( 0 .. $width - 1 ) {
			next unless $grid->[$row][$col][SQ_ELF];
			$grid->[$row][$col][SQ_ELF][ELF_ROW] = $row;
			$grid->[$row][$col][SQ_ELF][ELF_COL] = $col;
		}
	}
}

sub consider_moves ( $grid, $elves, $count ) {

	state $surroundings = [
		[ -1, -1 ],
		[ -1,  0 ],
		[ -1, +1 ],
		[  0, -1 ],
		[  0, +1 ],
		[ +1, -1 ],
		[ +1,  0 ],
		[ +1, +1 ],
	];

	my $considerations = 0;

	ELF: for my $elf ( $elves->@* ) {

		my $elf_row = $elf->[ELF_ROW];
		my $elf_col = $elf->[ELF_COL];
		my $has_nearby_elf = 0;

		SURROUNDING: for my $s ( $surroundings->@* ) {
			my $nearby_square = $grid->[ $elf_row + $s->[0] ][ $elf_col + $s->[1] ];
			if ( $nearby_square->[SQ_ELF] ) {
				$has_nearby_elf++;
				last SURROUNDING;
			}
		}

		next ELF unless $has_nearby_elf;
		$considerations++;

		DIRECTION: for my $cycle ( 0 .. 3 ) {
			my $direction = ( $count + $cycle ) % 4;

			if ( $direction == NORTH
			and ! $grid->[$elf_row-1][$elf_col-1][SQ_ELF]
			and ! $grid->[$elf_row-1][$elf_col+0][SQ_ELF]
			and ! $grid->[$elf_row-1][$elf_col+1][SQ_ELF] ) {
				$elf->[ELF_CONSIDERING] = NORTH;
				push $grid->[$elf_row-1][$elf_col+0][SQ_CONSIDERED_BY]->@*, $elf;
				last DIRECTION;
			}

			if ( $direction == SOUTH
			and ! $grid->[$elf_row+1][$elf_col-1][SQ_ELF]
			and ! $grid->[$elf_row+1][$elf_col+0][SQ_ELF]
			and ! $grid->[$elf_row+1][$elf_col+1][SQ_ELF] ) {
				$elf->[ELF_CONSIDERING] = SOUTH;
				push $grid->[$elf_row+1][$elf_col+0][SQ_CONSIDERED_BY]->@*, $elf;
				last DIRECTION;
			}

			if ( $direction == WEST
			and ! $grid->[$elf_row-1][$elf_col-1][SQ_ELF]
			and ! $grid->[$elf_row+0][$elf_col-1][SQ_ELF]
			and ! $grid->[$elf_row+1][$elf_col-1][SQ_ELF] ) {
				$elf->[ELF_CONSIDERING] = WEST;
				push $grid->[$elf_row+0][$elf_col-1][SQ_CONSIDERED_BY]->@*, $elf;
				last DIRECTION;
			}

			if ( $direction == EAST
			and ! $grid->[$elf_row-1][$elf_col+1][SQ_ELF]
			and ! $grid->[$elf_row+0][$elf_col+1][SQ_ELF]
			and ! $grid->[$elf_row+1][$elf_col+1][SQ_ELF] ) {
				$elf->[ELF_CONSIDERING] = EAST;
				push $grid->[$elf_row+0][$elf_col+1][SQ_CONSIDERED_BY]->@*, $elf;
				last DIRECTION;
			}
		}
	}

	return $considerations;
}

sub make_moves ( $grid, $elves ) {
	my $height = scalar( $grid->@* );
	my $width = scalar( $grid->[0]->@* );
	for my $row ( 0 .. $height - 1 ) {
		for my $col ( 0 .. $width - 1 ) {
			my $square = $grid->[$row][$col];
			my @elves = $square->[SQ_CONSIDERED_BY]->@* or next;

			# If multiple elves considered this square, then
			# they should no longer consider it. It should be
			# considered by no elves!
			if ( @elves > 1 ) {
				$_->[ELF_CONSIDERING] = undef for @elves;
				$square->[SQ_CONSIDERED_BY] = [];
				next;
			}

			# If one elf considered it, the elf should move!
			my $elf = shift @elves;
			my $old_square = $grid->[ $elf->[ELF_ROW] ][ $elf->[ELF_COL] ];
			undef $old_square->[SQ_ELF];
			$elf->[ELF_ROW] = $row;
			$elf->[ELF_COL] = $col;
			$elf->[ELF_CONSIDERING] = undef;
			$square->[SQ_ELF] = $elf;
			$square->[SQ_CONSIDERED_BY] = [];
		}
	}
}

sub shrink_grid ( $grid ) {
	SHRINK_TOP: {
		my $row_empty = !grep $_->[SQ_ELF], $grid->[0]->@*;
		if ( $row_empty ) {
			shift $grid->@*;
			redo SHRINK_TOP;
		}
	}
	SHRINK_BOTTOM: {
		my $row_empty = !grep $_->[SQ_ELF], $grid->[-1]->@*;
		if ( $row_empty ) {
			pop $grid->@*;
			redo SHRINK_BOTTOM;
		}
	}
	SHRINK_LEFT: {
		my $col_empty = !grep $_->[0][SQ_ELF], $grid->@*;
		if ( $col_empty ) {
			shift $_->@* for $grid->@*;
			redo SHRINK_LEFT;
		}
	}
	SHRINK_RIGHT: {
		my $col_empty = !grep $_->[-1][SQ_ELF], $grid->@*;
		if ( $col_empty ) {
			pop $_->@* for $grid->@*;
			redo SHRINK_RIGHT;
		}
	}
}

sub count_empty ( $grid ) {
	my $count = 0;
	my $height = scalar( $grid->@* );
	my $width = scalar( $grid->[0]->@* );
	for my $row ( 0 .. $height - 1 ) {
		for my $col ( 0 .. $width - 1 ) {
			++$count unless $grid->[$row][$col][SQ_ELF];
		}
	}
	$count;
}

sub part1 () {
	my ( $grid, $elves ) = read_grid();
	my $count = 0;
	while ( 1 ) {
		expand_grid( $grid ) if grid_needs_expansion( $grid );
		my $considered_moves = consider_moves( $grid, $elves, $count );
		make_moves( $grid, $elves );
		$count++;
		last if $count == 10;
	}
	shrink_grid( $grid );
	say "== After round $count ==";
	say dump_grid( $grid );
	say "PART1: ", count_empty( $grid );
}

sub part2 () {
	my ( $grid, $elves ) = read_grid();
	my $count = 0;
	while ( 1 ) {
		expand_grid( $grid ) if grid_needs_expansion( $grid );
		my $considered_moves = consider_moves( $grid, $elves, $count );
		make_moves( $grid, $elves );
		$count++;
		last if $considered_moves == 0;
	}
	shrink_grid( $grid );
	say "== Final state (after round $count) ==";
	say dump_grid( $grid );
	say "PART2: ", $count;
}

unless ( caller ) {
	part1();
	part2();
}
