//
//  ShowBookViewController.swift
//  Library@home
//
//  Created by ops on 2018-08-17.
//  Copyright © 2018 ops. All rights reserved.
//

import UIKit
import Firebase

class ShowBookViewController: UIViewController {
    
    var passedInVar: String!
    var book: Book!
    var randomData = [1, 2, 3, 4, 5]

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("############################")
        print("Class ==> ShowBookViewController")
        print("----------------------------")
        print("passedInVar ==> \(passedInVar)")
        print("book.id => \(book.id)")
        print("book.title => \(book.title)")
        print("book.author => \(book.author)")
        
        
        setCollectionViewCell()
        
        
        collectionView.delegate = self
        collectionView.dataSource = self

        
        //
        titleLabel.text = book.title!
        priceLabel.text = "$" + String(book.price!)
        authorLabel.text = "by " + book.author
        descriptionTextView.text = book.description
        
        //
        pageControl.numberOfPages = book.photos.count
        
        collectionView.reloadData()
        
        
    }
    
    
    private func setCollectionViewCell() {
        let width = view.frame.size.width
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: 360)
        
//        let viewWidth = width
//        let cvWidth = collectionView.frame.width
//
//        print("viewWidth \(viewWidth)")
//        print("cvWidth \(cvWidth)")
    }
    
    
    private func setCbImageView(photoUrl: String, imageView: UIImageView) {
                

        // 2) Reference the fir-storage url.
        let photoFirStorageRef = Storage.storage().reference(forURL: photoUrl)
        
        
        // 3) Download the photo-data (this is a method with call-back).
        photoFirStorageRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("********* ERROR SHOWING PHOTO bruh: \(error) *********")
            }
            else {
                if let photoData = data {
                    DispatchQueue.main.async {
                        imageView.image = UIImage(data: photoData)
                    }
                    
                }
            }
        }
    }

}


extension ShowBookViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return book.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! UICollectionViewCell

        if let imageView = cell.viewWithTag(200) as? UIImageView {
            setCbImageView(photoUrl: book.photos[indexPath.row], imageView: imageView)
        }
        
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Set the pageControl icon.
        let width = scrollView.bounds.width
        let pageFraction = scrollView.contentOffset.x / width
        pageControl.currentPage = Int(round(pageFraction))
    }
}

