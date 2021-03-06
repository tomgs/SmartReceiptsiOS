//
//  CategoriesView.swift
//  SmartReceipts
//
//  Created by Bogdan Evsenev on 15/07/2017.
//  Copyright © 2017 Will Baumann. All rights reserved.
//

import UIKit
import Viperit
import RxSwift

//MARK: - Public Interface Protocol
protocol CategoriesViewInterface {
}

//MARK: CategoriesView Class
final class CategoriesView: FetchedTableViewController {
    
    @IBOutlet private weak var addItem: UIBarButtonItem!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = LocalizedString("menu_main_categories")
        
        addItem.rx.tap.subscribe(onNext: {
            _ = self.showEditCategory().bind(to: self.presenter.categoryAction)
        }).disposed(by: bag)
        
        dataSource.canMoveRow = { _ in true }
        dataSource.moveRow = { [unowned self] from, to in
            let categoryOne = self.fetchedItems[from.row] as! WBCategory
            let categoryTwo = self.fetchedItems[to.row] as! WBCategory
            self.presenter.reorderSubject.onNext((categoryOne, categoryTwo))
        }
        
        navigationController?.setToolbarHidden(false, animated: false)
        navigationController?.toolbar.barTintColor = AppTheme.toolbarTintColor
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [space, self.editButtonItem]
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    override func configureCell(row: Int, cell: UITableViewCell, item: Any) {
        let category = item as! WBCategory
        cell.textLabel?.text = category.name
        cell.detailTextLabel?.text = category.code
    }
    
    override func createFetchedModelAdapter() -> FetchedModelAdapter? {
        return presenter.fetchedModelAdapter()
    }
    
    override func delete(object: Any!, at indexPath: IndexPath) {
        presenter.deleteSubject.onNext(object as! WBCategory)
    }
    
    override func tappedObject(_ tapped: Any, indexPath: IndexPath) {
        let category = tapped as! WBCategory
        showEditCategory(category).bind(to: presenter.categoryAction).disposed(by: bag)
    }
    
    func showEditCategory(_ category: WBCategory? = nil) -> Observable<CategoryAction> {
        return Observable<CategoryAction>.create({ [unowned self] observer -> Disposable in
            
            let isEdit = category != nil
            let title = isEdit ? LocalizedString("dialog_category_edit") :
                                 LocalizedString("dialog_category_add")
            
            
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = LocalizedString("item_name")
                textField.text = category?.name
            }
            
            alert.addTextField { textField in
                textField.placeholder = LocalizedString("item_code")
                textField.text = category?.code
            }
            
            let saveTitle = isEdit ? LocalizedString("update") :
                                     LocalizedString("add")
            alert.addAction(UIAlertAction(title: saveTitle, style: .default, handler: { [unowned self] _ in
                let forSave = category ?? WBCategory()
                let name = alert.textFields!.first!.text
                if self.validate(name: name) {
                    forSave.name = name
                    forSave.code = alert.textFields!.last!.text
                    forSave.customOrderId = isEdit ? forSave.customOrderId : 0
                    observer.onNext((category: forSave, update: isEdit))
                }
            }))
            
            alert.addAction(UIAlertAction(title: LocalizedString("DIALOG_CANCEL"),
                                          style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            return Disposables.create()
        })
    }
    
    private func validate(name: String?) -> Bool {
        if name == nil || name!.isEmpty {
            presenter.presentAlert(title: nil, message: LocalizedString("edit_payment_method_controller_save_error_message"))
            return false
        }
        return true
    }
}

//MARK: - Public interface
extension CategoriesView: CategoriesViewInterface {
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension CategoriesView {
    var presenter: CategoriesPresenter {
        return _presenter as! CategoriesPresenter
    }
    var displayData: CategoriesDisplayData {
        return _displayData as! CategoriesDisplayData
    }
}
