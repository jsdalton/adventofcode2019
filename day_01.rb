puts File
  .read('day-01.txt')
  .split("\n")
  .map(&:to_i)
  .map { |mass| mass / 3.0 }
  .map { |divided| divided.floor }
  .map { |subtracted| subtracted - 2 }
  .reduce(:+)
