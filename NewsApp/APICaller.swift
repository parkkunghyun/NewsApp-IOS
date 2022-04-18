//
//  APICaller.swift
//  NewsApp
//
//  Created by 박경현2 on 2022/03/20.
//

import Foundation

final class APICaller {
    // 싱글턴 패턴 Singleton Pattern  => 생성자가 여러차례호출되더라도 실제로 생성되는 객체는 하나이고 최초생성이후에 호출된 생성자는 최초의 생성자가 생성한 객체를 리턴한다
    
    // static프로퍼티로 instance생성하기 -> 전역으로 저장하기 위해서!!
    // 이렇게 하면 자동으로 클래스를 사용하는 시점에 초기화(lazy) 된다!!
    // 그래서 최초생성되기전까지 메모리에 올라가지않고 Dispatch_one(1회만 실행하는것을 보장하는 애)도 자동적용된다!
    
    /**
        장점: 전역인스턴스여서 다른 클래스들과 자원공유가 쉽다! DBCP(database connection pool)처럼 공통된 객체를 여러개 생성해서 사용해햐하는 상황에서 많이 사용(쓰레드퓰, 캐시, 대화상자, 사용자설정, 레지스트리설정 ,로그 기록대체등 ) -> 우리는 레지스트리 캐시
     
        단점: 싱글 객체가 너무많은일을 하거나 많은 데이터를 공유할경우 다른 클래스트의 인스턴스들간 결합도가 높아져 "개방= 폐쇄" 원칙으 위해함 수정과 테스트가 어려워진다
     */
    
    // 차고로 DBCP란 데이터베이스와 어플리케이션을 효율적으로 연결하는 커넥션 풀 ㅇ라이브러리를 의미한다
    // dbConnection을 pool이라는공간에 저장하고 필요할때마다 가져다 쓰고 반환가능!
    //
    static let shared = APICaller()
    
    struct Constants {
        static let topHeadlinesURL = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=4b3436d4fe8146a0a6f8c7ca141d53a6")
    }
    
    // 혹시라도 init함수를 호출해 instance를 또 생성하는것을 막기위해 private로 지정!
    private init(){}
    
    // @escaping클로저는 클로저가 함수의 인자로 전달됐을때, 함수의 실행이 종료된 후 실행되는 클로저 입니다.
    // Non-Escaping 클로저는 함수의실행이 종료되기전에 실행되는함수!!
    // 차고로 escaping해도 non으로 사용할수잇지만 컴파일러의 퍼포먼스최척화를 위해서 그건패스
    
    // completion안에 저장했다가 나중에 함수 종료되고 꺼내기!!!
    // ㅕURL 요청이 끝나고나서야 비동기로 실행횐다!
    public func getTopStories(completion: @escaping (Result<[Article], Error> )-> Void){
        guard let url = Constants.topHeadlinesURL else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {
            // HTTP의 각종 메서드를 이용해 서버로부터 응답데이터를 받아서 Data객체를 가져오는 작업을 수행
            data, _, error in
            if let error = error {
                completion(.failure((error)))
            }else if let data = data {
                do{
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    
                    // 가져온 API를 우리가 원하는형태로 바꿘다
                    
                    print("Articles: \(result.articles.count)")
                    completion(.success(result.articles))
                    
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}

//Model


struct APIResponse: Codable {
    let articles: [Article]
}
struct Article: Codable {
    let source: Source
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
    
}
struct Source: Codable {
    let name: String
}
