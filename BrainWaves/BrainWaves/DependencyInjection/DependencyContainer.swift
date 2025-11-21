//
//  DependencyContainer.swift
//  BrainWaves
//
//  Dependency injection container for managing app dependencies
//  Enables testability and loose coupling between components
//

import Foundation

/// Protocol for resolvable dependencies
protocol DependencyResolvable {
    func resolve<T>(_ type: T.Type) -> T
}

/// Main dependency injection container
final class DependencyContainer: DependencyResolvable {
    static let shared = DependencyContainer()

    private var factories: [String: () -> Any] = [:]
    private var singletons: [String: Any] = [:]

    private init() {
        registerDefaults()
    }

    /// Register a factory that creates a new instance every time
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }

    /// Register a singleton instance
    func registerSingleton<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        singletons[key] = instance
    }

    /// Register a singleton factory (lazy initialization)
    func registerSingleton<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = { [weak self] in
            if let existing = self?.singletons[key] as? T {
                return existing
            }
            let instance = factory()
            self?.singletons[key] = instance
            return instance
        }
    }

    /// Resolve a dependency
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)

        // Check if singleton exists
        if let singleton = singletons[key] as? T {
            return singleton
        }

        // Check if factory exists
        guard let factory = factories[key] else {
            fatalError("No registration found for type \(type). Did you forget to register it?")
        }

        guard let instance = factory() as? T else {
            fatalError("Failed to cast resolved instance to \(type)")
        }

        return instance
    }

    /// Register default dependencies
    private func registerDefaults() {
        // Persistence
        registerSingleton(PresetStoreProtocol.self, instance: PresetStore.shared)
        registerSingleton(SettingsManagerProtocol.self, instance: SettingsManager.shared)

        // Managers
        registerSingleton(AudioSessionManagerProtocol.self, instance: AudioSessionManager.shared)
        registerSingleton(HapticManagerProtocol.self, instance: HapticManager.shared)
        registerSingleton(PresetCoordinatorProtocol.self, instance: PresetCoordinator.shared)

        // Generators (factories - create new instances)
        register(BinauralBeatsGeneratorProtocol.self) {
            BinauralBeatsGenerator()
        }
        register(IsochronicTonesGeneratorProtocol.self) {
            IsochronicTonesGenerator()
        }
    }

    /// Reset container (useful for testing)
    func reset() {
        factories.removeAll()
        singletons.removeAll()
        registerDefaults()
    }
}

/// Property wrapper for dependency injection
@propertyWrapper
struct Injected<T> {
    private let container: DependencyResolvable

    var wrappedValue: T {
        container.resolve(T.self)
    }

    init(container: DependencyResolvable = DependencyContainer.shared) {
        self.container = container
    }
}
