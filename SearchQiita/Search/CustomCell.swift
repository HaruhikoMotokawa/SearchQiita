//
//  CustomCell.swift
//  SearchQiita
//
//  Created by 本川晴彦 on 2023/07/26.
//

import UIKit
import Kingfisher
/// カスタムセル
final class CustomCell: UITableViewCell {
    /// セルの登録に使用するためのプロパティ
    static var className: String { String(describing: CustomCell.self) }
    /// 記事の投稿者アイコンを表示
    @IBOutlet private weak var iconImageView: UIImageView! {
        didSet {
            iconImageView.image = defaultImage
        }
    }
    /// 記事の投稿者名を表示
    @IBOutlet private weak var userLabel: UILabel!
    /// 記事のタイトルを表示
    @IBOutlet private weak var titleLabel: UILabel!
    /// 記事の投稿者アイコンのデフォルトアイコン
    private let defaultImage = UIImage(systemName: "square.and.arrow.down")

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    /// 表示するデータを受け渡すメソッド
    internal func configure(qiitaItemModel: QiitaItemModel) {
        // ダウンロード中のインジケーターを表示
        iconImageView.kf.indicatorType = .activity
        // アイコンの表示、プレースホルダー画像にdefaultImageを指定
        iconImageView.kf.setImage(with: qiitaItemModel.imageUrl, placeholder: defaultImage)
        titleLabel.text = qiitaItemModel.title
        userLabel.text = qiitaItemModel.user.name
    }
}
