class Knot
	attr_reader :row, :col

	def initialize ( row, col )
		@row, @col, @history = row, col, Hash.new()
		track_history()
	end

	def track_history
		key = "#{ @row },#{ @col }"
		@history[key] = 1
	end

	def history_size
		@history.count
	end

	def move ( direction )
		@row -= 1 if direction =~ /U/
		@row += 1 if direction =~ /D/
		@col -= 1 if direction =~ /L/
		@col += 1 if direction =~ /R/
		track_history()
	end

	def follow ( other )
		return if ( @row - other.row ).abs <= 1 && ( @col - other.col ).abs <= 1
		direction = '';
		direction += 'U' if @row > other.row
		direction += 'D' if @row < other.row
		direction += 'L' if @col > other.col
		direction += 'R' if @col < other.col
		move( direction )
	end
end

def solve ( filename, knot_count )
	knot_count > 1 or die()
	knots = ( 1 .. knot_count ).map { Knot.new( 0, 0 ) }
	File.readlines( filename ).each do |line|
		direction, move_count = line.split( ' ' )
		for i in 1 .. move_count.to_i do
			knots[0].move( direction )
			(1 .. knot_count - 1).each { |ix| knots[ix].follow( knots[ix-1] ) }
		end
	end
	puts "Tail history: #{ knots[knot_count-1].history_size }"
end

solve( "input.txt", 2 );
solve( "input.txt", 10 );
