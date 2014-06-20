watch('README.md') { system('bundle exec yard doc') }
watch('doc_config/yard/.*') { system('bundle exec yard doc') }
watch('lib/.*\.rb') { system('bundle exec yard doc') }

# vi: ft=ruby
