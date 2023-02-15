/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linhome
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */


import Foundation
import linphonesw

class PlayerViewModel : ViewModel {
	
	var callId: String
	var player: Player
	let historyEvent: HistoryEvent?
	let playing = MutableLiveData(false)
	let endReached = MutableLiveData(false)
	let position = MutableLiveData(0)
	let trackingAllowed = MutableLiveData(false)
	private var playerDelegate : PlayerDelegateStub?
		
	init(callId:String, player:Player) {
		self.callId = callId
		self.player = player
		self.historyEvent = Core.get().workAroundFindCallLogFromCallId(callId: callId)?.getHistoryEvent()
		super.init()
		playerDelegate = PlayerDelegateStub ( onEofReached: { _ in
			self.playing.value = false
			self.endReached.value = true
		})
		player.addDelegate(delegate: playerDelegate!)
		if (historyEvent != nil) {
			historyEvent?.mediaFileName.map {try?player.open(filename: $0)}
			if let recordingFileName = historyEvent?.mediaFileName {
				let codec = Config.get().getString(section: "recording_formats", key:recordingFileName,defaultString: "")
				trackingAllowed.value = codec.lowercased().contains("h26") != true
				Log.info("[Player] playing \(recordingFileName) in format \(codec)")
				try?player.open(filename:recordingFileName)
			}
		}
	}
	
	var duration: Int {
		get {
			return player.duration
		}
	}
	
	func end()  {
		player.close()
		player.removeDelegate(delegate: playerDelegate!)
	}
	
	func togglePlay() {
		if (playing.value!) {
			try?player.pause()
			playing.value = false
		} else {
			if (self.endReached.value == true) {
				playFromStart()
			} else {
				try?player.start()
				playing.value = true
			}
		}
	}
	
	func pausePlay() {
		if (playing.value!) {
			try?player.pause()
			playing.value = false
		}
	}
	
	func resumePlay() {
		if (!playing.value!) {
			try?player.start()
			playing.value = true
		}
	}
	
	func playFromStart() {
		seek(targetSeek: 0)
	}
	
	
	func seek(targetSeek: Int) {
		if (targetSeek < player.duration) {
			endReached.value = false
		}
		if (playing.value == true) {
			pausePlay()
		}
		try?player.seek(timeMs: targetSeek)
		resumePlay()
		updatePosition()
	}
	
	func updatePosition() {
		position.value = player.currentPosition
	}
	
}
