import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var selectedCategory: Category? {
        didSet {
            loadData()
        }
    }
    var todoItems: Results<Item>?
    let realm=try!  Realm()
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory!.name
        searchBar.backgroundColor = UIColor(hexString: selectedCategory!.colorCell)
        
        navigationController?.navigationBar.tintColor = ContrastColorOf(backgroundColor: UIColor(hexString: selectedCategory?.colorCell), returnFlat: true)
        navigationController?.navigationBar.barTintColor = UIColor(hexString: selectedCategory?.colorCell)
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(backgroundColor: UIColor(hexString: selectedCategory?.colorCell), returnFlat: true)]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let colour = UIColor(hexString: selectedCategory?.colorCell).darken(byPercentage:
                                                CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(backgroundColor: colour, returnFlat: true)
            }
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items added yet"
        }
         
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
//        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                    //realm.delete(item)
                }
            }catch {
                print(error)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new ToDoey item", message: "", preferredStyle: .alert)
        var textField :UITextField?
        let action = UIAlertAction(title: "Add Item", style: .default) {(action) in
            if let safeText = textField?.text {
                if let currentCategory = self.selectedCategory {
                    
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = safeText
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    } catch {
                        print(error)
                    }
                    self.tableView.reloadData()
                }
            }
        }
        alert.addTextField{(alertTextField) in
            alertTextField.placeholder = "Create new Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func loadData() {

        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        //let request : NSFetchRequest<Item> = Item.fetchRequest()
//        if !check {
//            let predicate = NSPredicate(format: "parentCategory.name MATCHES %@",selectedCategory!.name!)
//            request.predicate = predicate
//        }
//        do {
//            todoItems = try context.fetch(request)
//        } catch {
//            print("error fetching data context \(error)")
//        }
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

//MARK: search bar methods

extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text as Any).sorted(byKeyPath: "dateCreated",
        ascending: true)
        tableView.reloadData()
    }
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@",selectedCategory!.name!)
//        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicate, categoryPredicate])
//        request.predicate = andPredicate
//
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//        if searchBar.text == "" {
//            loadData()
//        } else {
//            loadData(your: request, own: true)
//        }
//    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
