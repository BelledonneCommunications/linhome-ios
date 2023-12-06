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




import UIKit
import linphonesw

class HistoryCell: UITableViewCell {
	
	static let spaceBetweenCells  = 10
	
	@IBOutlet weak var thumbnail: UIImageView!
	@IBOutlet weak var nomedia: UILabel!
	@IBOutlet weak var play: UIButton!
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var address: UILabel!
	@IBOutlet weak var typedate: UILabel!
	@IBOutlet weak var newtag: UILabel!
	@IBOutlet weak var typeicon: UIImageView!
	@IBOutlet weak var checkbox: UIButton!
	@IBOutlet weak var ipadSeparator: UIView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		contentView.backgroundColor = Theme.getColor("color_c")
		contentView.layer.cornerRadius = CGFloat(Customisation.it.themeConfig.getFloat(section: "arbitrary-values", key: "call_in_history_list_corner_radius", defaultValue: 0.0))
		contentView.clipsToBounds = true
		contentView.layer.borderWidth = 2
		
		layer.shadowOffset = CGSize(width: 0, height: 5)
		layer.shadowRadius = contentView.layer.cornerRadius
		layer.shadowColor = UIColor.lightGray.cgColor
		layer.shadowOpacity = 0.3
		layer.frame = frame
		
		name.prepare(styleKey: "history_list_device_name")
		address.prepare(styleKey: "history_list_device_address")
		newtag.prepare(styleKey: "history_list_new_tag", textKey:"history_call_new")
		typedate.prepare(styleKey: "history_list_call_date")
		ipadSeparator?.backgroundColor = Theme.getColor("color_h")
		
		thumbnail.layer.cornerRadius = contentView.layer.cornerRadius
		thumbnail.clipsToBounds = true
		
		nomedia.prepare(styleKey: "history_no_media_found", textKey: "history_no_media_found" )
		nomedia.backgroundColor = Theme.getColor("color_u")
		
		play.prepareRoundIcon(effectKey: "primary_color", tintColor: "color_c", iconName: "icons/play.png", padding: 10)
		play.tintColor = Theme.getColor("color_c")
		
		checkbox.makeCheckBox()
		
		contentView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview().inset(5)
			make.height.greaterThanOrEqualTo(110)
			make.centerX.equalToSuperview()
		}
		
	}
	
	func set(model:HistoryEventViewModel) {
		
		contentView.layer.borderColor = Theme.getColor(model.isNew() ? "color_t" : "color_u").cgColor
		
		if let historyEvent = model.historyEvent  {
			thumbnail.isHidden =  !(historyEvent.hasMedia() && historyEvent.hasMediaThumbnail())
			nomedia.isHidden =  historyEvent.hasMedia()
			play.isHidden = !(historyEvent.hasMedia())
			if (historyEvent.hasMediaThumbnail()) {
				thumbnail.image = UIImage(contentsOfFile: historyEvent.mediaThumbnailFileName)
			}
		} else {
			thumbnail.isHidden = true
			nomedia.isHidden = false
			play.isHidden = true
		}
		
		name.text =  model.device != nil ?  model.device!.name : Texts.get("history_unregistered_device")
		address.text = model.callLog.remoteAddress!.asStringUriOnly()
		typedate.text = model.callTypeAndDate()
		
		typeicon.image = Theme.svgToUiImage(model.callTypeIcon(),CGSize(width: typeicon.frame.size.width*2, height: typeicon.frame.size.height*2))?.resized(to: typeicon.frame.size) // SVG renderer does not work too well on small sizes.
		
		model.historyViewModel.editing.observe { (_) in
			self.updateDynamicValues(model: model)
		}
		model.historyViewModel.selectedForDeletion.observe { (_) in
			self.updateDynamicValues(model: model)
		}
		
		self.updateDynamicValues(model: model)
		
		checkbox.onClick {
			self.checkbox.isSelected = !self.checkbox.isSelected
			model.toggleSelect()
		}
		
		contentView.onClick {
			self.playIt(model: model)
		}
		
		play.onClick {
			self.playIt(model: model)
		}
				
	}
	
	func updateDynamicValues(model:HistoryEventViewModel) {
		let selected = model.callLog.callId != nil ? model.historyViewModel.selectedForDeletion.value!.contains(model.callLog.callId!) : false;
		contentView.alpha = model.historyViewModel.editing.value! && !selected  ? 0.3 : 1.0
		play.tintColor = model.historyViewModel.editing.value! ? Theme.getColor("color_b") : Theme.getColor("color_c")
		self.checkbox.isHidden = !model.historyViewModel.editing.value!
		self.newtag.isHidden = !self.checkbox.isHidden || !model.isNew()
		self.checkbox.isSelected = selected
	}
	
	func playIt(model:HistoryEventViewModel) {
		if (model.historyViewModel.editing.value!) {
			model.toggleSelect()
		} else if (model.historyEvent != nil && model.historyEvent!.hasMedia()) {
			NavigationManager.it.navigateTo(childClass: PlayerView.self, asRoot: false, argument: model.callLog.callId)
		}
	}
	
	
}
