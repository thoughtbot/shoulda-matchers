module AcceptanceTests
  module RspecHelpers
    include GemHelpers

    def rspec_rails_version
      bundle_version_of('rspec-rails')
    end

    def add_rspec_file(path, content)
      content = "require '#{spec_helper_require_path}'\n#{content}"
      write_file path, content
    end

    def spec_helper_require_path
      if rspec_rails_version >= 3
        'rails_helper'
      else
        'spec_helper'
      end
    end

    def spec_helper_file_path
      "spec/#{spec_helper_require_path}.rb"
    end
  end
end
