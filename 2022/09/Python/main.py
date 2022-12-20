#!/usr/bin/python3.10

import os

class Knot:
	def __init__ ( self, row, col ):
		self.row, self.col, self.history = row, col, {}
		self.track_history()

	def track_history ( self ):
		self.history[ "{},{}".format( self.row, self.col ) ] = 1

	def history_size ( self ):
		return len( self.history )

	def move ( self, direction ):
		if "U" in direction: self.row -= 1
		if "D" in direction: self.row += 1
		if "L" in direction: self.col -= 1
		if "R" in direction: self.col += 1
		self.track_history()

	def follow ( self, other ):
		if abs( self.row - other.row ) <= 1 and abs( self.col - other.col ) <= 1:
			return
		direction = '';
		if self.row > other.row: direction += 'U'
		if self.row < other.row: direction += 'D'
		if self.col > other.col: direction += 'L'
		if self.col < other.col: direction += 'R'
		self.move( direction )

def solve ( filename, knot_count, desc ):
	if knot_count <= 1:
		raise Exception( "knot_count too low" )
	knots = [ Knot( 0, 0 ) for _ in range( knot_count ) ]
	for line in open( filename, "r" ).readlines():
		direction, move_count = line.split( ' ' )
		for i in range( int( move_count ) ):
			knots[0].move( direction )
			for ix in range( 1, knot_count ):
				knots[ix].follow( knots[ix-1] );
	print( "%s: %d" % ( desc, knots[knot_count-1].history_size() ) )

solve( os.getenv( 'ADVENT_INPUT' ),  2, 'PART1' );
solve( os.getenv( 'ADVENT_INPUT' ), 10, 'PART2' );
