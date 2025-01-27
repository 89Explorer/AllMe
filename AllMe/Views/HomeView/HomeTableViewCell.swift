//
//  HomeTableViewCell.swift
//  AllMe
//
//  Created by 권정근 on 1/25/25.
//

import UIKit
import Combine

class HomeTableViewCell: UITableViewCell {
    
    // MARK: - Variables
    static let reuseIdentifier: String = "HomeTableViewCell"
    
    // MARK: - UI Component
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Fri" + "\n" + "23"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘은 이러쿵저러쿵제목"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "미모로 승부하는게 아니라... 이거러커우 저러커ㅓㅇ.. 그래그래 으으으"
        label.numberOfLines = 3
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "2:45 PM"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        return label
    }()
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "mountain")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var innerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, contentLabel, timeLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 5
        stackView.distribution = .fill
        stackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return stackView
    }()
    
    private lazy var outterStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 5
        return stackView
    }()
    
    
    // MARK: - Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        outterStackView.addArrangedSubview(dateLabel)
        outterStackView.addArrangedSubview(innerStackView)
        outterStackView.addArrangedSubview(userImageView)
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    func configureTableView(feedItem: FeedItem, image: UIImage) {
        
        // 1) DateFormatter를 활용, 날짜 / 시간을 분리하여 표시
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"    // "Feb 23" 표시
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"    // "2:33 PM" 표시
        
        // feedItem.date가 nil 경우 대비, 옵셔널 바인딩
        if let date = feedItem.date {
            dateLabel.text = dateFormatter.string(from: date)
            timeLabel.text = timeFormatter.string(from: date)
        } else {
            // 예: 값이 없을 때 기본값
            dateLabel.text = "N/A"
            timeLabel.text = "--:--"
        }
        
        // 제목, 내용 설정
        titleLabel.text = feedItem.title
        contentLabel.text = feedItem.contents
        
        // 대표 이미지 설정
        userImageView.image = image
    }
    
    
    // MARK: - Layouts
    private func configureConstraints() {
        contentView.addSubview(outterStackView)
        
        outterStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            outterStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            outterStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            outterStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            outterStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            dateLabel.widthAnchor.constraint(equalToConstant: 40),
            
            userImageView.widthAnchor.constraint(equalToConstant: 100),
            userImageView.heightAnchor.constraint(equalToConstant: 100),
            
        ])
    }
}
