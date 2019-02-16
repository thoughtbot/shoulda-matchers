# Site branch

This is the branch where the site for shoulda-matchers (located at
<http://matchers.shoulda.io>) is kept.

## Developing

* Install dependencies: `bin/setup`
* Start Middleman and Webpack: `bin/server`
* Make changes to files in `source/` and `assets/`
* View the changes at <http://localhost:4567>
* When finished, try building the site using `bundle exec middleman build`
* Assuming all goes well, publish your changes by running `bundle exec rake
  site:publish`
* That's it!
