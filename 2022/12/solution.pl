use v5.24;
use warnings;
use Time::HiRes ();
use Term::ANSIScreen ();

package Square {
	use Moo; use experimental qw( signatures );
	has letter      => ( is => 'ro', required => !!1 );
	has height      => ( is => 'rwp' );
	has distance    => ( is => 'ro', writer => 'set_distance' );

	sub has_distance ( $self ) {
		defined( $self->distance );
	}

	sub marker ( $self ) {
		defined( $self->distance ) ? $self->letter : '.';
	}

	my %H = do {
		my $i = 0;
		map +( $_ => ++$i ), 'a' .. 'z';
	};
	$H{'S'} = $H{'a'};
	$H{'E'} = $H{'z'};
	sub BUILD ( $self, $args ) {
		my $letter = $args->{letter};
		$self->_set_height( $H{ $self->letter // $args->{letter} } );
	}
}

package Map {
	use Moo; use experimental qw( signatures );
	has description => ( is => 'ro', required => !!1 );
	has grid        => ( is => 'ro', required => !!1 );
	has start_point => ( is => 'ro', required => !!1 );
	has end_point   => ( is => 'ro', required => !!1 );

	sub load ( $class, %args ) {
		my $filename    = delete $args{filename};
		my $start_point = $args{start_point};

		local @ARGV = $filename;
		my @grid = map {
			chomp( my $line = $_ );
			my @row = map {
				my $letter = $_;
				Square->new(
					letter   => $_,
					distance => ( /$start_point/ ? 0 : undef ),
				);
			} split //, $line;
			\@row;
		} <>;

		return $class->new( grid => \@grid, %args );
	}

	sub lookup_square ( $self, $row, $col ) {
		return if $row < 0;
		return if $col < 0;
		return if $row > $#{ $self->grid };
		my $R = $self->grid->[$row];
		return if $col > $#{ $R };
		return $R->[$col];
	}

	sub assess ( $self, $quiet=0 ) {
		my $end_point = $self->end_point;
		if ( $quiet ) {
			my @found =
				grep defined,
				map $_->letter =~ $end_point ? $_->distance : undef,
				map $_->@*,
				$self->grid->@*;
			return wantarray ? ( $found[0], '' ) : $found[0];
		}
		my $got = undef;
		my $str = '';
		for my $row ( $self->grid->@* ) {
			$str .= join( q[], map {
				$got //= $_->distance if $_->letter =~ $end_point;
				$_->marker;
			} $row->@* ) . "\n";
		}
		wantarray ? ( $got, $str ) : $got;
	}

	sub run_simulation ( $self, $quiet=!$ENV{VISUALIZE} ) {
		my $start = Time::HiRes::time();
		my $step = 0;
		STEP: while () {
			++$step;
			my $actions = 0;
			ROW: for my $row ( 0 .. $#{ $self->grid } ) {
				COL: for my $col ( 0 .. $#{ $self->grid->[$row] } ) {
					my $square = $self->lookup_square( $row, $col );
					next if $square->has_distance;
					my @neighbours =
						grep $square->height <= $_->height + 1,
						grep $_->has_distance && $_->distance < $step,
						grep defined,
						map $self->lookup_square( @$_ ),
						[ $row-1, $col ], [ $row, $col+1 ], [ $row+1, $col ], [ $row, $col-1 ];
					$actions += @neighbours;
					$square->set_distance( $step ) if @neighbours;
				}
			}

			my ( $final, $debug ) = $self->assess( $quiet );

			if ( ! $quiet ) {
				print Term::ANSIScreen::cls();
				say "Step $step";
				say $debug;
				Time::HiRes::usleep(20_000);
			}

			if ( defined $final ) {
				my $end = Time::HiRes::time();
				printf( "%s: %d (%.06f s)\n", $self->description, $final, $end-$start );
				if ( ! $quiet ) {
					say "Hit Ctrl+D to continue";
					my $got = <>;
				}
				last STEP;
			}

			if ( not $actions ) {
				say $self->description, ": reached dead end";
				last STEP;
			}
		}
	}
}

defined( $ENV{VISUALIZE} )
	or say "Set the VISUALIZE environment variable for a pretty display.";

Map->load(
	description => 'Part 1',
	filename    => 'input.txt',
	start_point => qr/^S$/,
	end_point   => qr/^E$/,
)->run_simulation();

Map->load(
	description => 'Part 2',
	filename    => 'input.txt',
	start_point => qr/^[Sa]$/,
	end_point   => qr/^E$/,
)->run_simulation();
