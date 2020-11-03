module AcceptanceTests
  module ArrayHelpers
    def to_sentence(array)
      case array.size
      when 1
        array[0]
      when 2
        array.join(' and ')
      else
        to_sentence(array[1..-2].join(', '), [array[-1]])
      end
    end
  end
end
