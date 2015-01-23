require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'appraisal'
require 'erb'
require_relative 'lib/shoulda/matchers/version'

RSpec::Core::RakeTask.new('spec:unit') do |t|
  t.ruby_opts = '-w -r ./spec/report_warnings'
  t.pattern = "spec/unit/**/*_spec.rb"
  t.rspec_opts = '--color --format progress'
  t.verbose = false
end

RSpec::Core::RakeTask.new('spec:acceptance') do |t|
  t.ruby_opts = '-w -r ./spec/report_warnings'
  t.pattern = "spec/acceptance/**/*_spec.rb"
  t.rspec_opts = '--color --format progress'
  t.verbose = false
end

task :default do
  if ENV['BUNDLE_GEMFILE'] =~ /gemfiles/
    sh 'rake spec:unit'
    sh 'rake spec:acceptance'
  else
    Rake::Task['appraise'].invoke
  end
end

task :appraise do
  exec 'appraisal install && appraisal rake'
end

CURRENT_VERSION = Shoulda::Matchers::VERSION
GH_PAGES_DIR = '.gh-pages'
# GITHUB_USERNAME = 'thoughtbot'
GITHUB_USERNAME = 'mcmire'

namespace :docs do
  file GH_PAGES_DIR do
    create_reference_to_gh_pages_branch
  end

  task :setup => GH_PAGES_DIR do
    reset_repo_directory
  end

  desc 'Generate docs for a particular version'
  task :generate, [:version, :latest_version] => :setup do |t, args|
    generate_docs_for(args.version, latest_version: latest_version)
  end

  desc 'Generate docs for a particular version and push them to GitHub'
  task :publish, [:version, :latest_version] => :setup do |t, args|
    generate_docs_for(args.version, latest_version: latest_version)
    publish_docs_for(args.version, latest_version: latest_version)
  end

  desc "Generate docs for version #{CURRENT_VERSION} and push them to GitHub"
  task :publish_latest => :setup do
    version = Gem::Version.new(CURRENT_VERSION)
    options = {}

    unless version.prerelease?
      options[:latest_version] = version.to_s
    end

    generate_docs_for(CURRENT_VERSION, options)
    publish_docs_for(CURRENT_VERSION, options)
  end

  def create_reference_to_gh_pages_branch
    sh "git clone git@github.com:#{GITHUB_USERNAME}/shoulda-matchers.git #{GH_PAGES_DIR} --branch gh-pages"
  end

  def reset_repo_directory
    within_gh_pages_dir do
      sh 'git fetch origin'
      sh 'git reset --hard origin/gh-pages'
    end
  end

  def add_version_to_index_page_for(ref, version)
    within_gh_pages_dir do
      filename = "#{ref}/index.html"
      content = File.read(filename)
      content.sub!(%r{<h1>shoulda-matchers.+</h1>}, "<h1>shoulda-matchers (#{version})</h1>")
      File.open(filename, 'w') {|f| f.write(content) }
    end
  end

  def generate_docs_for(version, options = {})
    ref = determine_ref_from(version)

    sh "rm -rf #{GH_PAGES_DIR}/#{ref}"
    sh "bundle exec yard -o #{GH_PAGES_DIR}/#{ref}"

    add_version_to_index_page_for(ref, version)

    within_gh_pages_dir do
      sh "git add #{ref}"
    end

    if options[:latest_version]
      generate_file_that_redirects_to_latest_version(options[:latest_version])
    end
  end

  def publish_docs_for(version, options = {})
    message = build_commit_message(version)

    within_gh_pages_dir do
      sh 'git clean -f'
      sh "git commit -m '#{message}'"
      sh 'git push origin gh-pages'
    end
  end

  def generate_file_that_redirects_to_latest_version(version)
    ref = determine_ref_from(version)
    locals = { ref: ref }

    erb = ERB.new(File.read('doc_config/gh-pages/index.html.erb'))

    within_gh_pages_dir do
      File.open('index.html', 'w') { |f| f.write(erb.result(binding)) }
      sh 'git add index.html'
    end
  end

  def determine_ref_from(version)
    if version =~ /^\d+\.\d+\.\d+/
      'v' + version
    else
      version
    end
  end

  def build_commit_message(version)
    "Regenerated docs for version #{version}"
  end

  def within_gh_pages_dir(&block)
    Dir.chdir(GH_PAGES_DIR, &block)
  end
end

task release: 'docs:publish_latest'
