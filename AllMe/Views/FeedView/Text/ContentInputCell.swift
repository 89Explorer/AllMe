//
//  ContentInputCell.swift
//  AllMe
//
//  Created by 권정근 on 1/22/25.
//



import UIKit

class ContentInputCell: UITableViewCell {
    
    // MARK: - Variable
    static let reuseIdentifier: String = "ContentInputCell"
    
    // MARK: - UI Component
    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.text = "오늘 하루는 어땠나요? 😀"
        textView.backgroundColor = .systemBackground
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        
        // 글자 수에 따라 크기가 늘어가게 하기 위함
        textView.isScrollEnabled = true

        textView.textAlignment = .left
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.textColor = .secondaryLabel
        textView.backgroundColor = .systemBackground
        textView.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return textView
    }()
    
    // MARK: - Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        configureConstraints()
         
    }    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    func calledTextView() -> UITextView {
        return contentTextView
    }
    
    
    // MARK: - Layout
    private func configureConstraints() {
        contentView.addSubview(contentTextView)
        
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentTextView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentTextView.bottomAnchor.constraint(equalTo: contentView.keyboardLayoutGuide.topAnchor, constant: 5),
            contentTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 350)
            
        ])
    }
}

// MARK: - Extension: UITextViewDelegate
extension ContentInputCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard let tableView = tableView else { return }

        let contentSize = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: .infinity))

        if textView.bounds.height != contentSize.height {
            tableView.contentOffset.y += contentSize.height - textView.bounds.height

            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
}

extension ContentInputCell {

    var tableView: UITableView? {
        var view = superview
        while view != nil && !(view is UITableView) {
            view = view?.superview
        }

        return view as? UITableView
    }
}
