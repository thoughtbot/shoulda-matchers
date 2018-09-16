# Maintaining Shoulda Matchers

As maintainers of the gem, this is our guide. Most of the steps and guidelines
in the [Contributing](CONTRIBUTING.md) document apply here, including how to set
up your environment, write code to fit the code style, run tests, craft commits
and manage branches. Beyond this, this document provides some details that would
be too low-level for contributors.

## Communication

We use a combination of methods to communicate with each other:

* In planning major releases, it can be helpful to create a **new issue**
  outlining the changes as well as steps needed to launch the release. This
  serves both as an announcement to the community as well as an area to keep a
  checklist.
* To track progress for the next release, **GitHub milestones** are useful.
* To track progress on the movement of issues, [**labels**](#addendum-labels)
  are useful.
* To communicate small-scale changes, **pull requests** are effective, as
  mentioned above.
* To communicate large-scale changes or explain topics, **email** is best.

## Managing the community

As anyone who has played a sim game before, it's important to make your patrons
happy. We do this by:

* Answering questions from members of the community
* Closing stale issues and feature requests
* Keeping the community informed by ensuring that the changelog is up to date
* Ensuring that the inline documentation, as well as the docsite, is kept up to
  date

## Workflow

We generally follow [GitHub Flow]. The `master` branch is the main line, and all
branches are cut from and get merged back into this branch. Generally, the
workflow is as follows:

[GitHub Flow]: https://help.github.com/articles/github-flow/

* Cut a feature or bugfix branch from this branch.
* Upon completing a branch, create a PR and ask another maintainer to approve
  it.
* Try to keep the commit history as clean as possible. Before merging, squash
  "WIP" or related commits together and rebase as needed.
* Once your PR is approved and you've cleaned up your branch, you're free to
  merge it in.

## Architecture

Besides the matchers, there are files in `lib` which you may need to reference
or update:

* `lib/shoulda/matchers/doublespeak*` -- a small handrolled mocking library
  which is used by the `permit` matcher
* `lib/shoulda/matchers/util*` -- extra methods which are used in various places
  to detect library versions, wrap/indent text, and more

## Updating the changelog

After every user-facing change makes it into master, we make a note of it in the
changelog, which for historical reasons is kept in `NEWS.md`. The changelog is
sorted in reverse order by release version, with the topmost version as the next
release (tagged as "(Unreleased)").

Within each version, there are five available categories you can divide changes
into. They are all optional but they should appear in this order:

1. Backward-compatible changes
1. Deprecations
1. Bug fixes
1. Features
1. Improvements

Within each category section, the changes relevant to that category are listed
in chronological order.

For each change, provide a human-readable description of the change as well as a
linked reference to the PR where that change emerged (or the commit ID if no
such PR is available). This helps users cross-reference changes if they need to.

## Documentation

### Generating documentation

As mentioned in the Contributing document, we use YARD for documentation. YARD
is configured via `.yardopts` to process the Ruby files in `lib/` as well as
`NEWS.md` and the Markdown files in `docs/` and write the documentation in HTML
form to `doc`. This command will do exactly that:

```bash
bundle exec yard doc
```

However, if you're actively updating the documentation, it's more helpful to
launch a process that will watch the aforementioned source files for changes and
generate the HTML for you automatically:

```bash
bundle exec rake docs:autogenerate
```

Whichever approach you take, you can view the generated docs locally by running:

```bash
open doc/index.html
```

### About the docsite

The docfiles that YARD generates are published to the docsite, which is located
at:

<https://matchers.shoulda.io/docs>

The docsite is hosted on GitHub Pages*. As such, the `gh-pages` branch hosts the
code for the docsite. This branch is written to automatically by the
`docs:publish` and `docs:publish_latest` tasks.

The URL above actually links to a bare-bones HTML page which merely serves to
automatically redirect the visitor to the docs for the latest published version
of the gem. This version is hardcoded in the HTML page, but is also updated
automatically by the `docs:publish` and `docs:publish_latest` tasks.

*\* thoughtbot owns <https://shoulda.io>, and
they've got `matchers.shoulda.io` set up on the DNS level as an alias for
`thoughtbot.github.io/shoulda-matchers`.*

## Versioning

### Naming a new version

As designated in the README, we follow [SemVer 2.0][semver]. This offers a
meaningful baseline for deciding how to name versions. Generally speaking:

[semver]: https://semver.org/spec/v2.0.0.html

* We bump the "major" part of the version if we're introducing
  backward-incompatible changes (e.g. changing the API or core behavior,
  removing parts of the API, or dropping support for a version of Ruby).
* We bump the "minor" part if we're adding a new feature (e.g. adding a new
  matcher or adding a new qualifier to a matcher).
* We bump the "patch" part if we're merely including bugfixes.

In addition to major, minor, and patch levels, you can also append a
suffix to the version for pre-release versions. We usually use this to issue
release candidates prior to an actual release. A version number in this case
might look like `4.0.0.rc1`.

### Releasing a new version

Releasing a new version is very simple:

1. First, you'll want to be given ownership permissions for the Ruby gem itself.
   If you want to give someone else these rights, you can use:

   ```bash
   gem owner shoulda-matchers -a <email address>
   ```
1. Next, you'll want to update the `VERSION` constant in
   `lib/shoulda/matchers/version.rb`. This constant is referenced in the gemspec
   and is used in the Rake tasks to publish the gem on RubyGems as well as
   generate documentation.
1. Finally, you'll want to run:

   ```bash
   rake release
   ```

   This will not only push the gem to RubyGems, but also update the docsite.

### Re-publishing docs

In general you'll use the `release` task to update the docsite, but there may be
a situation where you'll need to do it manually.

You can re-publish the docs for the latest version (as governed by
`lib/shoulda/matchers/version.rb`) by running:

```bash
bundle exec rake docs:publish_latest
```

This will update the version to which the docsite auto-redirects to the latest
version. For instance, if the latest version were 4.0.0, this command would
publish the docs at <https://matchers.shoulda.io/docs/v4.0.0> but redirect
<https://matchers.shoulda.io/docs> to this location.

However, if you want to publish the docs for a version and at the same
time manually set the auto-redirected version, you can run this instead:

```bash
bundle exec rake docs:publish[version, latest_version]
```

Here, `version` and `latest_version` are both version strings. For instance, you
might say:

```bash
bundle exec rake docs:publish[4.0.0, 3.7.2]
```

This would publish the docs for 4.0.0 at
<https://matchers.shoulda.io/docs/v4.0.0>, but redirect
<https://matchers.shoulda.io/docs> to <https://matchers.shoulda.io/docs/v3.7.2>.

## Addendum: Labels

In order to corral the issue and PR backlog, we've found
[labels] to be useful for cataloguing and tracking progress purposes. Over time
we've added quite a collection of labels. Here's a quick list:

[labels]: https://github.com/thoughtbot/shoulda-matchers/labels

### Labels for issues

* **Issue: Bug**
* **Issue: Feature Request**
* **Issue: Need to Investigate** -- if we don't know whether a bug is legitimate
  or not
* **Issue: PR Needed** -- perhaps unnecessary, but it does signal to the
  community that we'd love a PR

### Labels for PRs

* **PR: Bugfix**
* **PR: Feature**
* **PR: Good to Merge** -- most of the time not necessary, but can be helpful in
  a code freeze before a release to mark PRs that we will include in the next
  release
* **PR: In Progress** -- used to mark PRs that are still being worked on by the
  PR author
* **PR: Needs Documentation**
* **PR: Needs Review**
* **PR: Needs Tests**
* **PR: Needs Updates Before Merge** -- along the same lines as the other
  "Needs" tags, but more generic

### Generic labels

* **Blocked**
* **Documentation**
* **Needs Decision**
* **Needs Revisiting**
* **Question**
* **Rails X**
* **Ruby X.Y**
* **UX**
