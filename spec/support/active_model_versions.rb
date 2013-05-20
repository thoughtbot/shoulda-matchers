RSpec.configure do |c|
  def active_model_3_0?
    ::ActiveModel::VERSION::MAJOR == 3 && ::ActiveModel::VERSION::MINOR >= 0
  end

  def active_model_3_1?
    ::ActiveModel::VERSION::MAJOR == 3 && ::ActiveModel::VERSION::MINOR >= 1
  end

  def active_model_3_2?
    ::ActiveModel::VERSION::MAJOR == 3 && ::ActiveModel::VERSION::MINOR >= 2
  end
end
