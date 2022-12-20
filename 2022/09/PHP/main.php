<?php

class Knot {
	private $row;
	private $col;
	private $history;

	public function __construct( $row = 0, $col = 0 ) {
		$this->row = $row;
		$this->col = $col;
		$this->history = [];
		$this->track_history();
	}

	private function track_history () {
		$key = implode( ',', [ $this->row, $this->col ] );
		if ( empty( $this->history[$key] ) )
			$this->history[$key] = 0;
		++$this->history[$key];
	}

	public function history_size () {
		return count( $this->history );
	}

	public function move ( $direction ) {
		str_contains( $direction, 'U' ) and --$this->row;
		str_contains( $direction, 'D' ) and ++$this->row;
		str_contains( $direction, 'L' ) and --$this->col;
		str_contains( $direction, 'R' ) and ++$this->col;
		$this->track_history();
	}

	public function follow ( $other ) {
		if ( abs( $this->row - $other->row ) <= 1 and abs( $this->col - $other->col ) <= 1 ) {
			return;
		}
		$direction = '';
		$this->row > $other->row and $direction .= 'U';
		$this->row < $other->row and $direction .= 'D';
		$this->col > $other->col and $direction .= 'L';
		$this->col < $other->col and $direction .= 'R';
		$this->move( $direction );
	}
}

function main ( $filename, $knot_count = 2, $desc = "ANSWER" ) {
	$knot_count > 1 or die();
	for ( $k = 0; $k < $knot_count; ++$k ) {
		$knots[] = new Knot( 0, 0 );
	}
	$lines = file( $filename );
	foreach ( $lines as $line ) {
		list ( $direction, $move_count ) = explode( ' ', trim( $line ) );
		while ( $move_count-->0 ) {
			foreach ( $knots as $ix => $knot ) {
				if ( $ix == 0 ) {
					$knot->move( $direction );
					continue;
				}
				$knot->follow( $knots[$ix - 1] );
			}
		}
	}
	echo "$desc: " . $knots[$knot_count-1]->history_size() . "\n";
}

main( getenv('ADVENT_INPUT'), 2, "PART1" );
main( getenv('ADVENT_INPUT'), 10, "PART2" );
