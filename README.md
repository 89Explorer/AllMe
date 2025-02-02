# AllMe

<img src="https://github.com/user-attachments/assets/3f4e8266-aec8-4972-b271-320f4306206b" width="200" height="200"/>
<br/>

## 📌 앱 소개
  - AllMe는 사용자가 자신의 피드를 작성하고 관리할 수 있는 iOS 애플리케이션입니다.
  - Core Data, FileManaager를 활용하여 사용자 데이터를 저장합니다.
  - 직관적인 UI를 제공하여 쉽게 피드를 작성하고 관리할 수 있도록 설계되었습니다.
  - 데이터의 흐름을 효율적으로 관리하기 위해 Combine + MVVM 기반 CRUD 구현했습니다.
<br/>


## ✨ 주요 기능
  - Facebook, Google 소셜 로그인, 로그아웃이 가능합니다.
  - 피드 작성: 사용자가 자신의 피드를 작성하고 저장할 수 있습니다.
  - Core Data 연동: 데이터를 로컬에 저장하고, 앱이 종료되어도 유지됩니다.
<br/>


## 📸 스크린샷
<img src="https://github.com/user-attachments/assets/96eeddf7-f0be-4948-a900-b9156d7f0f99"/>
<img src="https://github.com/user-attachments/assets/644eda4d-72b4-4827-ae23-4fbd24747412"/>
<br/>


## 🎥 시연 영상
<p align="center">
<img src="https://github.com/user-attachments/assets/e223cd83-ea6d-41cb-b8af-847f905de235" height="400"/>
<img src="https://github.com/user-attachments/assets/bdf50751-d78a-403b-81d1-e47bd7c2bcf2" height="400"/>
<img src="https://github.com/user-attachments/assets/4df5f0c9-77c0-4564-bc6d-605e2cb67ab9" height="400"/>
<img src="https://github.com/user-attachments/assets/74c1a6ed-88a2-4f40-bd07-0e737d2b49fc" height="400"/>
</p>
<br/>


## 🔧 앱 개발 환경
- 개발 언어: Swift
- 개발 도구: Xcode
- 데이터 관리: Core Data
- 회원 관리: Firebase
- 아키텍처: MVVM + Combine
<br/>


## ⚙️ 구현 고려사항
- Firebase에서 제공하는 소셜로그인 사용
- FileManager로 이미지를 저장 및 경로 반환
- CoreData에서 텍스트 및 이미지 경로 저장
- 피드 작성 및 수정 페이지는 공용으로 사용
- Combine + MVVM 아키텍처를 적용하여 보다 효율적인 데이터 흐름 관리
<br/>


## 🛠 개발 기간
- 개발 기간: 3주
- 개발 인원: 1인
<br/>


## 👏🏻 회고
이 전에 DailyNote 앱을 만들었는데, 해당 앱도 AllMe와 마찬가지로 개인 피드 작성 및 저장이 가능했습니다. 
이 때는 MVC패턴을 사용하여 CoreData 및 FileManager의 메서드를 직접 호출해서 사용했습니다. 

DailyNote를 만들면서 겪었던 불편함이 "유지보수" 입니다. 

이번에 AllMe는 개인 피드 관리하는 앱으로, 이전의 DailyNote와 동일한 기능을 합니다. 다만, DailyNote를 만들면서 겪었떤 유지보수 및 UI 업데이트 부분을 ${\textsf{\color{green}Combine + MVVM}}$ 을 활용하여 데이터 관리를 효율적으로 수행하는데 초점을 맞추어 개발되었습니다. 🚀


📌 MVC에서 발생하는 문제 (DailyNote)

```
class FeedViewController: UIViewController {
    let coreDataManager = CoreDataManager()

    func saveFeed(title: String, content: String) {
        coreDataManager.saveFeed(title: title, content: content) // CoreData 직접 호출
        loadFeeds()
    }

    func loadFeeds() {
        let feeds = coreDataManager.fetchFeeds() // CoreData 직접 호출
        updateUI(with: feeds)
    }
}

```

❌ 문제점
- CoreDataManager의 메서드가 변경되면, ViewController에서도 변경이 필요.
- ViewController가 데이터 로직을 직접 다루므로 강한 결합도가 발생.
- 유지보수할 때 모든 ViewController에서 CoreData를 수정해야 함.

<br/>

📌 MVVM + Combine에서 해결되는 문제 (AllMe)
```
class FeedManager {
    
    static let shared = FeedManager()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let storageManager = FeedStorageManager.shared
    
    // MARK: - Create
    func createFeed(_ feed: FeedItem, images: [UIImage]) -> AnyPublisher<FeedItem, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            let savedPaths = self.storageManager.saveImages(images: images, feedID: feed.id)
            var updatedFeed = feed
            updatedFeed.imagePath = savedPaths
            
            let feedModel = FeedModel(context: self.context)
            feedModel.id = updatedFeed.id
            feedModel.title = updatedFeed.title
            feedModel.content = updatedFeed.contents
            feedModel.date = updatedFeed.date
            feedModel.imagePath = updatedFeed.imagePath.isEmpty ? nil : updatedFeed.imagePath.joined(separator: ",")
            
            do {
                try self.context.save()
                print("Feed + images saved successfully to CoreData.")
                promise(.success(updatedFeed)) 
            } catch {
                print("Failed to save feed: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
```

<br/>

```
class FeedItemViewModel: ObservableObject {
    @Published var userFeed: FeedItem = FeedItem(id: "")
    @Published var feeds: [FeedItem] = []
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let feedManager = FeedManager.shared
    
    
    // MARK: - Create
    func createFeed(_ feed: FeedItem, images: [UIImage]) {
        feedManager.createFeed(feed, images: images)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] savedFeed in
                self?.feeds.append(savedFeed)
                self?.userFeed = FeedItem(id: "")
            })
            .store(in: &cancellables)
    }
```

```
class FeedViewController: UIViewController {
    private let viewModel = FeedItemViewModel()
    private var cancellables = Set<AnyCancellable>()
    ...

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        registerFeedButton.addTarget(self, action: #selector(registerFeed), for: .touchUpInside)
        ...
    }

    private func setupBindings() {
          viewModel.$feeds
              .receive(on: RunLoop.main)
              .sink { [weak self] _ in
                  self?.feedTableView.reloadData()
              }
              .store(in: &cancellables)

          viewModel.$errorMessage
              .compactMap { $0 }
              .receive(on: RunLoop.main)
              .sink { errerMessage in
                  print("Error: \(errerMessage)")
              }
              .store(in: &cancellables)
      }

    @objc private func registerFeed() {
    
    let finalImages = existingImages + selectedImages 
    
    switch mode {
    case .create:
        viewModel.userFeed.id = UUID().uuidString
        viewModel.createFeed(viewModel.userFeed, images: finalImages)

    case .edit(let feedItem, _):
        viewModel.userFeed.id = feedItem.id
        viewModel.updateFeed(viewModel.userFeed, images: finalImages)

        DispatchQueue.main.async {
            self.completionHandler?(self.viewModel.userFeed, finalImages)
        }
    }
    dismiss(animated: true)
}

```

✅ MVVM + Combine의 장점
- CoreData의 변경이 ViewModel에서만 이루어짐
→ ViewController는 ViewModel의 데이터를 구독만 하므로 CoreDataManager의 변경이 UI에 직접 영향을 주지 않음.

- ViewController의 역할이 단순해짐
→ ViewModel을 구독하기만 하면 UI 업데이트가 자동으로 이루어짐.
→ UI와 데이터 로직이 분리되어 유지보수 용이.

- 자동 UI 업데이트
→ viewModel.$feeds가 변경될 때마다 자동으로 UI 업데이트 (tableView.reloadData()).

<br/>
📝 정리

- MVC (DailyNote) → CoreData 로직을 수정하면 모든 ViewController에서 직접 수정 필요 ❌
- MVVM + Combine (AllMe) → CoreData 로직이 수정되어도 ViewModel만 변경하면 자동 반영 ✅

















