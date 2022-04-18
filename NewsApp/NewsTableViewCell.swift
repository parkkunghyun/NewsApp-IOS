//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by 박경현2 on 2022/03/20.
//

import UIKit

class NewsTableViewCellViewModel {
    
    let title: String
    let subtitle: String
    let imageURL: URL?
    var imageData: Data? = nil
    
    init(title: String, subtitle: String, imageURL: URL?){
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
    }
}

class NewsTableViewCell: UITableViewCell {

    static let identifier = "NewsTableViewCell"
    // 전역변수로 설정해야 밖에서도 부르기 편하기때문에 그렇게 한듯?>
    
    private let newsTitleLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let subTitleLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0 // 무한으로 아래에 줄바꿈가능
        label.font = .systemFont(ofSize: 17, weight: .light)
        return label
    }()
    
    private let newsImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true // bool 변수이고 true일때 내용이 기준보다 넘치면 짤림
        // 이미지뷰를 기쥰으로 그 밖에있는건 들어오지도 못하고 걍 나가지도못함
        
        imageView.clipsToBounds = true // 위에꺼랑 토시하나 안틀리고 같은 역할을 한다 왜 두개적었지??
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill // 콘텐츠의 비율을 유지하여 view크기에 맞게 확장하는 옵션, 빈영역없이 다 채운다 일부내용은 짤릴수도 있다
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(newsTitleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(newsImageView)
    }
    
    // UIView를 상속받아서 생성자를 사용하려고 하면 꼭 필요함! 스토리보드나 xib파일을 이용해 UI를 구성하여 이를 그대로 사용하는것이 가능하다 -> NSCoding이 있어서 가능!! 인터페이스파일은 UI의 구성을 xml형태로 저장하고있는데 이 저장한 형태를 사용자의 화면으로 그대로 가져오기 위해서는 이 파일에 대한구성을 가져오는것을 deserialzation이라고 한다.
    // xib나 스토리보드에서 생성이 될때는 따라서 init를 통해서 객체가 생성
    
    // IBOutlet울 통한객체는 이거 필요없음 같은 시점에 처리를해서
    required init?(coder: NSCoder){
        // NSCoder는 다른개체의 보관및 배포를 가능하게 하는 개체의 기반역할을 하는 추상클래스이다
        //
        // 아래 있는 프로그래머의 실수에 대한 에러를 말한다
        // 호출즉시 크래시를 발생시켜 프로세스를 죽임 -> 에러치명적이거나 메소드가 리턴할것이없을때
        fatalError()
    }
    
    override func layoutSubviews() {
        // 뷰의크기가 변경될때마다 이에 대응하여 하위뷰들의 크리& 위치를 조정해주는애!
        
        super.layoutSubviews()
        
        newsTitleLabel.frame = CGRect(x: 10,
                                      y: 0,
                                      width: contentView.frame.size.width - 170,
                                      height: 70
        )
        
        subTitleLabel.frame = CGRect(x: 10,
                                      y: 70,
                                      width: contentView.frame.size.width - 170,
                                      height: contentView.frame.size.height / 2
        )
        
        newsImageView.frame = CGRect(x: contentView.frame.size.width - 150,
                                      y: 5,
                                      width: 140,
                                      height: contentView.frame.size.height - 10
        )
    }
    override func prepareForReuse() {
        // 셀을 재사용하기 때문에 재사용하기전에 다시 prepare해주는 작업!
        super.prepareForReuse()
        newsTitleLabel.text = nil
        subTitleLabel.text = nil
        newsImageView.image = nil
        
    }
    
    func configure(with viewModel: NewsTableViewCellViewModel)
    {
        newsTitleLabel.text = viewModel.title
        subTitleLabel.text = viewModel.subtitle
        
        // image
        // 이미지가 data로 올때와 URL로 올때 다르게 만들었다.
        if let data = viewModel.imageData {
            newsImageView.image = UIImage(data: data)
            
        }else if let url = viewModel.imageURL {
            //fetch
            URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.newsImageView.image = UIImage(data: data)
                    
                }
            }.resume()
            
        }
        
    }
}
