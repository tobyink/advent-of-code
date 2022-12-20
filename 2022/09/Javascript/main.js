const Direction = {
	"U": 1,  // up
	"D": 2,  // down
	"L": 4,  // left
	"R": 8,  // right
};

class Knot {

	constructor ( row, col ) {
		this.row = row;
		this.col = col;
		this.history = {};
		this.track_history();
	}

	track_history () {
		let key = this.row + "," + this.col;
		this.history[key]++;
	}

	get history_size () {
		return Object.keys( this.history ).length;
	}

	move ( d ) {
		if ( d & Direction.U ) --this.row;
		if ( d & Direction.D ) ++this.row;
		if ( d & Direction.L ) --this.col;
		if ( d & Direction.R ) ++this.col;
		this.track_history();
	}

	follow ( other ) {
		if ( Math.abs( this.row - other.row ) <= 1
		&&   Math.abs( this.col - other.col ) <= 1 )
			return;
		let d = 0;
		if ( this.row > other.row ) d |= Direction.U;
		if ( this.row < other.row ) d |= Direction.D;
		if ( this.col > other.col ) d |= Direction.L;
		if ( this.col < other.col ) d |= Direction.R;
		this.move( d );
	}
}

function range ( start, stop, step ) {
	var a = [ start ], b = start;
	while ( b < stop ) {
		a.push( b += step || 1 );
	}
	return a;
}

function main ( filename, knot_count, desc ) {
	if ( knot_count < 2 ) {
		console.error( "knot_count too low" );
		return;
	}

	let knots = [];
	for ( var i of range( 0, knot_count - 1 ) ) {
		knots[i] = new Knot( 0, 0 );
	}

	require( 'fs' ).readFile( filename, 'utf8', ( err, input ) => {
		if ( err ) {
			console.error( err );
			return;
		}
		input.split( /\r?\n/ ).forEach( line => {
			let parts = line.split( ' ' );
			let d = parts[0];
			let move_count = parseInt( parts[1], 10 );
			for ( var i of range( 1, move_count ) ) {
				knots[0].move( Direction[d] );
				for ( let ix of range( 1, knot_count - 1 ) ) {
					knots[ix].follow( knots[ix - 1] );
				}
			}
		} );
		console.log( `${desc}: ${ knots[knot_count - 1].history_size }` );
	} );
}

main( process.env.ADVENT_INPUT, 2, "PART1" );
main( process.env.ADVENT_INPUT, 10, "PART2" );
