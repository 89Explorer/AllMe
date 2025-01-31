//
//  Extensions.swift
//  AllMe
//
//  Created by 권정근 on 1/31/25.
//

import Foundation
import UIKit


class PaddedLabel: UILabel {
    
    var padding: UIEdgeInsets
    
    // 기본 padding 설정
    init(padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)) {
        self.padding = padding
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        self.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        super.init(coder: coder)
    }
    
    // 텍스트가 그려지는 영역을 변경
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: padding)
        super.drawText(in: insetRect)
    }
    
    // label의 intrinsicContentSize를 조정 (auto-layout 사용 시 반영됨)
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                      height: size.height + padding.top + padding.bottom)
    }
}
