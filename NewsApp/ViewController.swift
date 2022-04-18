//
//  ViewController.swift
//  NewsApp
//
//  Created by 박경현2 on 2022/03/20.
//

import UIKit
import SafariServices
// 이거는 SFSafariViewcontroller를 불러서 사파리의 기능을 전부사용가능! 다만 url입력은 불가느우
// 사파리와 쿠키정보들을 공유 이정보들을 앱에선느 사용할수는없다 delegate를 이용해 어떤이벤트가들어왔을때 전달하는것도 가능!
// 쿠키는 서버로부터 받아 사용자의 브라우저에 저장하는 작은 데이터
// 쿠키는 귀하가 웹사이트나 모바일앱을 방문할때 웝서버에서 귀하의 쿰퓨터 또는 휴대전화 기타인터넷사용기기에 보낸 고유식별자를포함하는 작은 텍스트 파일!!

// ios에서는 쿠키관리가 자동으로 이루어져서 별도로 저장하거나 입력필요없다
/**
  var access_token_parameters: NSDictionary = [NSHTTPCookieDomain: "requestb.in",
                                    NSHTTPCookiePath: "/",
                                    NSHTTPCookieName: "access_token",
                                    NSHTTPCookieValue: "value"]
 var cookie : NSHTTPCookie = NSHTTPCookie(properties: acess_token_parameters)
 NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
 */

// safari를 열어서 웹페이지를 로딩하는방법!!
// 장점은 간단함! 단점은 커스텀이 전혀 불가능하고 이벤트를받아오는등의 상호작용은 힘들다
/**
 @IBAction func openSafariApp(_ sender: Any){
    guard let appleUrl = URL(string "https://wwweapple.com") else {return}
    guard UIApplication.shared.canOpenURL(appleUrl) else {return}
 
    UIApplication.shared.open(appleUrl, options: [:], completionHandler: nil)
 }
 */


// Tableview
// customCell
//APIO caller
// open the newssrot
//searchfor newsstory


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // uitableViewDataSource는 데이터를 관리! -> 색션과행수알려줌 각행마다 셀을 제공 header와 footer제공 사용자나 테이블의 데이터가 변경되었으면 업데이트
    // row는 각 행이지만 section의 경우 따로 설정안하면 없다!!
    
    
    // UITableViewDelegate 라는 객체를 생성해서 그 delegate안에있는 메서드와 관련된 이벤트가 발생시 그 일을 UITableViewDelegate라는 객체에서 처리해준다!
    
    private let tableView: UITableView = {
        let table = UITableView()
        // cell을 등록하기
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        
        return table
    }()
    
    
    private var articles = [Article]() // 기사에 대한 배열을 넣어주는거
    private var viewModels = [NewsTableViewCellViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"
        view.addSubview(tableView)
        // self가 대신해줘 라는 의미!
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .systemBackground
        
        APICaller.shared.getTopStories {[weak self] result in
            // [weak self] 이거 안하면 클로저는 셀프가 해제될때까지 기다리고 셀프는 클로저가 끝날때까지 기다린다!
            
            switch result {
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap ({
                    // compactMap은 1차원배열일때는 nil을 제거하고 2차원부터는 그냥 nil도 적어주네
                    // 2차원도 걍 1차원처럼 펴서 쓰고 싶으면 flatMap을 사용하면된다.
                    //
                    NewsTableViewCellViewModel(
                        // 클로저의 첫번째인자 $0 두번째 인자 $1
                        title: $0.title,
                        subtitle: $0.description ?? "No Description" ,
                        imageURL: URL(string: $0.urlToImage ?? ""))
                })
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        // 레이아웃이결정되고 나서 아래와 같은 일을 수행하고자 할때 이 메서드롤 오버라이드함
        // 다른 뷰들의 컨텐트 업데이트
        // 뷰들의 크기 최종조정 및 테이블 데이터를 reload
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
        //필요메서드 dataSource
        // 테이블뷰의 섹션 인덱스를 가지고 섹션안에 포함된 셀수를 알려주는 메서드
    }
    
    // func numberOfSections(in: UITableView) -> Int 테이블뷰의 전체 섹션수알려주는 메서드
    // func tableView(UITableView, cellForRowAt: indexPath) -> UITableViewCell 테이블뷰에서 특정 index에 있는셀을 알려준다
    
    // func tableView(UITableview, titleForHeaderInSection: Int) -> String  테이블뷰에서 특정 section의 header 타이틀을 가져오는 메서드
    // func tableView(UITableview, titleForFootererInSection: Int) -> String  테이블뷰에서 특정 section의 Footer 타이틀을 가져오는 메서드
    
    // func tableView(UITableView, canMoveRowAt: IndexPath_ 0> Bool 주어진 인덱스의 셀이 다른 인덱스로 이동가능한 상태인지 알려준다
    // func tableView(UITableView, moveRowAt: IndexPath, to: IndexPAth)데이블뷰틔 셀을 인덱스를 기반으로 다른곳에 이동시킨다!
    
    // func sectionIndextitles(for: UITableView) -> [String]? 테이블뷰의 모든섹션의 타일틀을 가져오는데 배열로 가져오고 타이틀이없을수도 있어서 옵셔널로 가져오는듯
    
    // func tableView(UITableView, sectionForSectionIndexTitle: String, at: Int) -> Int
    // sectionIndexTitles에서 반환된 Array에서 타이틀과 타이틀의 Array에서의 인덱스를 가지고 특정 섹션의 인덱스를 알려준다
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 필요메서드 dataSource
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for:indexPath) as? NewsTableViewCell else { fatalError("do not anything")
            // 재사용을 사용하는 이유는 메모리관리!!!!!!!!!!!
            // 큐를 사용 dequeue는 큐에서 메모리가 나갈때를 의미한다!!
            
            // 100개이상의 셀들을 각각 만들어 메모리에 할당하게 디면 메모리 낭비가 심하다
            // 셀이 스크린에 벗어난다면 그 셀들을 ReuseQueue에 넣어줫다가 다시 사용하는것!!
            // 모든셀을 메모리에 할당하지 않아도되니 훨씬 효율
            
            // dequeueReusableCell은 재사용 identifier를 가진 테이블뷰 셀 객체를 table에 추가하고 이를 반환한다는것을 알수가 있다!
            //
        }
        
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // row에 해당하는 부분을 클릭하는 이벤트 발생시 어떤 동장을 수행할지 나타내주는 메서드!!
        
        // 특정셀이 클릭될때 클릭된 셀에대한 정보를 다른 뷰컨으로 넘겨주소 싶을대 이 메서드를 ㅏㅅ용해  indexPath에 클릭된 셀에 대한 정보를 index에 담아서 넘겨줄 수 있다.
        
        tableView.deselectRow(at: indexPath, animated: true)
        // 선택한 애를 순간적으로 회색으로 표시했다가 다시 없애주는 효과를 준거
        
        
        // 기사자나
        // 기사들 중 내가 선택한 기사만을 전달!
        // 그거의 url을 가져오기!! 이거는 구조체로 선언해서 가능!
        let article = articles[indexPath.row]
        
        guard let url = URL(string: article.url ?? "") else {
            return
        }
        
        
        let vc = SFSafariViewController(url: url)
        // 뷰를 모달로 간단하게 띄우기 위해서 present를 사용
        present(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // index의 row의 높이를 지정하는 메서드를 구현해줬다
        return 150
    }
    
    
}


