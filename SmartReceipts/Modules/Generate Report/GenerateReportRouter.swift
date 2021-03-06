//
//  GenerateReportRouter.swift
//  SmartReceipts
//
//  Created by Bogdan Evsenev on 07/06/2017.
//  Copyright © 2017 Will Baumann. All rights reserved.
//

import Foundation
import Viperit

class GenerateReportRouter: Router {
    func close() {
        _view.dismiss(animated: true, completion: nil)
    }
    
    func openSheet(title: String?, message: String?, actions: [UIAlertAction]) {
        let sheet = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            sheet.addAction(action)
        }
        _view.present(sheet, animated: true, completion: nil)
    }
    
    func openSettingsOnDisatnce() {
        openSettings(option: .distanceSection)
    }
    
    func openSettingsOnReportLayout() {
        AnalyticsManager.sharedManager.record(event: Event.informationalConfigureReport())
        openSettings(option: .reportCSVOutputSection)
    }
    
    func openSettings(option: ShowSettingsOption) {
        let module = AppModules.settings.build()
        module.presenter.setupView(data: option)
        executeFor(iPhone: {
            module.router.show(from: _view, embedInNavController: true)
        }, iPad: {
            module.router.showIPadForm(from: _view, needNavigationController: true)
        })
    }
    
    func open(vc: UIViewController, animated: Bool = true, isPopover: Bool = false, completion: (() -> Void)? = nil) {
        if isPopover {
            // For iPad
            if let popover = vc.popoverPresentationController {
                popover.permittedArrowDirections = .up
                popover.sourceView = _view.view
                popover.sourceRect = _view.navigationController?.navigationBar.frame ?? _view.view.frame
            }
        }
        _view.present(vc, animated: animated, completion: completion)
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension GenerateReportRouter {
    var presenter: GenerateReportPresenter {
        return _presenter as! GenerateReportPresenter
    }
}
