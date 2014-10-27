require_relative 'base_helpers'

module AcceptanceTests
  module FileHelpers
    include BaseHelpers

    def append_to_file(path, content, options = {})
      fs.append_to_file(path, content, options)
    end

    def append_to_file_following(path, content_to_add, insertion_point)
      fs.append_to_file_following(path, content_to_add, insertion_point)
    end

    def remove_from_file(path, pattern)
      fs.remove_from_file(path, pattern)
    end

    def write_file(path, content)
      fs.write(path, content)
    end
  end
end
