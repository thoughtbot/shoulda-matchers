set :css_dir, 'assets/stylesheets'
set :js_dir, 'assets/javascripts'
set :images_dir, 'assets/images'
set :fonts_dir, 'assets/fonts'

activate :directory_indexes

activate :external_pipeline,
  name: :webpack,
  command: build? ? 'yarn run build' : 'yarn run start',
  source: '.tmp/dist',
  latency: 1

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :asset_hash, ignore: [/\.jpg\Z/, /\.png\Z/]
end
