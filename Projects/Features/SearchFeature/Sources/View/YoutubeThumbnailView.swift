import SnapKit
import Then
import UIKit

class YoutubeThumbnailView: UICollectionViewCell {
    var thumbnailView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension YoutubeThumbnailView {
    func configureUI() {
//        contentView.addSubview(thumbnailView)
//
//        thumbnailView.snp.makeConstraints {
//            $0.verticalEdges.horizontalEdges.equalToSuperview()
//        }
//
        contentView.backgroundColor = .orange
    }
}
