//
//  AKStringResonator.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/** AKStringResonator passes the input through a network composed of comb, low-pass and all-pass filters, similar to the one used in some versions of the Karplus-Strong algorithm, creating a string resonator effect. The fundamental frequency of the “string” is controlled by the fundamentalFrequency.  This operation can be used to simulate sympathetic resonances to an input signal. */
public class AKStringResonator: AKOperation {

    // MARK: - Properties

    private var internalAU: AKStringResonatorAudioUnit?
    private var token: AUParameterObserverToken?

    private var fundamentalFrequencyParameter: AUParameter?
    private var feedbackParameter:             AUParameter?

    /** Fundamental frequency of string. */
    public var fundamentalFrequency: Float = 100 {
        didSet {
            fundamentalFrequencyParameter?.setValue(fundamentalFrequency, originator: token!)
        }
    }
    /** Feedback amount (value between 0-1). A value close to 1 creates a slower decay and a more pronounced resonance. Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9. */
    public var feedback: Float = 0.95 {
        didSet {
            feedbackParameter?.setValue(feedback, originator: token!)
        }
    }

    // MARK: - Initializers

    /** Initialize this filter operation */
    public init(_ input: AKOperation) {
        super.init()

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x73747265 /*'stre'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKStringResonatorAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKStringResonator",
            version: UInt32.max)

        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.output = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKStringResonatorAudioUnit
            AKManager.sharedInstance.engine.attachNode(self.output!)
            AKManager.sharedInstance.engine.connect(input.output!, to: self.output!, format: nil)
        }

        guard let tree = internalAU?.parameterTree else { return }

        fundamentalFrequencyParameter = tree.valueForKey("fundamentalFrequency") as? AUParameter
        feedbackParameter             = tree.valueForKey("feedback")             as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.fundamentalFrequencyParameter!.address {
                    self.fundamentalFrequency = value
                }
                else if address == self.feedbackParameter!.address {
                    self.feedback = value
                }
            }
        }

    }
}
