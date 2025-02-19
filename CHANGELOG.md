# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## 6.0.2 - 2025-02-13
### Changed
- Update docs

## 6.0.1 - 2025-02-13
### Changed
- Updated dependencies
- Added rexml as explicit dependency

## 6.0.0 - 2024-07-04
### Changed
- **breaking changes** Removed support for Rollbar configuration. `config.rollbar` is no longer supported.
- Added support for passing `error_reporting_func` as a config option.

## 5.3.4 - 2024-06-14
### Changed
- Updated dependencies

## 5.3.3 - 2024-06-14
### Changed
- Updated dependencies

## 5.3.2 - 2024-05-27
### Changed
- Updated dependencies

## 5.3.1 - 2024-05-16
### Changed
- Updated dependencies

## 5.3.0 - 2024-04-19
### Changed
- Updated dependencies

## 5.2.16 - 2024-03-28
### Changed
- Updated dependencies

## 5.2.15 - 2024-02-23
### Changed
- Updated dependencies

## 5.2.14 - 2024-02-05
### Changed
- Do not log message body when publishing. Message bodies may have PII like email addresses in them.

## 5.2.13 - 2024-01-26
### Changed
- Updated dependencies

## 5.2.12 - 2023-01-02
### Changed
- Updated dependencies

## 5.2.11 - 2023-12-01
### Changed
- Updated dependencies

## 5.2.10 - 2023-11-30
### Changed
- Support all currently supported versions of Ruby

## 5.2.9 - 2023-11-06
### Changed
- Updated dependencies

## 5.2.8 - 2023-10-13
### Changed
- Updated dependencies

## 5.2.7 - 2023-09-08
### Added
- Updated dependencies & fixed rubocop issues

## 5.2.6 - 2023-08-23
### Added
- Updated dependencies - CVE

## 5.2.4 - 2023-07-26
### Added
- chore: add changelog link to gemspec

## 5.2.3 - 2023-07-17
### Changed
- Updated dependencies

## 5.2.2 - 2023-07-14
### Changed
- Added SECURITY.md file to repo

## 5.2.1 - 2023-07-05
### Changed
- Updated dependencies

## 5.2.0 - 2023-07-05
### Changed
- Bumped min Ruby version to 3.2

## 5.1.14 - 2023-05-25
### Changed
- Updated dependencies

## 5.1.13 - 2023-04-14
### Changed
- Removed Ruby 2 support

## 5.1.12 - 2023-03-24
### Changed
- Updated dependencies

## 5.1.11 - 2023-03-14
### Changed
- Updated rack
- Update activesupport

## 5.1.10 - 2023-03-09
### Changed
- Updated rack

## 5.1.9 - 2023-02-24
### Changed
- Updated dependencies

## 5.1.8 - 2023-01-27
### Changed
- Updated dependencies

## 5.1.7 - 2023-01-20
### Changed
- Updated dependencies

## 5.1.6 - 2023-01-04
### Changed
- Updated dependencies

## 5.1.5 - 2023-01-03
### Changed
- Updated dependencies

## 5.1.4 - 2022-12-02
### Changed
- Updated dependencies

## 5.1.3 - 2022-11-08
### Changed
- Updated dependencies

## 5.1.2 - 2022-10-12
### Changed
- Updated dependencies

## 5.1.1 - 2022-09-09
### Changed
- Updated dependencies

## 5.1.0 - 2022-08-16
### Changed
- Added support for FIFO params when publishing to SNS topic

## 5.0.10 - 2022-08-12
### Changed
- Updated dependencies

## 5.0.9 - 2022-07-15
### Changed
- Updated dependencies

## 5.0.8 - 2022-06-20
### Changed
- Updated dependencies

## 5.0.7 - 2022-05-27
### Changed
- Updated rack

## 5.0.6 - 2022-05-26
### Changed
- Updated dependencies

## 5.0.5 - 2022-04-22
### Changed
- Updated dependencies

## 5.0.4 - 2022-04-01
### Changed
- Updated workflows

## 5.0.3 - 2022-03-25
### Changed
- Updated dependencies

## 5.0.2 - 2022-02-25
### Changed
- Updated dependencies

## 5.0.1 - 2022-02-02
### Changed
- Updated dependencies

## 5.0.0 - 2022-01-04
### Changed
- Remove RecusiveOpenStruct in favor of ResourceStruct::FlexStruct

## 4.1.1 - 2022-01-04
### Changed
- Updated dependencies

## 4.1.0 - 2021-12-31
### Changed
- Add Ruby 3 support

## 4.0.15 - 2021-12-03
### Changed
- Updated dependencies

## 4.0.14 - 2021-11-05
### Changed
- Update dependencies

## 4.0.13 - 2021-10-12
### Changed
- Update dependencies

## 4.0.12 - 2021-09-07
### Changed
- Update dependencies

## 4.0.11 - 2021-08-30
### Changed
- Update dependencies

## 4.0.10 - 2021-07-27
### Changed
- Update dependencies

## 4.0.9 - 2021-07-12
### Changed
- Update dependencies

## 4.0.8 - 2021-07-12
### Changed
- Update dependencies

## 4.0.7 - 2021-06-28
### Changed
- Update dependencies

## 4.0.6 - 2021-06-28
### Changed
- Update dependencies

## 4.0.5 - 2021-04-20
### Changed
- Update dependencies

## 4.0.4 - 2021-04-16
### Changed
- Migrate CI from CircleCI to GitHub Actions

## 4.0.3 - 2021-03-08
### Changed
- Update documentation to include instructions on directly publishing to SQS

## 4.0.2 - 2020-12-17
### Changed
- Bump local dev version, rubocop fixes, add backstage catalog file + sonarqube project settings

## 4.0.1 - 2020-03-23
### Fixed
- Fixes 4.0.0. Instead of expecting message attributes in the message from `poll`, retrieves them from the right place.

## 4.0.0 - 2020-03-18
### Changed
- Add the ability for SQS to receive message attributes
- `handle` function of `QueuePoller` now takes a third parameter `message_attributes`
- blocks or `MessageHandler`s passed to `QueuePoller` can use this `message_attributes`

## 3.4.0 - 2020-03-17
### Added
- Add the ability to pass message attributes to SNS

## 3.3.0 - 2019-07-09
### Added
- Add more friendly options for initializing queue pollers by either:
    - passing the message handler class; or
    - providing a handler block

## 3.2.0 - 2019-05-29
### Added
- Support for Pheme::TopicPublisher to publish to an explicit SNS client.

## 3.1.3 - 2019-02-14
### Fixed
- Increase code coverage to 100%.

## 3.1.2 - 2019-02-14
### Fixed
- Trying to recover code coverage, it only worked for first few builds.

## 3.1.1 - 2019-02-14
### Fixed
- Code coverage not reporting as expected, only report coverage on Ruby 2.5 build.

## 3.1.0 - 2019-02-14
### Added
- Code coverage tracker integration (coveralls.io).

## 3.0.1 - 2019-02-07
### Changed
- Minimum Ruby version required to be 2.4.

## 3.0.0 - 2019-02-07
### Changed
- Renamed gem to pheme, back to open source and published to Rubygems.

## 2.0.1 - 2019-01-03
### Changed
- add internal gem spec to test standard gem behavior, reduces unnecessary copy and pasting

### Fixed
- namespace for the VERSION constant was incorrectly set to Ws::Ws

## 2.0.0 - 2019-01-03
### Changed
- Renamed gem to ws-pheme, **breaking changes** due to new namespace.

## 1.3.1 - 2018-01-02
### Fixed
- only pull private gems from private nexus server

## 1.3.0 - 2018-12-31
### Added
- publish to private nexus server
