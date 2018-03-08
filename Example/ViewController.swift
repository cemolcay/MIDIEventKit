//
//  ViewController.swift
//  Example
//
//  Created by Cem Olcay on 8.03.2018.
//  Copyright © 2018 cemolcay. All rights reserved.
//

import Cocoa
import AudioKit

class ViewController: NSViewController, AKMIDIListener {
  let midi = AKMIDI()

  override func viewDidLoad() {
    super.viewDidLoad()
    midi.addListener(self)
    midi.openInput()
    midi.createVirtualOutputPort(name: "MIDIEventKit")
  }

  @IBAction func sendMIDI(sender: NSButton) {
    let pitch = MIDIEvent(
      event: MIDIChannelVoiceEvent.pitchBendChange(bend: 8192, channel: 0),
      timestamp: .now)
//    midi.sendEvent(AKMIDIEvent(packet: pitch.midiPacket))

    let mod = MIDIEvent(
      event: MIDIChannelVoiceEvent.controllerChange(
        event: .modulationWheel(value: 100),
        channel: 0),
      timestamp: .now)
//    midi.sendEvent(AKMIDIEvent(packet: mod.midiPacket))

    var packetList = [pitch, mod].midiPacketList
    for endpoint in midi.endpoints {
      MIDISend(midi.virtualInput, endpoint.value, &packetList)
    }
  }
}
