/// The base class of a polling mode configuration.
abstract class PollingMode {
  const PollingMode._();

  /// Creates a configured auto polling configuration.
  ///
  /// [autoPollInterval] sets at least how often this policy should fetch the latest configuration and refresh the cache.
  /// [maxInitWaitTime] sets the maximum waiting time between initialization and the first config acquisition in seconds.
  /// [listener] sets a configuration changed listener.
  factory PollingMode.autoPoll(
      {autoPollInterval = const Duration(seconds: 60),
      maxInitWaitTime = const Duration(seconds: 5)}) {
    return AutoPollingMode._(autoPollInterval, maxInitWaitTime);
  }

  /// Creates a configured lazy loading polling configuration.
  ///
  /// [cacheRefreshInterval] sets how long the cache will store its value before fetching the latest from the network again.
  factory PollingMode.lazyLoad(
      {cacheRefreshInterval = const Duration(seconds: 60)}) {
    return LazyLoadingMode._(cacheRefreshInterval);
  }

  /// Creates a configured manual polling configuration.
  factory PollingMode.manualPoll() {
    return ManualPollingMode._();
  }

  /// Gets the current polling mode's identifier.
  /// Used for analytical purposes in HTTP User-Agent headers.
  String getPollingIdentifier();

  /// The default polling mode used by [ConfigCatClient] when no mode is set.
  static const defaultMode =
      AutoPollingMode._(Duration(seconds: 60), Duration(seconds: 5));
}

/// Represents the auto polling mode's configuration.
class AutoPollingMode extends PollingMode {
  final Duration autoPollInterval;
  final Duration maxInitWaitTime;

  const AutoPollingMode._(this.autoPollInterval, this.maxInitWaitTime)
      : super._();

  @override
  String getPollingIdentifier() {
    return 'a';
  }
}

/// Represents the manual polling mode's configuration.
class ManualPollingMode extends PollingMode {
  const ManualPollingMode._() : super._();

  @override
  String getPollingIdentifier() {
    return 'm';
  }
}

/// Represents lazy loading mode's configuration.
class LazyLoadingMode extends PollingMode {
  final Duration cacheRefreshInterval;

  const LazyLoadingMode._(this.cacheRefreshInterval) : super._();

  @override
  String getPollingIdentifier() {
    return 'l';
  }
}
