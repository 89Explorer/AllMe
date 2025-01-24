//
//  FeedViewController.swift
//  AllMe
//
//  Created by 권정근 on 1/21/25.
//

import UIKit
import PhotosUI
import Combine

class FeedViewController: UIViewController {
    
    // MARK: - Variable
    private let tableSection: [String] = ["이미지", "제목", "내용"]
    private var selectedImages: [UIImage] = []
    
    
    private let viewModel = FeedItemViewModel()
    private var cancellables = Set<AnyCancellable>()

    
    // MARK: - UI Components
    private let feedTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = false
        tableView.isScrollEnabled = true
        return tableView
    }()
    
    private let registerFeedButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("작성 완료", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemYellow
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureConstraints()
        setupTableViewDelegate()
        setupBindings()
        
        registerFeedButton.addTarget(self, action: #selector(registerFeed), for: .touchUpInside)
        
        navigationItem.title = "오늘 리뷰 쓰기"
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16)), style: .done, target: self, action: #selector(didTapBack))
        
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = .link
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapToDismiss)))
        
    }
    
    
    // MARK: - Functions
    // 테이블 뷰 대리자 선언 함수
    private func setupTableViewDelegate() {
        
        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        feedTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        feedTableView.register(ImageSelectedCell.self, forCellReuseIdentifier: ImageSelectedCell.reuseIdentifier)
        feedTableView.register(TitleInputCell.self, forCellReuseIdentifier: TitleInputCell.reuseIdentifier)
        feedTableView.register(ContentInputCell.self, forCellReuseIdentifier: ContentInputCell.reuseIdentifier)
    }
    
    private func setupBindings() {
        
        // feeds 배열이 바뀌면 테이블 뷰 리로드
        viewModel.$feeds
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.feedTableView.reloadData()
            }
            .store(in: &cancellables)
        
        // 에러 메세지 처리를 U로 표출, print() 문으로 확인
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { errerMessage in
                print("Error: \(errerMessage)")
                
                // 추후 alert 표시
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Actions
    @objc private func registerFeed() {
        
//        // 1) ViewModel의 userFeed에 ID 할당
//        viewModel.userFeed.id = UUID().uuidString
//        
//        // 2) 이미지 선택 항목을 userFeed.imagePath에 반영
//        for image in selectedImages {
//            if let imageString = image.toString() {
//                viewModel.userFeed.imagePath.append(imageString)
//            }
//        }
//        
//        let group = DispatchGroup()
//        for image in selectedImages {
//            group.enter()
//            guard let imageString = image.toString() else {
//                group.leave()
//                continue
//            }
//            
//            // 3) ViewModel에 저장 요청
//            viewModel.createFeed(viewModel.userFeed)
//            dismiss(animated: true)
//        }
        
        // userFeed에 title, contents는 이미 설정된 상태
        // selectedImages에 UIImage 배열이 들어있다고 가정
        // ID 생성
        viewModel.userFeed.id = UUID().uuidString
        
        // ViewModel에 생성 요청
        // userFeed는 현재 작성 중인 FeedItem, selectedImages는 이미 선택된 UIImage 목록
        viewModel.createFeed(viewModel.userFeed, images: selectedImages)
        
        dismiss(animated: true)
    }
    
    @objc private func didTapBack() {
        dismiss(animated: true)
    }
    
    @objc private func didTapToDismiss() {
        view.endEditing(true)
    }
    
    // MARK: - Layout
    private var feedTableViewBottomConstraint: NSLayoutConstraint!
    private var registerButtonTopConstraint: NSLayoutConstraint!

    private func configureConstraints() {
        view.addSubview(feedTableView)
        view.addSubview(registerFeedButton)
        
        feedTableView.translatesAutoresizingMaskIntoConstraints = false
        registerFeedButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 제약 조건 저장
        feedTableViewBottomConstraint = feedTableView.bottomAnchor.constraint(equalTo: registerFeedButton.topAnchor, constant: -10)
        registerButtonTopConstraint = registerFeedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            
            // 테이블뷰 제약조건
            feedTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            feedTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            feedTableView.topAnchor.constraint(equalTo: view.topAnchor),
            feedTableViewBottomConstraint,
            
            // 버튼 제약조건
            registerFeedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            registerFeedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            registerFeedButton.heightAnchor.constraint(equalToConstant: 50),
            registerButtonTopConstraint
        ])
        
        // 키보드 노티피케이션 설정
        setupKeyboardNotifications()
    }
    

    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            // 키보드가 올라오면 테이블뷰의 bottom을 키보드의 top에 맞춤
            feedTableViewBottomConstraint.constant = -keyboardFrame.height + 100

            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        // 키보드가 내려가면 테이블뷰의 bottom을 버튼의 top으로 복원
        feedTableViewBottomConstraint.constant = -10
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

}

// MARK: - Extension: TableView
extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        
        switch section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageSelectedCell.reuseIdentifier, for: indexPath) as? ImageSelectedCell else { return UITableViewCell() }
            cell.delegate = self
            
            cell.selectionStyle = .none
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleInputCell.reuseIdentifier, for: indexPath) as? TitleInputCell else { return UITableViewCell()}
            cell.calledTitleTextField().delegate = self
            return cell
            
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContentInputCell.reuseIdentifier, for: indexPath) as? ContentInputCell else { return UITableViewCell() }
        
            cell.calledTextView().delegate = self
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSection[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .label
    }
}

// MARK: - Extension: ImageSelectedDelegate
extension FeedViewController: ImageSelectedDelegate {
    func didTappedImageSelectedButton(in cell: ImageSelectedCell) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 10
        configuration.selection = .ordered
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imageAddCell(_ cell: ImageSelectedCell, didSelectImages images: [UIImage]) {
        cell.updateImages(images)
    }
}


// MARK: - Extension: PHPickerViewControllerDelegate
extension FeedViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let group = DispatchGroup()
        selectedImages.removeAll()
        for item in results {
            group.enter()
            item.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    self.selectedImages.append(image)
                    
                    //guard let imageString = image.toString() else { return }
                    //self.userFeed.imagePath?.append(imageString)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let cell = self.feedTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ImageSelectedCell {
                self.imageAddCell(cell, didSelectImages: self.selectedImages)
                
            }
        }
    }
}


// MARK: Extension: convert to UIImage to String
extension UIImage {
    func toString() -> String? {

        //let pngData = self.pngData()

        let jpegData = self.jpegData(compressionQuality: 0.75)

        return jpegData?.base64EncodedString(options: .lineLength64Characters)
    }
}

// MARK: - Extension: UITextFieldDelegate, UITextViewDelegate
extension FeedViewController: UITextFieldDelegate, UITextViewDelegate {
    // 제목 입력 완료 시
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.userFeed.title = textField.text ?? ""
    }
    
    // 내용 변경 시
    func textViewDidChange(_ textView: UITextView) {
        viewModel.userFeed.contents = textView.text
    }
}
