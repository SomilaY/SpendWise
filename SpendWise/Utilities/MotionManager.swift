import SwiftUI
import Combine
import CoreMotion   // Apple's framework for the phone's motion sensors

// An ObservableObject is a "broadcaster": whenever its values change, any
// view watching it refreshes. Think of a weather station announcing every
// change in the wind to everyone listening.
@MainActor
final class MotionManager: ObservableObject {
    // How far the phone is tilted, in radians (roughly -1 to 1 for normal tilting).
    // pitch = tilted forward/back, roll = tilted left/right.
    @Published var pitch: Double = 0
    @Published var roll: Double = 0

    private let manager = CMMotionManager()

    func start() {
        // The simulator has no sensors, so this safely does nothing there.
        guard manager.isDeviceMotionAvailable else { return }

        // Ask for 30 updates per second. That's smooth without draining battery.
        manager.deviceMotionUpdateInterval = 1.0 / 30.0

        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let motion else { return }

            // A spring animation smooths out the jittery raw sensor data,
            // so the card glides instead of shaking.
            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                self?.pitch = motion.attitude.pitch
                self?.roll = motion.attitude.roll
            }
        }
    }

    // Always switch sensors off when not needed. Like turning off a tap.
    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}
