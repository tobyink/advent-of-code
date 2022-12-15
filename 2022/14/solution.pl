#!perl

use v5.24;
use utf8;
use warnings;
use constant {
	FILENAME    => 'input-test.txt',
	ENTRANCE    => [ 500, 0 ],
};

binmode( STDOUT, ':utf8' );

# A bunch of imports to bring into all the OO packages...
BEGIN {
	package Prelude;
	use constant ();
	use experimental qw( signatures );
	use namespace::clean ();
	use Data::Dumper;
	use Import::Into 1.002000 ();
	use List::Util ();
	use Moo 2.000000 ();
	use Moo::Role ();
	use Scalar::Util ();
	use Sub::HandlesVia 0.045 ();
	use Types::Common 2.000000 ();
	sub import ( $class, $arg = '' ) {
		if ( $arg eq -class ) {
			'Moo'->import::into( 1 );
			'Sub::HandlesVia'->import::into( 1 );
		}
		elsif ( $arg eq -role ) {
			'Moo::Role'->import::into( 1 );
			'Sub::HandlesVia'->import::into( 1 );
		}
		'Types::Common'->import::into( 1, qw( -sigs -types ) );
		'experimental'->import::into( 1, qw( signatures ) );
		'constant'->import::into( 1, { true => !!1, false => !!0 } );
		'namespace::clean'->import::into( 1 );
	}
	$INC{'Prelude.pm'} = __FILE__;
	$Data::Dumper::Deparse = 1;
};

package Square {
	use Prelude;
	use constant {
		AIR    => 0,
		ROCK   => 1,
		SAND   => 2,
		FLOOR  => 3,
	};
	
	signature_for render => (
		method => 1,
		pos    => [ Int ],
	);
	sub render ( $class, $material ) {
		state $character = [ '·', '█', '▒', '▓' ];
		$character->[$material];
	}
}

package Grid {
	use Prelude -class;

	has squares => (
		is      => 'rw',
		isa     => ArrayRef[ ArrayRef[ Int ] ] ,
	);

	has active_area => (
		is      => 'rw',
		isa     => ArrayRef[ Int, 4 ],
		handles_via => 'Array',
		handles => {
			min_col => [ get => 0 ],
			min_row => [ get => 1 ],
			max_col => [ get => 2 ],
			max_row => [ get => 3 ],
		},
	);

	signature_for load => (
		method => 1,
		named  => [
			filename  => Str,
			init_args => Slurpy[HashRef],
		],
	);
	sub load ( $class, $arg ) {
		open my $fh, '<', $arg->filename or die;
		my ( $min_col, $max_col, $min_row, $max_row, @paths )
			= ( 10_000, 0, 10_000, 0 );
		while ( my $line = <$fh> ) {
			chomp $line;
			my @path = ();
			while ( $line =~ /(\d+),(\d+)/g ) {
				my ( $col, $row ) = ( $1, $2 );
				$min_col = $col if $col < $min_col;
				$min_row = $row if $row < $min_row;
				$max_col = $col if $col > $max_col;
				$max_row = $row if $row > $max_row;
				push @path, [ $col, $row ];
			}
			push @paths, \@path;
		}
		my $blanks = [ map [ ( Square::AIR ) x ( $max_col + 1 ) ], 0 .. $max_row ];
		my $grid = $class->new(
			$arg->init_args->%*,
			squares     => $blanks,
			active_area => [ $min_col, $min_row, $max_col, $max_row ],
		);
		$grid->draw_path( Square::ROCK, $_ ) for @paths;
		return $grid;
	}
	
	signature_for draw_path => (
		method => 1,
		pos    => [ Int, ArrayRef ],
	);
	sub draw_path ( $self, $material, $path ) {
		my @points = $path->@*;
		my $start  = shift @points;
		while ( @points ) {
			my $end = shift @points;
			$self->draw_line( $material, $start, $end );
			$start = $end;
		}
	}

	signature_for draw_line => (
		method => 1,
		pos    => [ Int, ArrayRef, ArrayRef ],
	);
	sub draw_line ( $self, $material, $start, $end ) {
		my @cols = sort { $a <=> $b } $start->[0], $end->[0];
		my @rows = sort { $a <=> $b } $start->[1], $end->[1];
		for my $col ( $cols[0] .. $cols[1] ) {
			for my $row ( $rows[0] .. $rows[1] ) {
				$self->squares->[$col][$row] = $material;
			}
		}
	}
	
	signature_for draw_floor => (
		method => 1,
		pos    => [ Int ],
	);
	sub draw_floor ( $self, $offset ) {
		my $floor_level = $self->max_row + $offset;
		$self->draw_line( Square::FLOOR, [ 0, $floor_level ], [ 20_000, $floor_level ] );
	}
	
	signature_for render => (
		method => 1,
		pos    => [],
	);
	sub render ( $self ) {
		join "\n", map {
			my $row = $_;
			join "", map {
				my $col = $_;
				Square->render( $self->squares->[$col][$row] // 0 );
			} ( $self->min_col - 1 .. $self->max_col + 1 );
		} ( $self->min_row .. $self->max_row + 2 );
	}

	signature_for drop_sand => (
		method => 1,
		pos    => [ ArrayRef ],
	);
	sub drop_sand ( $self, $from_source ) {
		my ( $col, $row ) = $from_source->@*;
		my $settled = false;
		my $void = false;
		until ( $settled or $void ) {
			no warnings 'uninitialized';

			if ( $row > $self->max_row + 3 ) {
				$void = true;
				last;
			}

			# Check if it can fall into the square below.
			if ( $self->squares->[$col][$row+1] == Square::AIR ) {
				++$row;
				next;
			}
			
			# Check if it can fall into the square diagonally to the left.
			if ( $self->squares->[$col-1][$row+1] == Square::AIR ) {
				++$row;
				--$col;
				next;
			}
			
			# Check if it can fall into the square diagonally to the right.
			if ( $self->squares->[$col+1][$row+1] == Square::AIR ) {
				++$row;
				++$col;
				next;
			}

			$self->squares->[$col][$row] = Square::SAND;
			$settled = true;
		} # /while
		
		if ( $settled ) {
			return [ $col, $row, false ];
		}
		return [ $col, undef, true ];
	}
	
	signature_for render_sand_drop => (
		method => 0,   # utility function
		pos    => [
			Tuple[ Int, Maybe[Int], Bool ],
			Str, { default => 'Sand' },
		],
	);
	sub render_sand_drop ( $result, $name ) {
		my ( $col, $row, $void ) = $result->@*;
		if ( $void ) {
			return "$name fell into the void from column $col."
		}
		return "$name settled at column $col, row $row."
	}
}

say Grid->load( filename => FILENAME )->render, "\n\n";

PART_1: {
	my $g = Grid->load( filename => FILENAME );
	for my $i ( 1 .. 20_000 ) { # avoid infinite loop
		my $result = $g->drop_sand( ENTRANCE );
		# say Grid::render_sand_drop( $result, "Sand block $i" );
		if ( $result->[2] ) {
			say $g->render;
			say "Started falling into the void at ", $i;
			last;
		}
	}
	say "Part one answer is that, minus one.";
	say "";
}

PART_2: {
	my $g = Grid->load( filename => FILENAME );
	$g->draw_floor( +2 );
	for my $i ( 1 .. 200_000 ) { # avoid infinite loop
		my $result = $g->drop_sand( ENTRANCE );
		# say Grid::render_sand_drop( $result, "Sand block $i" );
		if ( $result->[0] == ENTRANCE->[0] and $result->[1] == ENTRANCE->[1] ) {
			say $g->render;
			say "Entrance blocked at ", $i;
			last;
		}
	}
	say "Part two answer is that.";
	say "";
}
