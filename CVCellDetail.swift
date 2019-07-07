

import UIKit
import SDWebImage

class CVCellDetail: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate  {

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightCell: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var date: UILabel!
    
    var detail:Modal?
    var modals = [Modal]()
    //анимация загрузки
    let preload = Preload()
    var isAnimate = true
    
    weak var delegate:PresenTVCellProtocol?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        Downloader.shared.deleteSingleTask(url: "https://stmegi.com\(detail!.ImageViewURL!)")
        YouTubeManager.shared.removeVideo(textView: textView)
        textView.attributedText = nil
        scrollView.scrollToTop(animated: false)
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            AMShimmer.start(for: self.tableView)
        }
    }
    
    //вызывается из cellForRowAt
    func start(){
        
        setting()
        info()
        requestD(url: UrlSameNews)
        
    }
    
    func setting(){
        
        tableView.dataSource = self
        tableView.delegate = self
        
        preload.start(view:self.contentView, scroll: scrollView)
        AMShimmer.start(for: self.ImageView, except: [], isToLastView: false)
        
    }
    
    // задает текст
    @objc func info(){
        
        // текст с фотографиями и видео
        DispatchQueue.global(qos: .userInteractive).async {
            self.textView.convertToInlineImageFormat(htmlString: self.detail?.text ?? "")
            DispatchQueue.main.async {
                self.preload.stop(scroll: self.scrollView)
            }
        }
        
        date.sizeToFit()
        date.text = detail?.date
        
        name.sizeToFit()
        name.text = detail?.name
        
        
        if detail?.ImageView == nil {
            Downloader.shared.download(url: "https://stmegi.com\(detail!.ImageViewURL!)") { [weak self] (image) in
                self?.detail?.ImageView = image
                self?.ImageView.image = image
                self?.imageSize()
            }
        } else {
            ImageView.image = detail?.ImageView
            imageSize()
        }
        
    }
    
    //меняет размер фотографии
    @objc func imageSize(){
        
        guard let image = ImageView.image else { return }
        ImageView.image = Extension.resizeImage(image: image, targetSize: CGSize.init(width: scrollView.frame.size.width, height: scrollView.frame.height/2))
        DispatchQueue.main.async {
            AMShimmer.stop(for: self.ImageView)
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !isAnimate else { return 10 }
        return modals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCellNews
        if !isAnimate {
            cell.configure(modal: modals[indexPath.row], indexPath: indexPath, completion: { [weak self] (data) in
                self?.modals[indexPath.row] = data
            })
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.presentVC?(modals:modals, indexPath: indexPath)
    }
    
    @objc func requestD(url:String){
        
        guard self.modals.count == 0 else { return }
        heightCell.constant = CGFloat(10 * 80)
        
        DispatchQueue.global().async {
            SmartNetworkService.getData(with: url) {  [weak self] (error, data) in
                guard let data = data?.modals, data.count != 0, let tv = self?.tableView else { return }
                DispatchQueue.main.async {
                    self?.modals.append(contentsOf: data)
                    self?.isAnimate = false
                    self?.heightCell.constant = CGFloat(data.count * 80)
                    self?.tableView.reloadData()
                    AMShimmer.stop(for: tv)
                }
            }
        }
        
    }
    
}
