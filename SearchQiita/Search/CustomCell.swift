//
//  CustomCell.swift
//  SearchQiita
//
//  Created by 本川晴彦 on 2023/07/26.
//

import UIKit
import Kingfisher

final class CustomCell: UITableViewCell {

    static var className: String { String(describing: CustomCell.self) }

    @IBOutlet private weak var iconImageView: UIImageView! {
        didSet {
            iconImageView.image = defaultImage
        }
    }

    @IBOutlet private weak var userLabel: UILabel!

    @IBOutlet private weak var titleLabel: UILabel!

    private let defaultImage = UIImage(systemName: "square.and.arrow.down")

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = defaultImage
        titleLabel.text = nil
        userLabel.text = nil
    }

    internal func configure(qiitaItemModel: QiitaItemModel) {
        iconImageView.kf.indicatorType = .activity
        iconImageView.kf.setImage(with: qiitaItemModel.imageUrl, placeholder: defaultImage)
        titleLabel.text = qiitaItemModel.title
        userLabel.text = qiitaItemModel.user.name
    }
}
