//
//  AddNoteViewController.swift
//  MySafe
//
//  Created by Amritpal Singh on 5/5/17.
//  Copyright © 2017 sidhu. All rights reserved.
//

import UIKit

class AddNoteViewController: UIViewController {

    @IBOutlet weak var notesTextView: UITextView!

    @IBOutlet weak var textViewBottomConstaint: NSLayoutConstraint!
    @IBOutlet weak var copyBtnBottomConstraint: NSLayoutConstraint!

    var edited = false
    var isEditingMode = true
    var tapGesture: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.notesTextView.addGestureRecognizer(tapGesture)

        // Listen for keyboard appearances and disappearances
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolBar.items = [doneButton]

        notesTextView.inputAccessoryView = toolBar

    }

    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {

        if isEditingMode == false {
            copyBtnBottomConstraint.constant = -30
            notesTextView.isEditable = true
            notesTextView.becomeFirstResponder()
        }else {
            copyBtnBottomConstraint.constant = 0
            notesTextView.text = """
            WHEN, IN 1993, Hamid Biglari left his job as a theoretical nuclear physicist at Princeton to join McKinsey consulting, what struck him was that “companies were displacing nations as the units of international competition.”
            This seemed to him a pivotal change. International corporations have a different lens. They optimize globally, rather than nationally. Their aim is to maximize profits across the world — allocating cash where it is most beneficial, finding labor where it is cheapest — not to pursue some national interest.
            The shift was fast-forwarded by advances in communications that rendered distance irrelevant, and by the willingness in most emerging markets to open borders to foreign investment and new technologies.
            Hundreds of millions of people in these developing countries were lifted from poverty into the middle class. Conversely, in Western societies, a hollowing out of the middle class began as manufacturing migrated, technological advances eliminated jobs and wages stagnated.

            Looking back, it’s now easy enough to see that the high point of democracy — the victory of open systems over the Soviet imperium that brought down the Berlin Wall in 1989 and set free more than 100 million Central Europeans — was quickly followed by the unleashing of economic forces that would undermine democracies. Far from ending history, liberalism triumphant engendered a reaction.

            The shift was fast-forwarded by advances in communications that rendered distance irrelevant, and by the willingness in most emerging markets to open borders to foreign investment and new technologies.
            Hundreds of millions of people in these developing countries were lifted from poverty into the middle class. Conversely, in Western societies, a hollowing out of the middle class began as manufacturing migrated, technological advances eliminated jobs and wages stagnated.

            Looking back, it’s now easy enough to see that the high point of democracy — the victory of open systems over the Soviet imperium that brought down the Berlin Wall in 1989 and set free more than 100 million Central Europeans — was quickly followed by the unleashing of economic forces that would undermine democracies. Far from ending history, liberalism triumphant engendered a reaction.
            """
        }
        print("ContentSize: \(notesTextView.contentSize)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func keyboardWillShow(_ sender: Notification) {
        let userInfo = sender.userInfo!
        let r = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.textViewBottomConstaint.constant = r.height-20
        self.notesTextView.removeGestureRecognizer(tapGesture)
    }

    @objc func keyboardWillHide(_ sender: Notification){
        self.notesTextView.addGestureRecognizer(tapGesture)
        self.textViewBottomConstaint.constant = 5
        print("hidden")
    }

    //MARK: - Custom Functions
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("tapped")
        notesTextView.isEditable = true
        notesTextView.textColor = UIColor.white

        //        didTapReadTerm(sender: sender)
        if let textView = sender.view as? UITextView {

            var pointOfTap = sender.location(in: textView)
            print("x:\(pointOfTap.x) , y:\(pointOfTap.y)")

            let contentOffsetY = textView.contentOffset.y

            _ = word(atPosition: pointOfTap)
            if let startPosition = notesTextView.characterRange( at: pointOfTap) {
                if let newPosition = notesTextView.position(from: startPosition.start, offset: 1) {
                    notesTextView.selectedTextRange = notesTextView.textRange(from: newPosition, to: newPosition)
                }
            }
        }
        //
        notesTextView.becomeFirstResponder()
    }

    func didTapReadTerm(sender: UITapGestureRecognizer) {

        // calculate layout manager touch location
        let textView = sender.view as! UITextView, // we sure this is an UITextView, so force casting it
        layoutManager = textView.layoutManager
        //layoutManager.

        var location = sender.location(in: self.view)
        location.y -= notesTextView.frame.origin.y
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top

        location.y += textView.contentOffset.y

        // find the value
        let textContainer = textView.textContainer,
        characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil),
        textStorage = textView.textStorage

        guard characterIndex < textStorage.length else {
            notesTextView.becomeFirstResponder()
            return
        }

        let range = NSRange(location: characterIndex, length: 0)
        notesTextView.selectedRange = range

        notesTextView.becomeFirstResponder()

    }

    func word(atPosition: CGPoint) -> String? {
        //eliminate scroll offset
        if let tapPosition = notesTextView.closestPosition(to: atPosition) {
            //fetch the word at this position (or nil, if not available)
            if let textRange = notesTextView.tokenizer.rangeEnclosingPosition(tapPosition , with: .word, inDirection: 1) {
                if let tappedWord = notesTextView.text(in: textRange) {
                    print("Word: \(tappedWord)")
                    return tappedWord
                }

                return nil
            }
            return nil
        }
        return nil
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("Textview content offset: \(notesTextView.contentOffset)")
        print("scroll content offset: \(scrollView.contentOffset)")
    }


    //MARK: IBActions

    @IBAction func copyAllBtnTapped(_ sender: Any) {
        UIPasteboard.general.string = notesTextView?.text
    }
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}

extension AddNoteViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        edited = true
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        notesTextView.textColor = UIColor.white
        textView.isEditable = false
    }
}
