### v1.8.1 (5/9/16)
[Issue #38](https://github.com/crismali/magic_lamp/issues/38): Prevented token errors in the JavaScript when there's an error with the fixtures and `all_fixtures` is being used in Sprockets.

### v1.8.0 (2/4/16)
[PR #36](https://github.com/crismali/magic_lamp/pull/36): Added support for Rails 5.0 beta. Some Travis CI and Appraisal changes happened to ensure better support for Rails 5 in the future. Plus a bunch of deprecation warnings were removed (what remains can't be dropped until support for Rails 4.X is dropped).

### v1.7.0 (12/2/15)
[Issue #32](https://github.com/crismali/magic_lamp/issues/32): MagicLamp now raises an error when it finds empty fixtures (in Ruby and JavaScript).

### v1.6.2 (10/6/15)
[PR #30](https://github.com/crismali/magic_lamp/pull/30): Avoid generating fixtures twice when using `//= require magic_lamp/all_fixtures`.
