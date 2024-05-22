//
//  MainViewController.swift
//  MyNotes
//
//  Created by Kamil Biktineyev on 14.05.2024.
//

import UIKit

protocol MainViewControllerDelegate: AnyObject {
    func updateDescription(description: String?, index: Int)
}

class MainViewController: UIViewController {

    var notes: [Notes] = [Notes(name: "Chess", description: "The opening is the initial stage of a chess game. It usually consists of established theory. The other phases are the middlegame and the endgame. Many opening sequences, known as openings, have standard names such as Sicilian Defense. The Oxford Companion to Chess lists 1,327 named openings and variants, and there are many others with varying degrees of common usage."), Notes(name: "English", description: "Test"), Notes(name: "April Fool's day", description: "In the UK, jokes and tricks can be played up until noon on 1 April. After midday it's considered bad luck to play a trick. Anyone who forgets this and tries a joke in the afternoon becomes an April Fool themselves. So, what kind of jokes do people play? Well, a simple example would be telling your friend that their shoelaces are undone. Then, when they bend down to do them up, you shout, April Fool, and they realise their shoelaces are fine. Maybe it's not your kind of humour, but watch out, there's always someone who will find it hilarious! In Ireland, a popular prank is to send someone on a fool's errand. The victim is sent to deliver a letter, supposedly asking for help. When the person receives the letter, they open it, read it and tell the poor messenger that they will have to take the letter to another person. This continues and the victim ends up taking the message to several different people until someone feels sorry for them and shows them what the letter says: Send the fool to someone else. In France, Belgium, the Netherlands, Italy and French-speaking areas of Canada and Switzerland, the 1 April tradition is known as the April Fish. A common joke is to try to stick a paper fish onto a victim's back without being noticed. Some newspapers, TV channels and well-known companies publish false news stories to fool people on 1 April. One of the earliest examples of this was in 1957 when a programme on the BBC, the UK's national TV channel, broadcast a report on how spaghetti grew on trees. The film showed a family in Switzerland collecting spaghetti from trees and many people were fooled into believing it, as in the 1950s British people didn't eat much pasta and many didn't know how it was made! Most British people wouldn't fall for the spaghetti trick today, but in 2008 the BBC managed to fool their audience again with their Miracles of Evolution trailer, which appeared to show some special penguins that had regained the ability to fly. Two major UK newspapers, The Daily Telegraph and the Daily Mirror, published the 'important story' on their front pages.")]
    
    // Переменные для поиска по заметкам
    var filteredNotes: [Notes] = []
    var isSearching = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        addLongPressGesture()
    }
    
    // Создаем экземпляр Long Press Gesture (переименовать заметку)
    func addLongPressGesture() {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            tableView.addGestureRecognizer(longPressGesture)
        }
    
    // Определяем метод для обрабоки Long Press Gesture
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if isSearching == false {
            if gesture.state == .began {
                let location = gesture.location(in: tableView) // Возвращает точку, в которой произошло касание в координатах таблицы
                let indexPath = tableView.indexPathForRow(at: location) // Позволяет получить IndexPath для ячейки, соответствующей этой точке
                if let indexPath = indexPath {
                    renameTableViewCell(index: indexPath.row)
                }
            }
        }
    }
    
    //Определяем возможность переименования ячейки таблицы
    func renameTableViewCell (index: Int) {
        let alert = UIAlertController(title: "Choose your new name for the note \(notes[index].name)?", message: "", preferredStyle: .alert)
        alert.addTextField()
        let saveButton = UIAlertAction(title: "Rename", style: .default) { _ in
            if let textName = alert.textFields?.first?.text {
                self.notes[index].name = textName
                self.tableView.reloadData()
            }
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveButton)
        alert.addAction(cancelButton)
        present(alert, animated: true)
    }
    
    // Передаем название заметки, ее описние и indexPath в NoteViewController (с использованием метода Segue)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "goToNoteViewController" else { return }
        guard let destination = segue.destination as? NoteViewController else { return }
        let indexPath = self.tableView.indexPathForSelectedRow!
        
        if isSearching == false {
            destination.noteTitle = notes[indexPath.row].name
            destination.noteDescription = notes[indexPath.row].description
            destination.noteIndexPath = indexPath.row
        } else {
            for index in 0..<notes.count {
                if filteredNotes[indexPath.row].id == notes[index].id {
                    destination.noteTitle = notes[index].name
                    destination.noteDescription = notes[index].description
                    destination.noteIndexPath = index
                }
            }
        }
        destination.delagate = self
    }
    
    // Определяем возможность добавления новой ячейки в таблицу
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Create a note", message: "", preferredStyle: .alert)
        alert.addTextField()
        let saveButton = UIAlertAction(title: "Save", style: .default) { _ in
            if let textName = alert.textFields?.first?.text {
                self.notes.append(Notes(name: textName, description: ""))
                self.tableView.reloadData()
            }
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveButton)
        alert.addAction(cancelButton)
        present(alert, animated: true)
    }
    
}

extension MainViewController: UITableViewDataSource {
    // Определяем количество строк в таблице
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching == false {
            return notes.count
        } else {
            return filteredNotes.count
        }
    }
 
    // Определяем как будет выглядеть ячейка таблицы
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        var listConfig = cell.defaultContentConfiguration()
        
        if isSearching == false {
            listConfig.text = notes[indexPath.row].name
            listConfig.secondaryText = notes[indexPath.row].description
        } else {
            listConfig.text = filteredNotes[indexPath.row].name
            listConfig.secondaryText = filteredNotes[indexPath.row].description
        }
        
        listConfig.textProperties.font = UIFont.boldSystemFont(ofSize: 18)
        listConfig.textProperties.numberOfLines = 1
        listConfig.secondaryTextProperties.numberOfLines = 1
        cell.contentConfiguration = listConfig
        
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    // Определяем возможность удаления ячейки из таблицы
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Определяем метод для исчесзновения клавиатуры во время скролинга
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        }
}

extension MainViewController: MainViewControllerDelegate {
    // Определяем метод для делегата
    func updateDescription(description: String?, index: Int) {
        isSearching = false
        searchBar.text = ""
        
        if let description = description {
            notes[index].description = description
        }
        else {
            notes[index].description = ""
        }
        
        self.tableView.reloadData()
       
    }
}

extension MainViewController: UISearchBarDelegate {
    // Определяем метод для поиска заметок в Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredNotes.removeAll()
        guard searchText != "" || searchText != " " else { return }
        
        for note in notes {
            let searchNote = searchText.lowercased()
            let isNoteContains = note.name.lowercased().contains(searchNote)
            if isNoteContains == true {
                filteredNotes.append(note)
            }
        }
        
        if searchBar.text == "" {
            isSearching = false
            tableView.reloadData()
        } else {
            isSearching = true
            tableView.reloadData()
        }
    }
}
