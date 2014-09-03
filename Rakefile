require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'appraisal'
require 'erb'
require_relative 'lib/shoulda/matchers/version'

CURRENT_VERSION = Shoulda::Matchers::VERSION

RSpec::Core::RakeTask.new do |t|
  t.ruby_opts = '-w -r ./spec/report_warnings'
  t.pattern = "spec/**/*_spec.rb"
  t.rspec_opts = '--color --format progress'
  t.verbose = false
end

Cucumber::Rake::Task.new do |t|
  options = []

  options << '--format' << (ENV['CUCUMBER_FORMAT'] || 'progress')

  if Bundler.definition.dependencies.none? { |dependency| dependency.name == 'spring' }
    options << '--profile' << 'without_spring'
  end

  t.fork = false
  t.cucumber_opts = options
end

task :default do
  if ENV['BUNDLE_GEMFILE'] =~ /gemfiles/
    Rake::Task['spec'].invoke
    Rake::Task['cucumber'].invoke
  else
    Rake::Task['appraise'].invoke
  end
end

task :appraise do
  exec 'appraisal install && appraisal rake'
end

GH_PAGES_DIR = '.gh-pages'

namespace :docs do
  file GH_PAGES_DIR do
    sh "git clone git@github.com:thoughtbot/shoulda-matchers.git #{GH_PAGES_DIR} --branch gh-pages"
  end

  task :setup => GH_PAGES_DIR do
    within_gh_pages do
      sh 'git fetch origin'
      sh 'git reset --hard origin/gh-pages'
    end
  end

  desc 'Generate docs for a particular version'
  task :generate, [:version, :latest_version] => :setup do |t, args|
    generate_docs(args.version, latest_version: latest_version)
  end

  desc 'Generate docs for a particular version and push them to GitHub'
  task :publish, [:version, :latest_version] => :setup do |t, args|
    generate_docs(args.version, latest_version: latest_version)
    publish_docs(args.version, latest_version: latest_version)
  end

  desc "Generate docs for version #{CURRENT_VERSION} and push them to GitHub"
  task :publish_latest => :setup do
    version = Gem::Version.new(CURRENT_VERSION)

    unless version.prerelease?
      latest_version = version.to_s
    end

    generate_docs(CURRENT_VERSION, latest_version: latest_version)
    publish_docs(CURRENT_VERSION, latest_version: latest_version)
  end

  def rewrite_index_to_inject_version(ref, version)
    within_gh_pages do
      filename = "#{ref}/index.html"
      content = File.read(filename)
      content.sub!(%r{<h1>shoulda-matchers.+</h1>}, "<h1>shoulda-matchers (#{version})</h1>")
      File.open(filename, 'w') {|f| f.write(content) }
    end
  end

  def generate_docs(version, options = {})
    ref = determine_ref_from(version)

    sh "rm -rf #{GH_PAGES_DIR}/#{ref}"
    sh "bundle exec yard -o #{GH_PAGES_DIR}/#{ref}"

    rewrite_index_to_inject_version(ref, version)

    within_gh_pages do
      sh "git add #{ref}"
    end

    if options[:latest_version]
      generate_file_that_redirects_to_latest_version(options[:latest_version])
    end
  end

  def publish_docs(version, options = {})
    message = build_commit_message(version)

    within_gh_pages do
      sh 'git clean -f'
      sh "git commit -m '#{message}'"
      sh 'git push'
    end
  end

  def generate_file_that_redirects_to_latest_version(version)
    ref = determine_ref_from(version)
    locals = { ref: ref }

    erb = ERB.new(File.read('doc_config/gh-pages/index.html.erb'))

    within_gh_pages do
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

  def within_gh_pages(&block)
    Dir.chdir(GH_PAGES_DIR, &block)
  end
end

task release: 'docs:publish_latest'
