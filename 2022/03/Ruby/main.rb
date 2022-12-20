#!/usr/bin/ruby3.0

letters = [*('a'..'z'),*('A'..'Z')]
i = 0
priorities = letters.map { |letter| i += 1; [ letter, i ] }.to_h

total = 0
File.readlines( ENV["ADVENT_INPUT"] ).each do |line|
	line = line.chomp
	first, second = line.chars.each_slice( line.length / 2 ).map( &:join )
	match = first.match /([#{second}])/
	total += priorities[match[1]]
end
puts( "PART1: %s" % [ total ] );

total = 0
File.readlines( ENV["ADVENT_INPUT"] ).each_slice(3) do |line|
	letters.each do |letter|
		if line[0].include? letter and
			line[1].include? letter and
			line[2].include? letter
			total += priorities[letter]
		end
	end
end
puts( "PART2: %s" % [ total ] );
