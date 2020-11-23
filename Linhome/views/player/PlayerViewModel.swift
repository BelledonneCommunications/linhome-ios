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
    let position = MutableLiveData(0)
    let resetEvent = MutableLiveData(false)
    let seekPosition = MutableLiveData(0)
	private var playerDelegate : PlayerDelegateStub?

    var targetSeek: Int = 0
	
	init(callId:String, player:Player) {
		self.callId = callId
		self.player = player
		self.historyEvent = Core.get().workAroundFindCallLogFromCallId(callId: callId)?.getHistoryEvent()
		super.init()
		playerDelegate = PlayerDelegateStub ( onEofReached: { _ in
			self.playing.value = false
			self.resetEvent.value = true
			self.targetSeek = 0
			self.seek()
		})
		player.addDelegate(delegate: playerDelegate!)
		if (historyEvent != nil) {
			historyEvent?.mediaFileName.map {try?player.open(filename: $0)}
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
		} else {
            try?player.start()
		}
        playing.value = !playing.value!
    }
	
	func pausePlay() {
		if (playing.value!) {
            try?player.pause()
			playing.value = false
		}
    }

    func playFromStart() {
        targetSeek = 0
        seek()
        try?player.start()
        playing.value = true
        resetEvent.value = true
    }


    func seek() {
        player.close()
        if (historyEvent != nil) {
			historyEvent?.mediaFileName.map { try?player.open(filename:$0)}
        }
		try?player.seek(timeMs: targetSeek)
		if (playing.value!) {
            try?player.start()
		}
        updatePosition()
        seekPosition.value = targetSeek
    }

    func updatePosition() {
            position.value = player.currentPosition
    }

}
