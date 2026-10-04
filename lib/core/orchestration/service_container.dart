import 'orchestration_models.dart';

final class ServiceToken<T> {
  ServiceToken(String name) : name = name.trim() {
    if (this.name.isEmpty ||
        !RegExp(r'^[a-z0-9]+(?:[._-][a-z0-9]+)*$').hasMatch(this.name)) {
      throw ArgumentError.value(
        name,
        'name',
        'Service token must be a lowercase path token.',
      );
    }
  }

  final String name;

  @override
  String toString() => 'ServiceToken($name)';
}

final class ServiceContainer {
  final Map<String, _ServiceRegistration> _registrations =
      <String, _ServiceRegistration>{};
  bool _frozen = false;

  bool get isFrozen => _frozen;
  int get registrationCount => _registrations.length;

  void registerSingleton<T>(ServiceToken<T> token, T value) {
    _rejectAgentReference(value);
    _register(
      token.name,
      _SingletonRegistration(value),
    );
  }

  void registerFactory<T>(
    ServiceToken<T> token,
    T Function() factory,
  ) {
    _register(
      token.name,
      _FactoryRegistration(() {
        final value = factory();
        _rejectAgentReference(value);
        return value;
      }),
    );
  }

  void registerLazySingleton<T>(
    ServiceToken<T> token,
    T Function() factory,
  ) {
    _register(
      token.name,
      _LazySingletonRegistration(() {
        final value = factory();
        _rejectAgentReference(value);
        return value;
      }),
    );
  }

  T resolve<T>(ServiceToken<T> token) {
    final registration = _registrations[token.name];
    if (registration == null) {
      throw StateError(
        'No service registered for token ${token.name}.',
      );
    }

    final value = registration.resolve();
    if (value is! T) {
      throw StateError(
        'Service token ${token.name} resolved to '
        '${value.runtimeType}, expected requested type.',
      );
    }
    return value;
  }

  bool contains<T>(ServiceToken<T> token) =>
      _registrations.containsKey(token.name);

  void freeze() {
    _frozen = true;
  }

  void _register(
    String name,
    _ServiceRegistration registration,
  ) {
    if (_frozen) {
      throw StateError('ServiceContainer is frozen.');
    }
    if (_registrations.containsKey(name)) {
      throw StateError('Service token already registered: $name.');
    }
    _registrations[name] = registration;
  }
}

abstract interface class _ServiceRegistration {
  Object? resolve();
}

final class _SingletonRegistration implements _ServiceRegistration {
  const _SingletonRegistration(this.value);

  final Object? value;

  @override
  Object? resolve() => value;
}

final class _FactoryRegistration implements _ServiceRegistration {
  const _FactoryRegistration(this.factory);

  final Object? Function() factory;

  @override
  Object? resolve() => factory();
}

final class _LazySingletonRegistration implements _ServiceRegistration {
  _LazySingletonRegistration(this.factory);

  final Object? Function() factory;
  Object? _value;
  bool _initialized = false;

  @override
  Object? resolve() {
    if (!_initialized) {
      _value = factory();
      _initialized = true;
    }
    return _value;
  }
}

void _rejectAgentReference(Object? value) {
  if (value is AgentReferenceBoundary) {
    throw ArgumentError(
      'Direct agent references are forbidden in ServiceContainer. '
      'Use AgentEventBus streams instead.',
    );
  }
}
