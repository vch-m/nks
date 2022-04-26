# frozen_string_literal: true

class ReliabilityIndicatorCalculator
  attr_reader :sample, :gamma, :time_trouble_free_operation, :time_trouble_operation

  INTERVAL_COUNTS = 10

  def initialize(sample, gamma, time_trouble_free_operation, time_trouble_operation)
    @sample = sample.sort
    @gamma = gamma
    @time_trouble_free_operation = time_trouble_free_operation
    @time_trouble_operation = time_trouble_operation
  end

  def launch
    puts "Середній наробіток до відмови Tср: #{calculate_tcp}"
    puts "γ-відсотковий наробіток на відмову Tγ при γ = #{gamma}, #{static_failure_time}"
    puts "ймовірність безвідмовної роботи на час #{time_trouble_free_operation} годин, #{probability_trouble_free_operation(time_trouble_free_operation)}"
    puts "інтенсивність відмов на час #{time_trouble_operation} годин, #{failure_intensity(time_trouble_operation)}"
  end

  private

  def calculate_tcp
    sample.sum.to_f / sample.length
  end

  def static_failure_time
    d = (interval_length * (probability_left - gamma) / (probability_left - probability_right))
    probabilities.index(probability_left) * interval_length - d
  end

  def probability_trouble_free_operation(time)
    integral = 1
    densities.each_with_index do |density, index|
      if time <= interval_length * (index + 1)
        integral -= density * (time - (interval_length * index))
        break
      else
        integral -= density * interval_length
      end
    end
    integral
  end

  def failure_intensity(time)
    density_range(time) / probability_trouble_free_operation(time)
  end

  def density_range(time)
    densities.each_with_index { |density, index| return density if time <= interval_length * (index + 1) }
  end

  def densities
    @densities ||= calculate_densities
  end

  def calculate_densities
    available_densities = []
    INTERVAL_COUNTS.times do |interval|
      available_densities << sample.select do |time|
        (interval * interval_length..(interval + 1) * interval_length).include?(time)
      end.length / (sample.length * interval_length)
    end
    available_densities
  end

  def probabilities
    @probabilities ||= calculate_probabilities
  end

  def calculate_probabilities
    available_probabilities = [1]
    densities.each { |density| available_probabilities << available_probabilities.last - density * interval_length }
    available_probabilities
  end

  def interval_length
    @interval_length ||= sample.max.to_f / INTERVAL_COUNTS
  end

  def probability_right
    probabilities.select { |probability| probability > gamma }.min
  end

  def probability_left
    probabilities.select { |probability| probability < gamma }.max
  end
end

a = [
  138, 951, 1584, 18, 1533, 3378, 130, 309,
  218, 338, 1052, 521, 818, 1095, 68, 1196,
  2618, 679, 506, 661, 172, 36, 1437, 700,
  190, 4926, 649, 1442, 7, 1177, 927, 1455,
  181, 337, 963, 7, 4658, 656, 1889, 1071,
  2348, 934, 82, 424, 55, 1458, 124, 180, 461,
  201, 329, 299, 864, 277, 636, 1403, 484,
  1541, 899, 2432, 1822, 523, 357, 2627, 212,
  20, 570, 7255, 916, 692, 755, 2370, 1340,
  34, 397, 1074, 67, 445, 1555, 492, 185, 461,
  1717, 1365, 1523, 1225, 188, 106, 541, 209,
  3118, 779, 442, 1608, 466, 1307, 1006, 298,
  143, 312
]

ReliabilityIndicatorCalculator.new(a, 0.96, 4206, 6867).launch
