//
//  ViewController.swift
//  FXConverter
//
//  Created by D Yahns on 12/10/2018.
//

import UIKit

class ViewController: UITableViewController {

    let converter = Converter()
    var ratesProvider: ApiManager?
    var currencyCodes = [String]()
    
    private var formatter = NumberFormatter()
    
    // we need to cater for a scenario where currency is selected while the top row is off screen
    let topIndexPath = IndexPath(row: 0, section: 0)
    var inputActive = false
    var inputCell: CurrencyCell? {
        return inputActive ? tableView.cellForRow(at: topIndexPath) as? CurrencyCell : nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // designate self as conversion consumer
        converter.delegate = self
        
        // wire up FX provider and start updating rates
        ratesProvider = ApiManager(consumer: converter)
        
        // configure formater
        formatter.numberStyle = .decimal
        formatter.maximumSignificantDigits = 5
        formatter.usesGroupingSeparator = false
    }

    @objc func inputChanged(textField: UITextField) {
        guard let text = textField.text, let amount = formatter.number(from: "0\(text)")?.doubleValue else {
            return
        }
        
        converter.converting(amount: amount, from: currencyCodes.first ?? "")
        reloadNonInputCells()
    }

    private func reloadNonInputCells() {
        // exclude the input cell
        guard let cells = tableView.indexPathsForVisibleNonInputRows else {
            return
        }
        
        tableView.reloadRows(at: cells, with: .none)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyCodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CurrencyCell

        // Configure the cell...
        let currencyCode = currencyCodes[indexPath.row]
        cell.currencyLabel.text = currencyCode
        cell.amountTextField.text = formatter.string(for: converter.converted(to: currencyCode))
        
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if inputActive, indexPath == topIndexPath, let cell = cell as? CurrencyCell {
            cell.amountTextField.becomeInput(in: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.endEditing(true)
        
        currencyCodes.moveToTop(from: indexPath.row)
        inputActive = true
        
        tableView.moveRow(at: indexPath, to: topIndexPath)
        tableView.scrollToRow(at: topIndexPath, at: .top, animated: true)
        
        // if topIndexPath is visible, willDisplayCell won't fire
        // if it isn't, inputCell returns nil
        inputCell?.amountTextField.becomeInput(in: self)
    }
}

// MARK: - ConversionConsumer

extension ViewController: ConversionConsumer {
    func dataChanged(with codes: [String]) {
        updateCurrencyCodes(with: codes)
        
        reloadNonInputCells()
    }

    // TODO: This business with keeping the table view in sync with the data
    // is a bit insane and likely can be improved
    private func updateCurrencyCodes(with codes: [String]) {
        if currencyCodes.isEmpty {
            currencyCodes = codes
            
            // we need to update table view too
            let indexPaths = (0..<codes.count).map({ IndexPath(row: $0, section: 0) })
            tableView.insertRows(at: indexPaths, with: .fade)
        } else {
            // delete discarded codes
            let deletedCodes = Array(Set(currencyCodes).subtracting(codes))
            if !deletedCodes.isEmpty {
                // we need to update table view too
                let indexPaths = deletedCodes.compactMap { code -> IndexPath? in
                    guard let row = currencyCodes.index(where: { $0 == code }) else {
                        return nil
                    }
                    return IndexPath(row: row, section: 0)
                }
                
                currencyCodes.removeAll { deletedCodes.contains($0) }
                tableView.deleteRows(at: indexPaths, with: .fade)
            }
            
            // add new codes
            let newCodes = Set(codes).subtracting(currencyCodes).sorted()
            if !newCodes.isEmpty {
                let appendFrom = currencyCodes.count
                currencyCodes.append(contentsOf: newCodes)
                
                // we need to update table view too
                let indexPaths = (appendFrom..<appendFrom + newCodes.count).map({ IndexPath(row: $0, section: 0) })
                tableView.insertRows(at: indexPaths, with: .fade)
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        let newValue = (text as NSString).replacingCharacters(in: range, with: string)
        return newValue.isEmpty || formatter.number(from: newValue) != nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.delegate = nil
        textField.removeTarget(self, action: #selector(ViewController.inputChanged(textField:)), for: UIControl.Event.editingChanged)
    }
}

// MARK: - UITableView extension

extension UITableView {
    var indexPathsForVisibleNonInputRows: [IndexPath]? {
        return indexPathsForVisibleRows?.filter({
            !((cellForRow(at: $0) as? CurrencyCell)?.amountTextField.isFirstResponder ?? false)
        })
    }
}
