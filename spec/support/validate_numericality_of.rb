RSpec.configure do |c|
  def all_possible_combinations_of_greater_than_or_less_than_methods
    [:greater_than, :greater_than_or_equal_to].product([:less_than_or_equal_to, :less_than])
  end

  def all_possible_validate_numericality_of_methods
    [:greater_than, :greater_than_or_equal_to, :equal_to, :less_than, :less_than_or_equal_to]
  end
end

