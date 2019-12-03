program = File
  .read('day-02.txt')
  .strip
  .split(",")
  .map(&:to_i)

magic_number = 19690720

class Runner
  attr_reader :program

  def initialize(program)
    @program = program
    @pointer = 0
  end

  def run
    loop do
      case @program[@pointer]
      when 1
        add
      when 2
        multiply
      when 99
        break
      else
        raise "Invalid opcode at #{@pointer}: #{@program[@pointer]}!"
      end
    end
  end

  def add
    positions = @program[(@pointer + 1)..(@pointer + 3)]
    result = @program[positions[0]] + @program[positions[1]]
    @program[positions[2]] = result
    @pointer += 4
  end

  def multiply
    positions = @program[(@pointer + 1)..(@pointer + 3)]
    result = @program[positions[0]] * @program[positions[1]]
    @program[positions[2]] = result
    @pointer += 4
  end
end

(0..99).each do |noun|
  (0..99).each do |verb|
    attempt = program.dup
    attempt[1] = noun
    attempt[2] = verb
    runner = Runner.new(attempt)
    runner.run
    if runner.program[0] == magic_number
      puts 'Yes!'
      puts [noun, verb]
      puts runner.program[0]
      puts "#{((100 * noun) + verb)}"
    end
  end
end
