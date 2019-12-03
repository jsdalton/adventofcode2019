def unfold(start, &block)
  Enumerator.new do |y|
    next_item = start
    loop do
      y << next_item
      next_item = block.call(next_item)
    end
  end
end

def calculate_fuel(mass)
  (mass / 3.0).floor - 2
end

puts(File
  .read('day-01.txt')
  .split("\n")
  .map(&:to_i)
  .map(&method(:calculate_fuel))
  .map do |mass|
    unfold(mass, &method(:calculate_fuel))
      .take_while(&:positive?)
      .reduce(:+)
  end
  .reduce(:+))
  #.map do |mass|
    #unfold(mass, &method(:calculate_fuel))
      #.take_while { |value| value > 0 }
      #.reduce(:+)
  #end
  #.map do |fuel|
    #unfold(fuel) { |extra| (mass / 3.0).floor - 2 }
  #end

