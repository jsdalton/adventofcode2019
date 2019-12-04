require 'byebug'

program = File
  .read('day-03.txt')
  .strip
  .split("\n")
  .map { |wire| wire.split(',') }

class Runner
  attr_reader :wire1, :wire2

  def initialize(wire1, wire2)
    @central_point = [0, 0]
    @wire1 = {
      path: wire1,
      coverage: {},
      num_steps: 0,
      steps_to_intersections: {},
      current_position: @central_point.dup
    }
    @wire2 = {
      path: wire2,
      coverage: {},
      num_steps: 0,
      steps_to_intersections: {},
      current_position: @central_point.dup
    }
  end

  def run
    lay(@wire1)
    lay(@wire2)

    # Do it again to count steps
    @wire1[:current_position] = @central_point
    lay(@wire1, with_intersections: true)
    @wire2[:current_position] = @central_point
    lay(@wire2, with_intersections: true)
  end

  def closest_intersection
    populate_steps_for_intersections
    closest = intersections.keys.min do |a, b|
      intersections[a] <=> intersections[b]
    end
    intersections[closest]
  end

  def populate_steps_for_intersections
    intersections.keys.each do |point|
      intersections[point] = @wire1[:steps_to_intersections][point] + @wire2[:steps_to_intersections][point]
    end
  end

  def closest_distance
    distance_from_center(
      intersections.keys.min do |a, b|
        distance_from_center(a) <=> distance_from_center(b)
      end
    )
  end

  def intersections
    @intersections ||= @wire1[:coverage].reduce({}) do |matches, (wire1_x, wire1_ys)|
      wire1_ys.each do |wire1_y, _|
        if @wire2[:coverage].dig(wire1_x, wire1_y)
          matches[[wire1_x, wire1_y]] = true
        end
      end
      matches
    end
  end

  def distance_from_center(point)
    return nil unless point

    (point[0].abs - @central_point[0]) + (point[1].abs - @central_point[1])
  end

  private

  def lay(wire, with_intersections: false)
    wire[:path].each do |line|
      draw(line, wire: wire, with_intersections: with_intersections)
    end
  end

  def draw(line, wire:, with_intersections:)
    direction, length = line[0], line[1..-1]
    length.to_i.times do
      advance(direction, wire: wire, with_intersections: with_intersections)
    end
  end

  def advance(direction, wire:, with_intersections:)
    movement = case direction
               when 'U'
                 [0, 1]
               when 'R'
                 [1, 0]
               when 'D'
                 [0, -1]
               when 'L'
                 [-1, 0]
               else
                 raise 'Bad direction!'
               end
    new_position = [
      wire[:current_position][0] + movement[0],
      wire[:current_position][1] + movement[1]
    ]
    if wire[:coverage][new_position[0]].nil?
      wire[:coverage][new_position[0]] = { new_position[1] => true }
    else
      wire[:coverage][new_position[0]][new_position[1]] = true
    end
    wire[:current_position] = new_position
    return unless with_intersections

    wire[:num_steps] += 1
    return unless intersections.include?(new_position)

    wire[:steps_to_intersections][new_position] = wire[:num_steps]
  end
end

def main(program)
  runner = Runner.new(program[0], program[1])
  puts 'running...'
  runner.run
  puts runner.closest_distance
  puts runner.closest_intersection
end

if __FILE__ == $0
  main(program)
end

describe Runner do
  subject(:runner) { described_class.new(wire1, wire2) }

  let(:wire1) { ["R75", "D30", "R83", "U83", "L12", "D49", "R71", "U7", "L72"] }
  let(:wire2) { ["U62", "R66", "U55", "R34", "D71", "R55", "D58", "R83"] }
  let(:expected_distance) { 159 }

  it { is_expected.to be_an_instance_of(Runner) }

  describe 'run' do
    subject { runner.run }

    it do
      subject
      expect(runner.closest_distance).to eq(expected_distance)
    end

    context 'for closest intersection' do
      let(:wire1) { ["R75", "D30", "R83", "U83", "L12", "D49", "R71", "U7", "L72"] }
      let(:wire2) { ["U62", "R66", "U55", "R34", "D71", "R55", "D58", "R83"] }
      let(:expected_steps) { 610 }

      it do
        subject
        expect(runner.closest_intersection).to eq(expected_steps)
      end
    end
  end
end
