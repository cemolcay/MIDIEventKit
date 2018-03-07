//
//  MIDIEventKit.swift
//  MIDIEventKit
//
//  Created by Cem Olcay on 7.03.2018.
//  Copyright © 2018 cemolcay. All rights reserved.
//

import Foundation
import CoreMIDI

public protocol MIDIStatusEvent: CustomStringConvertible {
  var statusByte: UInt8 { get }
}

public protocol MIDIReservedEvent: MIDIStatusEvent {}
public protocol MIDISystemRealTimeReservedEvent: MIDIReservedEvent {}
public protocol MIDISystemCommonReservedEvent: MIDIReservedEvent {}
public protocol MIDIControllerReservedEvent: MIDIReservedEvent {}

public enum MIDIEventTimeStamp {
  case timestamp(MIDITimeStamp)
  case now
  case secondsAfterNow(Double)

  var value: MIDITimeStamp {
    switch self {
    case .timestamp(let timestamp):
      return timestamp
    case .now:
      return 0
    case .secondsAfterNow(let sec):
      let now = mach_absolute_time()
      let offset = UInt64(sec * 1000000)
      return now + offset
    }
  }
}

public struct MIDIEventData {
  var data1: UInt8
  var data2: UInt8

  init(data1: UInt8, data2: UInt8) {
    self.data1 = data1
    self.data2 = data2
  }

  init(value: MIDIEventValue) {
    switch value {
    case .value(let data1):
      self.data1 = data1
      self.data2 = 0
    case .lsb_msb(let data):
      let mask: UInt16 = 0x007F
      self.data1 = UInt8(data & mask) // MSB, bit shift right 7
      self.data2 = UInt8((data & (mask << 7)) >> 7) // LSB, mask of 127
    case .on(let on):
      self.data1 = on ? 127 : 0
      self.data2 = 0
    case .none:
      self.data1 = 0
      self.data2 = 0
    }
  }
}

public enum MIDIEventValue {
  /// 8-bit value between 0 - 127.
  case value(UInt8)
  /// 16-bit value between 0 - 16383.
  case lsb_msb(UInt16)
  /// False for off, True for on.
  case on(Bool)
  /// No MIDI event data.
  case none
}

public enum MIDIChannelVoiceEvent: MIDIStatusEvent {
  case noteOff // 128 - 143
  case noteOn // 144 - 159
  case polyphonicAftertouch // 160 - 175
  case controllerChange(MIDIControllerEvent) // 176 - 191
  case programChange(UInt8) // 192 - 207
  case channelAftertouch // 208 - 223
  case pitchBendChange // 224 - 239

  // MARK: MIDIStatusEvent

  public var statusByte: UInt8 {
    switch self {
    case .noteOff: return 128
    case .noteOn: return 144
    case .polyphonicAftertouch: return 160
    case .controllerChange: return 176
    case .programChange: return 192
    case .channelAftertouch: return 208
    case .pitchBendChange: return 224
    }
  }

  // MARK: CustomStringConvertible

  public var description: String {
    switch self {
    case .noteOff: return NSLocalizedString("midi_noteOff", comment: "")
    case .noteOn: return NSLocalizedString("midi_noteOn", comment: "")
    case .polyphonicAftertouch: return NSLocalizedString("midi_polyphonicAftertouch", comment: "")
    case .controllerChange(let event): return event.description
    case .programChange(let event): return event.description
    case .channelAftertouch: return NSLocalizedString("midi_channelAftertouch", comment: "")
    case .pitchBendChange: return NSLocalizedString("midi_pitchBendChange", comment: "")
    }
  }
}

public enum MIDIControllerEvent: MIDIStatusEvent {
  case bankSelect // 0
  case modulationWheel // 1
  case breathController // 2
  case footController // 4
  case portamentoTime // 5
  case dataEntryMSB // 6
  case channelVolume // 7
  case balance // 8
  case pan // 10
  case expressionController // 11
  case effectControl1 // 12
  case effectControl2 // 13
  case generalPurposeController1 // 16
  case generalPurposeController2 // 17
  case generalPurposeController3 // 18
  case generalPurposeController4 // 19
  case lsbBankSelect // 32
  case lsbModulationWheel // 33
  case lsbBreathController // 34
  case lsbFootController // 38
  case lsbPortamentoTime // 37
  case lsbDataEntryMSB // 38
  case lsbChannelVolume // 39
  case lsbBalance // 40
  case lsbPan // 42
  case lsbExpressionController // 43
  case lsbEffectControl1 // 44
  case lsbEffectControl2 // 45
  case lsbGeneralPurposeController1 // 48
  case lsbGeneralPurposeController2 // 49
  case lsbGeneralPurposeController3 // 50
  case lsbGeneralPurposeController4 // 51
  case damperPedal // 64
  case portamentoOn // 65
  case sostenutoOn // 66
  case softPedalOn // 67
  case legatoFootswitch // 68
  case hold2 // 69
  case soundVariation // 70
  case timbreIntesity // 71
  case releaseTime // 72
  case attackTime // 73
  case brightness // 74
  case decayTime // 75
  case vibratoRate // 76
  case vibratoDepth // 77
  case vibratoDelay // 78
  case defaultUndefined // 79
  case generalPurposeController5 // 80
  case generalPurposeController6 // 81
  case generalPurposeController7 // 82
  case generalPurposeController8 // 83
  case portamentoControl // 84
  case highResolutionVelocityPrefix // 88
  case reverbSendLevel // 91
  case tremoloDepth // 92
  case chorusSendLevel // 93
  case celesteDepth // 94
  case phaserDepth // 95
  case dataIncrement // 96
  case dataDecrement // 97
  case nonRegisteredParameterNumberLSB // 98
  case nonRegisteredParameterNumberMSB // 99
  case registeredParameterNumberLSB // 100
  case registeredParameterNumberMSB // 101
  case undefined(UInt8) // 3, 9, 14, 15, 20...31, 35, 21, 46, 47, 52...63, 85, 86, 87, 89, 90, 102...119

  // MARK: MIDIStatusEvent

  public var statusByte: UInt8 {
    switch self {
    case .bankSelect: return 0
    case .modulationWheel: return 1
    case .breathController: return 2
    case .footController: return 4
    case .portamentoTime: return 5
    case .dataEntryMSB: return 6
    case .channelVolume: return 7
    case .balance: return 8
    case .pan: return 10
    case .expressionController: return 11
    case .effectControl1: return 12
    case .effectControl2: return 13
    case .generalPurposeController1: return 16
    case .generalPurposeController2: return 17
    case .generalPurposeController3: return 18
    case .generalPurposeController4: return 19
    case .lsbBankSelect: return 32
    case .lsbModulationWheel: return 33
    case .lsbBreathController: return 34
    case .lsbFootController: return 38
    case .lsbPortamentoTime: return 37
    case .lsbDataEntryMSB: return 38
    case .lsbChannelVolume: return 39
    case .lsbBalance: return 40
    case .lsbPan: return 42
    case .lsbExpressionController: return 43
    case .lsbEffectControl1: return 44
    case .lsbEffectControl2: return 45
    case .lsbGeneralPurposeController1: return 48
    case .lsbGeneralPurposeController2: return 49
    case .lsbGeneralPurposeController3: return 50
    case .lsbGeneralPurposeController4: return 51
    case .damperPedal: return 64
    case .portamentoOn: return 65
    case .sostenutoOn: return 66
    case .softPedalOn: return 67
    case .legatoFootswitch: return 68
    case .hold2: return 69
    case .soundVariation: return 70
    case .timbreIntesity: return 71
    case .releaseTime: return 72
    case .attackTime: return 73
    case .brightness: return 74
    case .decayTime: return 75
    case .vibratoRate: return 76
    case .vibratoDepth: return 77
    case .vibratoDelay: return 78
    case .defaultUndefined: return 79
    case .generalPurposeController5: return 80
    case .generalPurposeController6: return 81
    case .generalPurposeController7: return 82
    case .generalPurposeController8: return 83
    case .portamentoControl: return 84
    case .highResolutionVelocityPrefix: return 88
    case .reverbSendLevel: return 91
    case .tremoloDepth: return 92
    case .chorusSendLevel: return 93
    case .celesteDepth: return 94
    case .phaserDepth: return 95
    case .dataIncrement: return 96
    case .dataDecrement: return 97
    case .nonRegisteredParameterNumberLSB: return 98
    case .nonRegisteredParameterNumberMSB: return 99
    case .registeredParameterNumberLSB: return 100
    case .registeredParameterNumberMSB: return 101
    case .undefined(let number): return number
    }
  }

  // MARK: CustomStringConvertible

  public var description: String {
    switch self {
    case .bankSelect: return NSLocalizedString("midi_bankSelect", comment: "")
    case .modulationWheel: return NSLocalizedString("midi_modulationWheel", comment: "")
    case .breathController: return NSLocalizedString("midi_breathController", comment: "")
    case .footController: return NSLocalizedString("midi_footController", comment: "")
    case .portamentoTime: return NSLocalizedString("midi_portamentoTime", comment: "")
    case .dataEntryMSB: return NSLocalizedString("midi_dataEntryMSB", comment: "")
    case .channelVolume: return NSLocalizedString("midi_channelVolume", comment: "")
    case .balance: return NSLocalizedString("midi_balance", comment: "")
    case .pan: return NSLocalizedString("midi_pan", comment: "")
    case .expressionController: return NSLocalizedString("midi_expressionController", comment: "")
    case .effectControl1: return NSLocalizedString("midi_effectControl1", comment: "")
    case .effectControl2: return NSLocalizedString("midi_effectControl2", comment: "")
    case .generalPurposeController1: return NSLocalizedString("midi_generalPurposeController1", comment: "")
    case .generalPurposeController2: return NSLocalizedString("midi_generalPurposeController2", comment: "")
    case .generalPurposeController3: return NSLocalizedString("midi_generalPurposeController3", comment: "")
    case .generalPurposeController4: return NSLocalizedString("midi_generalPurposeController4", comment: "")
    case .lsbBankSelect: return NSLocalizedString("midi_lsbBankSelect", comment: "")
    case .lsbModulationWheel: return NSLocalizedString("midi_lsbModulationWheel", comment: "")
    case .lsbBreathController: return NSLocalizedString("midi_lsbBreathController", comment: "")
    case .lsbFootController: return NSLocalizedString("midi_lsbFootController", comment: "")
    case .lsbPortamentoTime: return NSLocalizedString("midi_lsbPortamentoTime", comment: "")
    case .lsbDataEntryMSB: return NSLocalizedString("midi_lsbDataEntryMSB", comment: "")
    case .lsbChannelVolume: return NSLocalizedString("midi_lsbChannelVolume", comment: "")
    case .lsbBalance: return NSLocalizedString("midi_lsbBalance", comment: "")
    case .lsbPan: return NSLocalizedString("midi_lsbPan", comment: "")
    case .lsbExpressionController: return NSLocalizedString("midi_lsbExpressionController", comment: "")
    case .lsbEffectControl1: return NSLocalizedString("midi_lsbEffectControl1", comment: "")
    case .lsbEffectControl2: return NSLocalizedString("midi_lsbEffectControl2", comment: "")
    case .lsbGeneralPurposeController1: return NSLocalizedString("midi_lsbGeneralPurposeController1", comment: "")
    case .lsbGeneralPurposeController2: return NSLocalizedString("midi_lsbGeneralPurposeController2", comment: "")
    case .lsbGeneralPurposeController3: return NSLocalizedString("midi_lsbGeneralPurposeController3", comment: "")
    case .lsbGeneralPurposeController4: return NSLocalizedString("midi_lsbGeneralPurposeController4", comment: "")
    case .damperPedal: return NSLocalizedString("midi_damperPedal", comment: "")
    case .portamentoOn: return NSLocalizedString("midi_portamentoOn", comment: "")
    case .sostenutoOn: return NSLocalizedString("midi_sostenutoOn", comment: "")
    case .softPedalOn: return NSLocalizedString("midi_softPedalOn", comment: "")
    case .legatoFootswitch: return NSLocalizedString("midi_legatoFootswitch", comment: "")
    case .hold2: return NSLocalizedString("midi_hold2", comment: "")
    case .soundVariation: return NSLocalizedString("midi_soundVariation", comment: "")
    case .timbreIntesity: return NSLocalizedString("midi_timbreIntesity", comment: "")
    case .releaseTime: return NSLocalizedString("midi_releaseTime", comment: "")
    case .attackTime: return NSLocalizedString("midi_attackTime", comment: "")
    case .brightness: return NSLocalizedString("midi_brightness", comment: "")
    case .decayTime: return NSLocalizedString("midi_decayTime", comment: "")
    case .vibratoRate: return NSLocalizedString("midi_vibratoRate", comment: "")
    case .vibratoDepth: return NSLocalizedString("midi_vibratoDepth", comment: "")
    case .vibratoDelay: return NSLocalizedString("midi_vibratoDelay", comment: "")
    case .defaultUndefined: return NSLocalizedString("midi_defaultUndefined", comment: "")
    case .generalPurposeController5: return NSLocalizedString("midi_generalPurposeController5", comment: "")
    case .generalPurposeController6: return NSLocalizedString("midi_generalPurposeController6", comment: "")
    case .generalPurposeController7: return NSLocalizedString("midi_generalPurposeController7", comment: "")
    case .generalPurposeController8: return NSLocalizedString("midi_generalPurposeController8", comment: "")
    case .portamentoControl: return NSLocalizedString("midi_portamentoControl", comment: "")
    case .highResolutionVelocityPrefix: return NSLocalizedString("midi_highResolutionVelocityPrefix", comment: "")
    case .reverbSendLevel: return NSLocalizedString("midi_reverbSendLevel", comment: "")
    case .tremoloDepth: return NSLocalizedString("midi_tremoloDepth", comment: "")
    case .chorusSendLevel: return NSLocalizedString("midi_chorusSendLevel", comment: "")
    case .celesteDepth: return NSLocalizedString("midi_celesteDepth", comment: "")
    case .phaserDepth: return NSLocalizedString("midi_phaserDepth", comment: "")
    case .dataIncrement: return NSLocalizedString("midi_dataIncrement", comment: "")
    case .dataDecrement: return NSLocalizedString("midi_dataDecrement", comment: "")
    case .nonRegisteredParameterNumberLSB: return NSLocalizedString("midi_nonRegisteredParameterNumberLSB", comment: "")
    case .nonRegisteredParameterNumberMSB: return NSLocalizedString("midi_nonRegisteredParameterNumberMSB", comment: "")
    case .registeredParameterNumberLSB: return NSLocalizedString("midi_registeredParameterNumberLSB", comment: "")
    case .registeredParameterNumberMSB: return NSLocalizedString("midi_registeredParameterNumberMSB", comment: "")
    case .undefined(let number): return "CC \(number)"
    }
  }
}

public enum MIDIChannelModeEvent: MIDIStatusEvent {
  case allSoundOff // 120
  case resetAllControllers // 121
  case localControl // 122
  case allNotesOff // 123
  case omniModeOff // 124
  case omniModeOn // 125
  case monoModeOn // 126
  case polyModeOn // 127

  public var statusByte: UInt8 {
    switch self {
    case .allSoundOff: return 120
    case .resetAllControllers: return 121
    case .localControl: return 122
    case .allNotesOff: return 123
    case .omniModeOff: return 124
    case .omniModeOn: return 125
    case .monoModeOn: return 126
    case .polyModeOn: return 127
    }
  }

  // MARK: CustomStringConvertible

  public var description: String {
    switch self {
    case .allSoundOff: return NSLocalizedString("midi_allSoundOff", comment: "")
    case .resetAllControllers: return NSLocalizedString("midi_resetAllControllers", comment: "")
    case .localControl: return NSLocalizedString("midi_localControl", comment: "")
    case .allNotesOff: return NSLocalizedString("midi_allNotesOff", comment: "")
    case .omniModeOff: return NSLocalizedString("midi_omniModeOff", comment: "")
    case .omniModeOn: return NSLocalizedString("midi_omniModeOn", comment: "")
    case .monoModeOn: return NSLocalizedString("midi_monoModeOn", comment: "")
    case .polyModeOn: return NSLocalizedString("midi_polyModeOn", comment: "")
    }
  }
}

public struct MIDIQuarterFrameEvent: CustomStringConvertible {

  public var description: String {
    return ""
  }
}

public enum MIDISystemCommonEvent: MIDIStatusEvent {
  case systemExclusive // 240
  case midiTimeCodeQuarterFrame(MIDIQuarterFrameEvent) // 241
  case songPositionPointer // 242
  case songSelect // 243
  case tuneRequest // 246
  case eox // 247
  case reserved(MIDISystemCommonReservedEvent) // 245, 244

  // MARK: MIDIStatusEvent

  public var statusByte: UInt8 {
    switch self {
    case .systemExclusive: return 240
    case .midiTimeCodeQuarterFrame: return 241
    case .songPositionPointer: return 242
    case .songSelect: return 243
    case .tuneRequest: return 246
    case .eox: return 247
    case .reserved(let event): return event.statusByte
    }
  }

  // MARK: CustomStringConvertible

  public var description: String {
    switch self {
    case .systemExclusive: return NSLocalizedString("midi_systemExclusive", comment: "")
    case .midiTimeCodeQuarterFrame(let qt): return qt.description
    case .songPositionPointer: return NSLocalizedString("midi_songPositionPointer", comment: "")
    case .songSelect: return NSLocalizedString("midi_songSelect", comment: "")
    case .tuneRequest: return NSLocalizedString("midi_tuneRequest", comment: "")
    case .eox: return NSLocalizedString("midi_eox", comment: "")
    case .reserved(let event): return event.description
    }
  }
}

public enum MIDISystemRealTimeEvent: MIDIStatusEvent {
  case timingClock // 248
  case start // 250
  case `continue` // 251
  case stop // 252
  case activeSensing // 254
  case reset // 255
  case reserved(MIDISystemRealTimeReservedEvent) // 253, 249

  // MARK: MIDIStatusEvent

  public var statusByte: UInt8 {
    switch self {
    case .timingClock: return 248
    case .start: return 250
    case .continue: return 251
    case .stop: return 252
    case .activeSensing: return 254
    case .reset: return 255
    case .reserved(let event): return event.statusByte
    }
  }

  // MARK: CustomStringConvertible

  public var description: String {
    switch self {
    case .timingClock: return NSLocalizedString("midi_timingClock", comment: "")
    case .start: return NSLocalizedString("midi_start", comment: "")
    case .continue: return NSLocalizedString("midi_continue", comment: "")
    case .stop: return NSLocalizedString("midi_stop", comment: "")
    case .activeSensing: return NSLocalizedString("midi_activeSensing", comment: "")
    case .reset: return NSLocalizedString("midi_reset", comment: "")
    case .reserved(let event): return event.description
    }
  }
}
