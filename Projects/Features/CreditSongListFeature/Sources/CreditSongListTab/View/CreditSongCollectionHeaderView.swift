import SnapKit
import Then
import UIKit
import Utility

final class CreditSongCollectionHeaderView: UICollectionReusableView {
    private let randomPlayButton = RandomPlayButton()
    private var playButtonHandler: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        bind()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layer.zPosition = 1
    }

    func setPlayButtonHandler(handler: @escaping () -> Void) {
        self.playButtonHandler = handler
    }

    private func setupViews() {
        addSubview(randomPlayButton)
        randomPlayButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func bind() {
        randomPlayButton.addAction { [weak self] in
            self?.playButtonHandler?()
        }
    }
}