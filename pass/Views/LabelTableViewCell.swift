//
//  LabelTableViewCell.swift
//  pass
//
//  Created by Mingshen Sun on 2/2/2017.
//  Copyright © 2017 Bob Sun. All rights reserved.
//

import passKit
import SVProgressHUD
import UIKit

struct LabelTableViewCellData {
    var title: String
    var content: String
}

class LabelTableViewCell: UITableViewCell {
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!

    private enum CellType {
        case password, URL, HOTP, other
    }

    private var type = CellType.other
    private var isReveal = false

    weak var delegatePasswordTableView: PasswordDetailTableViewController?

    private var passwordDisplayButton: UIButton?
    private var buttons: UIView?

    private lazy var editMenuInteraction = UIEditMenuInteraction(delegate: self)

    override func awakeFromNib() {
        super.awakeFromNib()
        addInteraction(editMenuInteraction)
    }

    var cellData: LabelTableViewCellData? {
        didSet {
            guard let title = cellData?.title, let content = cellData?.content else {
                type = .other
                return
            }
            titleLabel.text = title
            if title.caseInsensitiveCompare("password") == .orderedSame {
                type = .password
                if isReveal {
                    contentLabel.attributedText = Utils.attributedPassword(plainPassword: content)
                } else {
                    if content.isEmpty {
                        contentLabel.text = ""
                    } else {
                        contentLabel.text = Globals.passwordDots
                    }
                }
                contentLabel.font = Globals.passwordFont
            } else if title.caseInsensitiveCompare("HmacBased".localize()) == .orderedSame {
                type = .HOTP
                if isReveal {
                    contentLabel.text = content
                } else {
                    contentLabel.text = Globals.oneTimePasswordDots
                }
                contentLabel.font = Globals.passwordFont
            } else if title.lowercased().contains("url") {
                type = .URL
                contentLabel.text = content
                contentLabel.font = UIFont.systemFont(ofSize: contentLabel.font.pointSize)
            } else {
                // default
                type = .other
                contentLabel.text = content
                contentLabel.font = UIFont.systemFont(ofSize: contentLabel.font.pointSize)
            }
            updateButtons()
        }
    }

    override var canBecomeFirstResponder: Bool {
        true
    }

    // Copy is the only standard edit action; the others are in menuActions.
    override func canPerformAction(_ action: Selector, withSender _: Any?) -> Bool {
        action == #selector(copy(_:))
    }

    // Shows Copy and the actions for this cell's content above the content.
    func showMenu() {
        becomeFirstResponder()
        let frame = contentLabel.convert(contentLabel.bounds, to: self)
        editMenuInteraction.presentEditMenu(with: UIEditMenuConfiguration(identifier: nil, sourcePoint: CGPoint(x: frame.midX, y: frame.minY)))
    }

    private var menuActions: [UIMenuElement] {
        var actions = [UIMenuElement]()
        if type == .password || type == .HOTP {
            if isReveal {
                actions.append(UIAction(title: "Conceal".localize()) { [weak self] _ in self?.concealPassword() })
            } else {
                actions.append(UIAction(title: "Reveal".localize()) { [weak self] _ in self?.revealPassword() })
            }
        }
        if type == .HOTP {
            actions.append(UIAction(title: "NextPassword".localize()) { [weak self] _ in self?.getNextHOTP() })
        }
        if type == .URL {
            actions.append(UIAction(title: "CopyAndOpen".localize()) { [weak self] _ in self?.openLink() })
        }
        return actions
    }

    override func copy(_: Any?) {
        SecurePasteboard.shared.copy(textToCopy: cellData?.content)
    }

    func revealPassword() {
        let plainPassword = cellData?.content ?? ""
        if type == .password {
            contentLabel.attributedText = Utils.attributedPassword(plainPassword: plainPassword)
        } else {
            contentLabel.text = plainPassword
        }
        isReveal = true
        passwordDisplayButton?.configuration?.image = UIImage(systemName: "eye.slash")
    }

    func concealPassword() {
        if type == .password {
            if cellData?.content.isEmpty == false {
                contentLabel.text = Globals.passwordDots
                contentLabel.textColor = Colors.label
            } else {
                contentLabel.text = ""
            }
        } else {
            contentLabel.text = Globals.oneTimePasswordDots
        }
        isReveal = false
        passwordDisplayButton?.configuration?.image = UIImage(systemName: "eye")
    }

    @objc
    func reversePasswordDisplay() {
        if isReveal {
            concealPassword()
        } else {
            revealPassword()
        }
    }

    func openLink() {
        // if isURLCell, passwordTableView should not be nil
        delegatePasswordTableView!.openLink(to: cellData?.content)
    }

    @objc
    func getNextHOTP() {
        // if isHOTPCell, passwordTableView should not be nil
        delegatePasswordTableView!.getNextHOTP()
    }

    private func updateButtons() {
        // total width and height of a button
        let height = min(bounds.height, 36.0)
        let width = max(height * 0.8, Globals.tableCellButtonSize)
        let visibilityImage = isReveal ? "eye.slash" : "eye"

        switch type {
        case .password:
            if let content = cellData?.content, !content.isEmpty {
                passwordDisplayButton = makeButton(systemImage: visibilityImage, frame: CGRect(x: 0, y: 0, width: width, height: height), action: #selector(reversePasswordDisplay))
                buttons = passwordDisplayButton
            }
        case .HOTP:
            let nextButton = makeButton(systemImage: "arrow.clockwise", frame: CGRect(x: 0, y: 0, width: width, height: height), action: #selector(getNextHOTP))
            passwordDisplayButton = makeButton(systemImage: visibilityImage, frame: CGRect(x: width, y: 0, width: width, height: height), action: #selector(reversePasswordDisplay))
            buttons = UIView()
            buttons!.frame = CGRect(x: 0, y: 0, width: width * 2, height: height)
            buttons!.addSubview(nextButton)
            buttons!.addSubview(passwordDisplayButton!)
        default:
            passwordDisplayButton = nil
            buttons = nil
        }
        accessoryView = buttons
    }

    private func makeButton(systemImage: String, frame: CGRect, action: Selector) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: systemImage)
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: Globals.tableCellButtonSize * 0.85)
        configuration.contentInsets = .zero
        let button = UIButton(configuration: configuration)
        button.frame = frame
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}

extension LabelTableViewCell: UIEditMenuInteractionDelegate {
    func editMenuInteraction(_: UIEditMenuInteraction, menuFor _: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
        UIMenu(children: suggestedActions + menuActions)
    }
}
