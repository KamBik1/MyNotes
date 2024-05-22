//
//  NoteViewController.swift
//  MyNotes
//
//  Created by Kamil Biktineyev on 14.05.2024.
//

import UIKit

class NoteViewController: UIViewController {

    @IBOutlet weak var noteTextView: UITextView!
    
    var noteTitle = ""
    var noteDescription = ""
    var noteIndexPath = 0
    
    weak var delagate: MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextView.text = noteDescription
        navigationItem.title = noteTitle
        addSwipeGesture()
        
        // Добавляем NoteViewController в центр сообщений как наблюдателя за сообщениями о появлении и исчезновении клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(moveTextViewUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveTextViewDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Определяем метод для поднятия контента в TextView при появлении клавиатуры
    @objc func moveTextViewUp(notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardHeight = keyboardFrame!.size.height
        
        noteTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
    }
    
    // Определяем метод для опускания контента в TextView при исчезновении клавиатуры
    @objc func moveTextViewDown(notification: NSNotification) {
        noteTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // Создаем экземпляр Swipe Gesture (убрать клавиатуру)
    func addSwipeGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.direction = .right
        noteTextView.addGestureRecognizer(swipeGesture)
    }
    
    // Определяем метод для обрабоки Swipe Gesture
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        noteTextView.resignFirstResponder()
    }
        
    // Передаем описние заметки в MainViewController (с использованием метода Delegate)
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        delagate?.updateDescription(description: noteTextView.text, index: noteIndexPath)
    }
}
