//
//  AKCombFilter.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/** This filter reiterates input with an echo density determined by loopDuration. The attenuation rate is independent and is determined by reverbDuration, the reverberation duration (defined as the time in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude). Output from a comb filter will appear only after loopDuration seconds. */
public class AKCombFilter: AKOperation {

    // MARK: - Properties

    private var internalAU: AKCombFilterAudioUnit?
    private var token: AUParameterObserverToken?

    private var reverbDurationParameter: AUParameter?

    /** The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude. (aka RT-60). */
    public var reverbDuration: Float = 1.0 {
        didSet {
            reverbDurationParameter?.setValue(reverbDuration, originator: token!)
        }
    }

    // MARK: - Initializers

    /** Initialize this filter operation */
    public init(_ input: AKOperation) {
        super.init()

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x636f6d62 /*'comb'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKCombFilterAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKCombFilter",
            version: UInt32.max)

        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.output = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKCombFilterAudioUnit
            AKManager.sharedInstance.engine.attachNode(self.output!)
            AKManager.sharedInstance.engine.connect(input.output!, to: self.output!, format: nil)
        }

        guard let tree = internalAU?.parameterTree else { return }

        reverbDurationParameter = tree.valueForKey("reverbDuration") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.reverbDurationParameter!.address {
                    self.reverbDuration = value
                }
            }
        }

    }
}
