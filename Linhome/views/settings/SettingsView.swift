//
//  SideMenuViewViewController.swift
//  Linhome
//
//  Created by Christophe Deschamps on 22/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import SnapKit
import linphonesw
import MessageUI

class SettingsView: MainViewContent, MFMailComposeViewControllerDelegate {
	
	@IBOutlet weak var form: UIStackView!
	@IBOutlet weak var scrollView: UIScrollView!
	
	
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		isRoot = false
		onTopOfBottomBar = true
		titleTextKey = "settings"
		
		scrollView.snp.makeConstraints { make in
			make.edges.equalTo(view)
		}
		scrollView.addSubview(form)
		form.snp.makeConstraints { make in
			make.top.equalTo(scrollView)
			make.bottom.equalTo(scrollView)
			make.left.right.equalTo(view)
		}
		
		let model = SettingsViewModel()
		manageModel(model)
		
		let audioCodecsExpandable = SettingExpandable.addOne(titleKey: "audio_codecs", subtitleKey: nil, targetVC: self,form: form)
		model.audioCodecs?.forEach { descriptor in
			let _ = SettingSwitch.addOne(titleText: descriptor.title, subtitleText: descriptor.rate , targetVC: self, liveValue: descriptor.liveState, form: form, liveCollapsed: audioCodecsExpandable.collapsed, pad:true)
		}
		
		let videoCodecsExpandable = SettingExpandable.addOne(titleKey: "video_codecs", subtitleKey: nil, targetVC: self,form: form)
		model.videCodecs?.forEach { descriptor in
			let _ = SettingSwitch.addOne(titleText: descriptor.title, subtitleText: descriptor.rate , targetVC: self, liveValue: descriptor.liveState, form: form, liveCollapsed: videoCodecsExpandable.collapsed, pad:true)
		}
		
		
		let _ = SettingSwitch.addOne(titleText: Texts.get("enable_ipv6"), subtitleText: nil, targetVC: self, liveValue: model.enableIpv6, form: form, liveCollapsed: nil)
		
		let _ = SettingSpinner.addOne(titleKey: Texts.get("media_encryption"), targetVC: self, liveIndex: model.encryptionIndex, options:model.encryptionLabels, form: form)
		
		let _ = SettingSwitch.addOne(titleText: Texts.get("enable_debuglogs"), subtitleText: nil, targetVC: self, liveValue: model.enableDebugLogs, form: form)
		
		let _ = SettingButton.addOne(titleText: Texts.get("clear_logs"),targetVC: self, form: form, liveCollapsed:model.enableDebugLogs.opposite(), pad:true, onClick: {
			model.clearLogs()
			DialogUtil.info("log_clear_success")
		})
		
		let _ = SettingButton.addOne(titleText: Texts.get("send_logs"),targetVC: self, form: form, liveCollapsed:model.enableDebugLogs.opposite(), pad:true, onClick: {
			
			self.showProgress()
			model.logUploadResult.observeAsUniqueObserver (onChange: { (result) in
				if (result?.first == Core.LogCollectionUploadState.NotDelivered) {
					self.hideProgress()
					DialogUtil.error("log_upload_failed")
				}
				if (result?.first == Core.LogCollectionUploadState.Delivered) {
					self.hideProgress()
					self.shareUploadedLogsUrl(url: result!.second)
				}
			})
			model.sendLogs()
			
		})
		
		let _ = SettingSwitch.addOne(titleText: Texts.get("settings_device_show_latest_snapshot"), subtitleText: nil, targetVC: self, liveValue: model.showLatestSnapshot, form: form)
		
	}
	
	private func shareUploadedLogsUrl(url: String) {
		if MFMailComposeViewController.canSendMail() {
			let mail = MFMailComposeViewController()
			mail.mailComposeDelegate = self
			mail.setToRecipients([Texts.get("support_email_ios")])
			mail.setSubject("\(Texts.appName) Logs")
			mail.setMessageBody(url, isHTML: true)
			present(mail, animated: true)
		} else {
			DialogUtil.confirm(titleTextKey: nil, messageTextKey: "unable_to_sendMail_from_this_device", oneArg:url,  confirmAction: {
				let pasteboard = UIPasteboard.general
				pasteboard.string = url
			},confirmTextKey:"copy_url_to_clipboard")
		}
	}
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		   controller.dismiss(animated: true, completion: nil)
	   }
	
}
