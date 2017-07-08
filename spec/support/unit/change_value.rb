module UnitTests
  class ChangeValue
    def self.call(column_type, value, value_changer)
      new(column_type, value, value_changer).call
    end

    def initialize(column_type, value, value_changer)
      @column_type = column_type
      @value = value
      @value_changer = value_changer
    end

    def call
      if value_changer.is_a?(Proc)
        value_changer.call(value)
      elsif respond_to?(value_changer, true)
        send(value_changer)
      else
        value.public_send(value_changer)
      end
    end

    protected

    attr_reader :column_type, :value, :value_changer

    private

    def previous_value
      if value.is_a?(String)
        value[0..-2] + (value[-1].ord - 1).chr
      else
        value - 1
      end
    end

    def next_value
      if value.is_a?(Array)
        value + [value.first.class.new]
      elsif value.respond_to?(:next)
        value.next
      else
        value + 1
      end
    end

    def next_next_value
      change_value(change_value(value, :next_value), :next_value)
    end

    def next_value_or_numeric_value
      if value
        change_value(value, :next_value)
      else
        change_value(value, :numeric_value)
      end
    end

    def next_value_or_non_numeric_value
      if value
        change_value(value, :next_value)
      else
        change_value(value, :non_numeric_value)
      end
    end

    def never_falsy
      value || dummy_value_for_column
    end

    def truthy_or_numeric
      value || 1
    end

    def never_blank
      value.presence || dummy_value_for_column
    end

    def nil_to_blank
      value || ''
    end

    def always_nil
      nil
    end

    def add_character
      value + 'a'
    end

    def remove_character
      value.chop
    end

    def numeric_value
      '1'
    end

    def non_numeric_value
      'a'
    end

    def change_value(value, value_changer)
      self.class.call(column_type, value, value_changer)
    end

    def dummy_value_for_column
      Shoulda::Matchers::Util.dummy_value_for(column_type)
    end
  end
end
