//
//  TemplateView.swift
//  Linhome
//
//  Created by Christophe Deschamps on 18/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import SVProgressHUD
import IQKeyboardManager

class MainViewContentWithScrollableForm : MainViewContent {

	var scrollView : UIScrollView
	var contentView : UIView
	var viewTitle, viewSubtitle : UILabel
	var form, formSecondColumn: UIStackView
	var formHasSecondColumn: Bool
	
	public required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		scrollView = UIScrollView()
		contentView = UIView()
		viewTitle = UILabel()
		viewTitle.numberOfLines = 2
		viewSubtitle = UILabel()
		viewSubtitle.numberOfLines = 3
		form = UIStackView()
		formSecondColumn = UIStackView()
		formHasSecondColumn = false
		super.init(nibName: nibNameOrNil,bundle: nibBundleOrNil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(scrollView)
		scrollView.snp.makeConstraints { make in
			make.edges.equalTo(view)
		}
		
		scrollView.addSubview(contentView)
		contentView.snp.makeConstraints { make in
			make.top.equalTo(scrollView)
			make.bottom.equalTo(scrollView)
			make.left.right.equalTo(view)
		}
		
		contentView.addSubview(viewTitle)
		viewTitle.snp.makeConstraints { make in
			make.top.equalTo(contentView).offset(40)
			make.centerX.equalTo(view.snp.centerX)
			make.left.equalTo(contentView).offset(20)
			make.right.equalTo(contentView).offset(-20)
		}
		
		contentView.addSubview(viewSubtitle)
		viewSubtitle.snp.makeConstraints { make in
			make.top.equalTo(viewTitle.snp.bottom).offset(33)
			make.centerX.equalTo(view.snp.centerX)
			make.left.equalTo(contentView).offset((20))
			make.right.equalTo(contentView).offset(-20)
		}
		
		form.axis = .vertical
		contentView.addSubview(form)
		form.snp.makeConstraints { make in
			make.top.equalTo(viewSubtitle.snp.bottom).offset(43)
			if (UIDevice.ipad()) {
				make.left.equalTo(contentView).offset(120)
				make.right.equalTo(contentView).offset(-120)
			} else {
				make.left.equalTo(contentView).offset(20)
				make.right.equalTo(contentView).offset(-20)
			}
		}
		
		viewTitle.prepare(styleKey: "view_main_title")
		viewSubtitle.prepare(styleKey: "view_sub_title")
	}
	
	required init?(coder: NSCoder) {
		scrollView = UIScrollView()
		contentView = UIView()
		viewTitle = UILabel()
		viewSubtitle = UILabel()
		form = UIStackView()
		formSecondColumn = UIStackView()
		formHasSecondColumn = false
		super.init(coder: coder)
	}
	
	func hideSubtitle() {
		viewSubtitle.isHidden = true
		viewSubtitle.snp.makeConstraints { make in
			make.top.equalTo(viewTitle.snp.bottom).offset(0)
		}
	}
	
	func hideTitle() {
		viewTitle.isHidden = true
		viewTitle.snp.makeConstraints { make in
			make.top.equalTo(contentView).offset(0)
		}
	}
	
	func addSecondColumn() {
		
		contentView.addSubview(formSecondColumn)
		formSecondColumn.axis = .vertical

		form.snp.removeConstraints()
		form.snp.makeConstraints { make in
			make.top.equalTo(viewSubtitle.snp.bottom).offset(0)
			make.left.equalTo(contentView).offset(40)
			make.width.equalTo(formSecondColumn.snp.width)
			make.right.equalTo(formSecondColumn.snp.left).offset(-40)

		}
		
		formSecondColumn.snp.makeConstraints { make in
			make.top.equalTo(viewSubtitle.snp.bottom).offset(0)
			make.right.equalTo(contentView).offset(-40)
			make.width.equalTo(form.snp.width)
			make.left.equalTo(form.snp.right).offset(40)
		}
		
	}

	
}
