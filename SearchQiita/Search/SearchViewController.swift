//
//  SearchViewController.swift
//  SearchQiita
//
//  Created by 本川晴彦 on 2023/07/26.
//

import UIKit

final class SearchViewController: UIViewController {


    @IBOutlet private weak var myArticleButton: UIButton! {
        didSet {
            myArticleButton.addTarget(self, action: #selector(showMyArticle), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }

    @IBOutlet private weak var searchButton: UIButton! {
        didSet {
            searchButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
        }
    }

    @IBOutlet private weak var resultTableView: UITableView! {
        didSet {
            let cellNib = UINib(nibName: CustomCell.className, bundle: nil)
            resultTableView.register(cellNib, forCellReuseIdentifier: CustomCell.className)
            resultTableView.dataSource = self
            resultTableView.delegate = self
        }
    }

    private var qiitaItems: [QiitaItemModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @objc private func reload() {
        print("ボタンタップしたで")
        guard let inputText = searchTextField.text else { return }
        guard !inputText.isEmpty else { return }

        QiitaAPI.shared.getItems(inputText: inputText) { [weak self] result in
            guard let self else { return }
            view.endEditing(true)
            switch result {
                case .success(let item):
                    print("検索成功したで")
                    qiitaItems = item
                    print("qiitaItems.count:\(qiitaItems.count)")
                    resultTableView.reloadData()
                case .failure(let error):
                    print("errorですよ：\(error)")
            }
        }
    }

    @objc private func showMyArticle() {
        QiitaAPI.shared.getMyArticle { [weak self]result in
            guard let sSelf = self else { return }
            switch result {
                case .success(let items):
                    sSelf.qiitaItems = items
                    sSelf.resultTableView .reloadData()
                case .failure(let error):
                    print(error)
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print(qiitaItems[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        Router.shared.showWeb(from: self, qiitaItemModel: qiitaItems[indexPath.row])

    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return qiitaItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = resultTableView.dequeueReusableCell(withIdentifier: CustomCell.className, for: indexPath) as? CustomCell  else {
            return UITableViewCell()
        }
        let qiitaItemModel = qiitaItems[indexPath.row]
        cell.configure(qiitaItemModel: qiitaItemModel)
        return cell
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


