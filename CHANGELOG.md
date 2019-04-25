# Changelog

All notable changes to this project will be documented in this file.

## [v0.7.3](https://github.com/voxpupuli/hiera-eyaml-gpg/tree/v0.7.3) (2019-04-25)

[Full Changelog](https://github.com/voxpupuli/hiera-eyaml-gpg/compare/v0.7.2...v0.7.3)

**Fixed bugs:**

- Fix uninitialized constant `Hiera::Backend::Eyaml::Encryptors::GpgVer… [\#65](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/65) ([alexjfisher](https://github.com/alexjfisher))

## [v0.7.2](https://github.com/voxpupuli/hiera-eyaml-gpg/tree/v0.7.2) (2019-04-24)

[Full Changelog](https://github.com/voxpupuli/hiera-eyaml-gpg/compare/v0.7.1...v0.7.2)

**Fixed bugs:**

- Remove gem dependency on `puppet` [\#63](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/63) ([alexjfisher](https://github.com/alexjfisher))

## [v0.7.1](https://github.com/voxpupuli/hiera-eyaml-gpg/tree/v0.7.1) (2019-04-24)

[Full Changelog](https://github.com/voxpupuli/hiera-eyaml-gpg/compare/v0.7.0...v0.7.1)

**Merged pull requests:**

- Use correct travis-ci.com secret [\#61](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/61) ([alexjfisher](https://github.com/alexjfisher))

## [v0.7.0](https://github.com/voxpupuli/hiera-eyaml-gpg/tree/v0.7.0) (2019-04-24)

[Full Changelog](https://github.com/voxpupuli/hiera-eyaml-gpg/compare/vp_migration...v0.7.0)

This is the first release of `hiera-eyaml-gpg` since the project was migrated to [Vox Pupuli](https://voxpupuli.org/).  We're pleased to announce that this project should now work with Puppet 6 (jruby 9k puppetserver).  Special thanks to [seanmil](https://github.com/seanmil) for his work on this.

From this point onwards, all releases made to rubygems will have corresponding tags in the github project and a changelog will be maintained with [GitHub Changelog Generator](https://github.com/github-changelog-generator/github-changelog-generator).  The project will use [semantic versioning](https://semver.org/).

**Implemented enhancements:**

- Expose plugin version [\#58](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/58) ([alexjfisher](https://github.com/alexjfisher))
- Use Puppet::Util::Execution for RubyGpg [\#48](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/48) ([seanmil](https://github.com/seanmil))
- Allow gnupghome to be set from an environment variable [\#46](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/46) ([seanmil](https://github.com/seanmil))

**Fixed bugs:**

- blank lines in a recipients file results in the first key in the being used to encrypt the secrets [\#37](https://github.com/voxpupuli/hiera-eyaml-gpg/issues/37)
- Fix `uninitialized constant Puppet \(NameError\)` [\#55](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/55) ([alexjfisher](https://github.com/alexjfisher))
- Make the list of keys to encrypt with accurate [\#38](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/38) ([grahamhar](https://github.com/grahamhar))

**Merged pull requests:**

- Refactoring and fixing of remaining rubocop violations [\#57](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/57) ([alexjfisher](https://github.com/alexjfisher))
- Fix `\<module:Encryptors\>: Gpg is not a class \(TypeError\)` [\#56](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/56) ([alexjfisher](https://github.com/alexjfisher))
- Document installation of gems on puppetserver [\#53](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/53) ([ghoneycutt](https://github.com/ghoneycutt))
- Document usage with Hiera 5 [\#51](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/51) ([ghoneycutt](https://github.com/ghoneycutt))
- Document which versions of Puppet this should work with [\#50](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/50) ([ghoneycutt](https://github.com/ghoneycutt))

## v0.6 (2015-09-10)

**Implemented enhancements:**

- Improve GPG home handling [\#30](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/30) ([sihil](https://github.com/sihil))
- Add support for comments in hiera-eyaml-gpg.recipients file [\#29](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/29) ([tampakrap](https://github.com/tampakrap))

**Fixed bugs:**

- Add missing curly brace. [\#31](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/31) ([danny-cheung](https://github.com/danny-cheung))

## v0.5 (2015-03-21)

**Implemented enhancements:**

- Adapt code for Puppetserver [\#24](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/24) ([raphink](https://github.com/raphink))
- Set GPG home directory without an environment variable [\#19](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/19) ([mattbostock](https://github.com/mattbostock))

**Closed issues:**

- Support for puppetserver \(jruby\) [\#23](https://github.com/voxpupuli/hiera-eyaml-gpg/issues/23)

## [v0.4](https://github.com/voxpupuli/hiera-eyaml-gpg/tree/v0.4) (2013-11-26)

[Full Changelog](https://github.com/voxpupuli/hiera-eyaml-gpg/compare/v0.3...v0.4)

**Closed issues:**

- Encryption should fail if don't have hiera-gpg key on my keyring [\#7](https://github.com/voxpupuli/hiera-eyaml-gpg/issues/7)

**Merged pull requests:**

- \[FIX\] keys map not being set correctly [\#9](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/9) ([rooprob](https://github.com/rooprob))

## [v0.3](https://github.com/voxpupuli/hiera-eyaml-gpg/tree/v0.3) (2013-11-22)

[Full Changelog](https://github.com/voxpupuli/hiera-eyaml-gpg/compare/709b12bcd637a18672847946c410701d32096e0c...v0.3)

**Implemented enhancements:**

- Use gpg-agent when using the edit option [\#2](https://github.com/voxpupuli/hiera-eyaml-gpg/issues/2)

**Merged pull requests:**

- Fix typo. [\#5](https://github.com/voxpupuli/hiera-eyaml-gpg/pull/5) ([javins](https://github.com/javins))


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
