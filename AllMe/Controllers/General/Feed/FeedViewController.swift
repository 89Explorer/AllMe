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
    private let mode: EditMode
    private let tableSection: [String] = ["이미지", "제목", "내용"]
    private var selectedImages: [UIImage] = []
    
    // 기존 이미지를 따로 저장
    private var existingImages: [UIImage] = []
    
    private let viewModel = FeedItemViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // 기존 데이터를 유지하기 위해 속성 추가
    private var existingFeedItem: FeedItem?
    
    // 수정 완료 후 콜백을 실행할 변수 추가
    private var completionHandler: ((FeedItem, [UIImage]) -> Void)?
    
    // MARK: - UI Components
    private let feedTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = false
        tableView.isScrollEnabled = false
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
    
    // 새로운 init 메서드 추가
    init(mode: EditMode, completionHandler: ((FeedItem, [UIImage]) -> Void)? = nil) {
        self.mode = mode
        self.completionHandler = completionHandler
        super.init(nibName: nil, bundle: nil)
        
        switch mode {
        case .create:
            self.navigationItem.title = "새 피드 작성"
        case .edit(let feedItem, let images):
            self.navigationItem.title = "피드 수정"
            self.viewModel.userFeed = feedItem
            self.selectedImages = images
            self.existingFeedItem = feedItem
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        let finalImages = existingImages + selectedImages // 기존 + 새로운 이미지 유지
        
        switch mode {
        case .create:
            viewModel.userFeed.id = UUID().uuidString
            viewModel.createFeed(viewModel.userFeed, images: finalImages)
        case .edit(let feedItem, _):
            viewModel.userFeed.id = feedItem.id
            viewModel.updateFeed(viewModel.userFeed, images: finalImages)

            // ✅ 이미지가 변경되었을 경우에도 반영되도록 개선
            DispatchQueue.main.async {
                self.completionHandler?(self.viewModel.userFeed, finalImages)
            }
        }
        
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
            
            // 기존 이미지 불러오기
            if !selectedImages.isEmpty {
                cell.updateImages(selectedImages)
            }
            
            cell.selectionStyle = .none
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleInputCell.reuseIdentifier, for: indexPath) as? TitleInputCell else { return UITableViewCell()}
            
            // 기존 제목 불러오기
            if let existingTitle = existingFeedItem?.title {
                cell.calledTitleTextField().text = existingTitle
            }
            
            cell.calledTitleTextField().delegate = self
            return cell
            
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContentInputCell.reuseIdentifier, for: indexPath) as? ContentInputCell else { return UITableViewCell() }
            
            // 기존 내용 불러오기
            if let existingContent = existingFeedItem?.contents {
                cell.calledTextView().text = existingContent
            }
            
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
    func didDeleteImage(in cell: ImageSelectedCell, deletedImage: UIImage?) {
        guard let deletedImage = deletedImage else { return }

        // ✅ 기존 이미지(`existingImages`)인지 확인 (이미 FileManager에 저장된 이미지)
        if let index = existingImages.firstIndex(of: deletedImage) {
            let relativePath = existingFeedItem?.imagePath[index] // 저장된 경로 가져오기

            if let relativePath = relativePath {
                // ✅ FileManager에서 삭제
                FeedStorageManager.shared.deleteImages(from: [relativePath])

                // ✅ Core Data에서 이미지 경로 제거
                existingFeedItem?.imagePath.remove(at: index)
            }

            // ✅ 기존 이미지 배열에서 삭제
            existingImages.remove(at: index)
        }

        // ✅ 새로운 이미지(`selectedImages`)인지 확인 (아직 저장되지 않은 이미지)
        else if let index = selectedImages.firstIndex(of: deletedImage) {
            selectedImages.remove(at: index)
        }

        // ✅ UI 업데이트
        cell.updateImages(existingImages + selectedImages)
        feedTableView.reloadData()
    }

    
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
        var newImages: [UIImage] = []
        //selectedImages.removeAll()
        
        
        for item in results {
            group.enter()
            item.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    newImages.append(image)
//                    self.selectedImages.append(contentsOf: newImages)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.selectedImages = newImages + self.selectedImages // 기존 이미지 반영하지 않고, 새로운 이미지만 유지
            self.feedTableView.reloadData()
        }
    }
}


// MARK: - Extension: UITextFieldDelegate, UITextViewDelegate
extension FeedViewController: UITextFieldDelegate, UITextViewDelegate {
    
    // 플레이스홀더 텍스트 설정
    private func setTextFieldPlaceholder(_ textField: UITextField) {
        textField.text = "글 제목을 입력해주세요 😀"
        textField.textColor = .secondaryLabel
    }
    
    private func setTextViewPlaceholder(_ textView: UITextView) {
        textView.text = "오늘 하루는 어땠나요? 😀"
        textView.textColor = .secondaryLabel
    }
    
    // 제목 입력 완료 시 (텍스트 필드)
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        viewModel.userFeed.title = text
        
        if text.isEmpty {
            setTextFieldPlaceholder(textField)
        }
    }
    
    // 제목 입력 시작 시 (플레이스홀더 제거)
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "글 제목을 입력해주세요 😀" {
            textField.text = ""
            textField.textColor = .label
        }
    }
    
    // 내용 변경 시 (텍스트 뷰)
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.userFeed.contents = text
    }
    
    // 내용 입력 시작 시 (플레이스홀더 제거)
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "오늘 하루는 어땠나요? 😀" {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    // 내용 입력 종료 시 (빈 경우 플레이스홀더 추가)
    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            setTextViewPlaceholder(textView)
        }
    }
}


enum EditMode {
    case create   // 새 피드 생성
    case edit(FeedItem, [UIImage])    // 기존 피드 수정
}
