[English](https://github.com/rrousselGit/provider/blob/master/README.md)

[![Build Status](https://travis-ci.org/rrousselGit/provider.svg?branch=master)](https://travis-ci.org/rrousselGit/provider)
[![pub package](https://img.shields.io/pub/v/provider.svg)](https://pub.dev/packages/provider) [![codecov](https://codecov.io/gh/rrousselGit/provider/branch/master/graph/badge.svg)](https://codecov.io/gh/rrousselGit/provider) [![Gitter](https://badges.gitter.im/flutter_provider/community.svg)](https://gitter.im/flutter_provider/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

[<img src="https://raw.githubusercontent.com/rrousselGit/provider/master/resources/flutter_favorite.png" width="200" />](https://flutter.dev/docs/development/packages-and-plugins/favorites)

A wrapper around [InheritedWidget]
to make them easier to use and more reusable.

By using `provider` instead of manually writing [InheritedWidget], you get:

- simplified allocation/disposal of resources
- lazy-loading
- a largely reduced boilerplate over making a new class every time
- devtools friendly
- a common way to consume these [InheritedWidget]s (See [Provider.of]/[Consumer]/[Selector])
- increased scalability for classes with a listening mechanism that grows exponentially
  in complexity (such as [ChangeNotifier], which is O(N²) for dispatching notifications).