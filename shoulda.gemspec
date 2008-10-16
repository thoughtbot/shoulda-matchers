# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{shoulda}
  s.version = "2.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tammer Saleh"]
  s.date = %q{2008-10-15}
  s.default_executable = %q{convert_to_should_syntax}
  s.email = %q{tsaleh@thoughtbot.com}
  s.executables = ["convert_to_should_syntax"]
  s.extra_rdoc_files = ["README.rdoc", "CONTRIBUTION_GUIDELINES.rdoc"]
  s.files = ["CONTRIBUTION_GUIDELINES.rdoc", "MIT-LICENSE", "Rakefile", "README.rdoc", "bin/convert_to_should_syntax", "lib/shoulda", "lib/shoulda/action_mailer", "lib/shoulda/action_mailer/assertions.rb", "lib/shoulda/action_mailer.rb", "lib/shoulda/active_record", "lib/shoulda/active_record/assertions.rb", "lib/shoulda/active_record/macros.rb", "lib/shoulda/active_record.rb", "lib/shoulda/assertions.rb", "lib/shoulda/context.rb", "lib/shoulda/controller", "lib/shoulda/controller/formats", "lib/shoulda/controller/formats/html.rb", "lib/shoulda/controller/formats/xml.rb", "lib/shoulda/controller/helpers.rb", "lib/shoulda/controller/macros.rb", "lib/shoulda/controller/resource_options.rb", "lib/shoulda/controller.rb", "lib/shoulda/helpers.rb", "lib/shoulda/macros.rb", "lib/shoulda/private_helpers.rb", "lib/shoulda/proc_extensions.rb", "lib/shoulda/rails.rb", "lib/shoulda/tasks", "lib/shoulda/tasks/list_tests.rake", "lib/shoulda/tasks/yaml_to_shoulda.rake", "lib/shoulda/tasks.rb", "lib/shoulda.rb", "rails/init.rb", "test/fail_macros.rb", "test/fixtures", "test/fixtures/addresses.yml", "test/fixtures/friendships.yml", "test/fixtures/posts.yml", "test/fixtures/products.yml", "test/fixtures/taggings.yml", "test/fixtures/tags.yml", "test/fixtures/users.yml", "test/functional", "test/functional/posts_controller_test.rb", "test/functional/users_controller_test.rb", "test/other", "test/other/context_test.rb", "test/other/convert_to_should_syntax_test.rb", "test/other/helpers_test.rb", "test/other/private_helpers_test.rb", "test/other/should_test.rb", "test/rails_root", "test/rails_root/app", "test/rails_root/app/controllers", "test/rails_root/app/controllers/application.rb", "test/rails_root/app/controllers/posts_controller.rb", "test/rails_root/app/controllers/users_controller.rb", "test/rails_root/app/helpers", "test/rails_root/app/helpers/application_helper.rb", "test/rails_root/app/helpers/posts_helper.rb", "test/rails_root/app/helpers/users_helper.rb", "test/rails_root/app/models", "test/rails_root/app/models/address.rb", "test/rails_root/app/models/dog.rb", "test/rails_root/app/models/flea.rb", "test/rails_root/app/models/friendship.rb", "test/rails_root/app/models/post.rb", "test/rails_root/app/models/product.rb", "test/rails_root/app/models/tag.rb", "test/rails_root/app/models/tagging.rb", "test/rails_root/app/models/user.rb", "test/rails_root/app/views", "test/rails_root/app/views/layouts", "test/rails_root/app/views/layouts/posts.rhtml", "test/rails_root/app/views/layouts/users.rhtml", "test/rails_root/app/views/layouts/wide.html.erb", "test/rails_root/app/views/posts", "test/rails_root/app/views/posts/edit.rhtml", "test/rails_root/app/views/posts/index.rhtml", "test/rails_root/app/views/posts/new.rhtml", "test/rails_root/app/views/posts/show.rhtml", "test/rails_root/app/views/users", "test/rails_root/app/views/users/edit.rhtml", "test/rails_root/app/views/users/index.rhtml", "test/rails_root/app/views/users/new.rhtml", "test/rails_root/app/views/users/show.rhtml", "test/rails_root/config", "test/rails_root/config/boot.rb", "test/rails_root/config/database.yml", "test/rails_root/config/environment.rb", "test/rails_root/config/environments", "test/rails_root/config/environments/sqlite3.rb", "test/rails_root/config/initializers", "test/rails_root/config/initializers/new_rails_defaults.rb", "test/rails_root/config/initializers/shoulda.rb", "test/rails_root/config/routes.rb", "test/rails_root/db", "test/rails_root/db/migrate", "test/rails_root/db/migrate/001_create_users.rb", "test/rails_root/db/migrate/002_create_posts.rb", "test/rails_root/db/migrate/003_create_taggings.rb", "test/rails_root/db/migrate/004_create_tags.rb", "test/rails_root/db/migrate/005_create_dogs.rb", "test/rails_root/db/migrate/006_create_addresses.rb", "test/rails_root/db/migrate/007_create_fleas.rb", "test/rails_root/db/migrate/008_create_dogs_fleas.rb", "test/rails_root/db/migrate/009_create_products.rb", "test/rails_root/db/migrate/010_create_friendships.rb", "test/rails_root/db/schema.rb", "test/rails_root/log", "test/rails_root/log/sqlite3.log", "test/rails_root/public", "test/rails_root/public/404.html", "test/rails_root/public/422.html", "test/rails_root/public/500.html", "test/rails_root/script", "test/rails_root/script/console", "test/rails_root/script/generate", "test/rails_root/vendor", "test/rails_root/vendor/plugins", "test/README", "test/test_helper.rb", "test/unit", "test/unit/address_test.rb", "test/unit/dog_test.rb", "test/unit/flea_test.rb", "test/unit/friendship_test.rb", "test/unit/post_test.rb", "test/unit/product_test.rb", "test/unit/tag_test.rb", "test/unit/tagging_test.rb", "test/unit/user_test.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://thoughtbot.com/projects/shoulda}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{shoulda}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Making tests easy on the fingers and eyes}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.0.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.0.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.0.0"])
  end
end
