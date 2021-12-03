# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- Update documentation to include instructions on directly publishing to SQS

## 4.0.2 - 2020-12-17
- Bump local dev version, rubocop fixes, add backstage catalog file + sonarqube project settings

## 4.0.1 - 2020-03-23
### Fixes
- Fixes 4.0.0. Instead of expecting message attributes in the message from `poll`, retrieves them from the right place.

## 4.0.0 - 2020-03-18
### Breaking Changes
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
