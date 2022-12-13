<?php

function my_cmp ( $x, $y ) {
	if ( is_int($x) and is_int($y) )
		return $y <=> $x;
	if ( is_int($x) and is_array($y) )
		return my_cmp( [$x], $y );
	if ( is_array($x) and is_int($y) )
		return my_cmp( $x, [$y] );

	$i = 0;
	while ( true ) {
		if ( $i >= count($x) and $i >= count($y) )
			return 0;
		if ( $i >= count($x) )
			return 1;
		if ( $i >= count($y) )
			return -1;
		$cmp = my_cmp( $x[$i], $y[$i] );
		if ( $cmp != 0 )
			return $cmp;
		++$i;
	}
}

$filename = 'input.txt';

PART_1: {
	list ( $i, $total ) = [ 0, 0 ];
	$lines = file( $filename );
	while ( count($lines) ) {
		$first  = json_decode( array_shift($lines) );
		$second = json_decode( array_shift($lines) );
		array_shift($lines);
		++$i;
		if ( my_cmp( $first, $second ) >= 0 )
			$total += $i;
	}
	echo "Index total: $total\n";
}

PART_2: {
	$all = array_map(
		function ( $line ) { return json_decode( $line ); },
		array_filter(
			file( $filename ),
			function ( $line ) { return preg_match( '/\S/', $line ); },
		),
	);
	$all []= [[2]];
	$all []= [[6]];
	usort( $all, 'my_cmp' );
	$all = array_reverse( $all );
	$indices = [];
	foreach ( $all as $ix => $line ) {
		$json = json_encode( $line );
		if ( $json === '[[2]]' or $json === '[[6]]' ) $indices []= 1 + $ix;
	}
	echo "Decoder key: " . ( $indices[0] * $indices[1] ) . "\n";
}
