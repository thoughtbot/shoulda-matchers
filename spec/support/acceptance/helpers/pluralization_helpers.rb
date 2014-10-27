module AcceptanceTests
  module PluralizationHelpers
    def pluralize(count, singular_version, plural_version = nil)
      plural_version ||= singular_version + 's'

      if count == 1
        "#{count} #{singular_version}"
      else
        "#{count} #{plural_version}"
      end
    end
  end
end
