//
//  LibraryCollectionViewController.swift
//  Library@home
//
//  Created by ops on 2018-06-08.
//  Copyright © 2018 ops. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

private let reuseIdentifier = "Cell"

class LibraryCollectionViewController: UICollectionViewController {
    
    //    var books = ["lion", "space", "interconnection"]
    var books = [Book]()
    var isReading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
        setCells()
        
        //
        print("about to call method: readBooks()")
        readBooks()
        
        
        //        //
        //        let book1 = Book("Set For Life", "3", "")
        //        let book2 = Book("Befor She Was Harriet", "3", "")
        //        let book3 = Book("Diary of a Wimpy Kid", "3", "")
        //        let book4 = Book("Understanding American Power", "3", "")
        //
        //        storeBook(book: book1)
        //        storeBook(book: book2)
        //        storeBook(book: book3)
        //        storeBook(book: book4)
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? ShowBookViewController,
            let index = sender as? IndexPath {
            
            let selectedBook = books[index.row]
            destination.book = selectedBook
            print("index ==> \(index)")
            destination.passedInVar = "passed in value"
//            destination.selection = collectionData[index.row]
        }
    }
    
    
    
//    public func storeBook(book: Book) {
//
//        let bookInDictForm = [
//            "title": book.title,
//            "authorId": book.author,
//            "photoDownloadUrl": book.photoDownloadUrl
//        ]
//
//
//        // Reference the db's table.
//        let firDbBooksRef = Database.database().reference().child("Books")
//
//
//        // Firebase's way of saving a record.
//        firDbBooksRef.childByAutoId().setValue(bookInDictForm) {
//            (error, reference) in
//
//            if error != nil {
//                print(error!)
//            } else {
//                print("Book saved successfully")
//            }
//
//        }
//    }
    
    
    public func storeBooks() {
        
        for i in 0...2 {
            
            let title = "Hunger Games \(i+1)"
            let authorId = "author\(i+2)"
            let photoDownloadUrl = ""
            
            let newBook = [
                "title": title,
                "authorId": authorId,
                "photoDownloadUrl": photoDownloadUrl
            ]
            
            
            // Reference the db's table.
            let firDbBooksRef = Database.database().reference().child("Books")
            
            
            // Firebase's way of saving a record.
            firDbBooksRef.childByAutoId().setValue(newBook) {
                (error, reference) in
                
                if error != nil {
                    print(error!)
                } else {
                    print("Book saved successfully")
                }
                
            }
            
        }
    }
    
    
    public func writeBooks() {
        
        let firDbBooksRef = Database.database().reference().child("Books")
        
        let bookDictionary = [
            "title": "title1",
            "authorId": "author1",
            "photoDownloadUrl": "url1"
        ]
        
        
        
        let newBooks = [
            [
                "title": "title1",
                "authorId": "author1",
                "photoDownloadUrl": "url4"
            ],
            [
                "title": "title2",
                "authorId": "author2",
                "photoDownloadUrl": "url5"
            ],
            [
                "title": "title3",
                "authorId": "author3",
                "photoDownloadUrl": "url6"
            ]
        ]
        
        
        for i in 0...2 {
            
            // Firebase's way of saving a record.
            firDbBooksRef.childByAutoId().setValue(newBooks[i]) {
                (error, reference) in
                
                if error != nil {
                    print(error!)
                } else {
                    print("Book saved successfully")
                }
                
            }
        }
        
    }
    
    
    /**
     * From stackoverflow: https://stackoverflow.com/questions/29243060/trying-to-convert-firebase-timestamp-to-nsdate-in-swift
     */
    func cbConvertTimestamp(serverTimestamp: Double) -> String {
        let x = serverTimestamp / 1000
        let date = NSDate(timeIntervalSince1970: x)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        
        return formatter.string(from: date as Date)
    }
    
    
    public func readBooks() {
        
        //
        if isReading { return }
        isReading = true
        
        // 1) Create a reference to fir-db.
        let firDbBooksRef = Database.database().reference().child("Books")
        
        
        // Read by query.
        //        let qResult = firDbBooksRef.queryLimited(toFirst: 2)
//        let numOfReadBooks = books.count
//        var idOfLastSeenBook = "0"
//        var pseudoIdOfLastSeenBook = 0
        var timestampeOfLastSeenBook = 0.0
        var qResult = firDbBooksRef.queryOrdered(byChild: "createdAt").queryLimited(toFirst: 4)
        
        if books.count > 0 {
//            idOfLastSeenBook = books[books.count - 1].id!
            timestampeOfLastSeenBook = books[books.count - 1].createdAt!
//            pseudoIdOfLastSeenBook = books[books.count - 1].pseudoId!
            
//            print("idOfLastSeenBook ==> \(idOfLastSeenBook)")
            
            qResult = firDbBooksRef.queryOrdered(byChild: "createdAt").queryStarting(atValue: timestampeOfLastSeenBook, childKey: "createdAt").queryLimited(toFirst: 4)
        }
        
        print("timestampeOfLastSeenBook ==> \(timestampeOfLastSeenBook)")
        
        
        
        
        
        
        qResult.observeSingleEvent(of: DataEventType.value) {
            (snapshot) in
//            print("qResult's snapshot => \(snapshot)")
            let snapshotValue = snapshot.value as? [String: AnyObject]
            print("snapshotValue => \(snapshotValue)")
            
            if snapshotValue != nil {
                var temporaryBooks = [Book]()
                
                //            var isFirstRead = true
                
                for (key, jsonRecord) in snapshotValue! {
                    
                    
                    let title = jsonRecord["title"] as? String ?? ""
                    let author = jsonRecord["author"] as? String ?? ""
                    let photos = jsonRecord["photos"] as? [String]
                    let pseudoId = jsonRecord["pseudoId"] as? Int ?? 0
                    let price = jsonRecord["price"] as? Int ?? nil
                    let description = jsonRecord["description"] as? String ?? ""
                    let createdAtTimestamp = jsonRecord["createdAt"] as? Double
                    let updatedAtTimestamp = jsonRecord["updatedAt"] as? Double
                    
                    // If the current book has already been read, skip it.
                    if timestampeOfLastSeenBook == createdAtTimestamp {
                        //                    isFirstRead = false
                        print()
                        print("SKIPPED")
                        print()
                        continue
                        
                    }
                    
                    
                    let newBook = Book(key, title, author, photos!, price: price, description: description, createdAt: createdAtTimestamp, updatedAt: updatedAtTimestamp)
                    //
                    temporaryBooks.append(newBook)
                    //                self.books.append(newBook)
                    
                    print("id ==> \(key)")
                    print("pseudoId ==> \(pseudoId)")
                    print("title ==> \(title)")
                    print("author ==> \(author)")
                    print("photos ==> \(photos)")
                    print("last appended book id ==> \(title) ==> \(key)")
                    print("last book in the array ==> \(temporaryBooks[temporaryBooks.count - 1].id)")
                    print("createdAtTimestamp ==> \(createdAtTimestamp)")
                    print("updatedAtTimestamp ==> \(updatedAtTimestamp)")
                    print()
                }
                
                // 3) Update the collectionView.
                //            self.books = temporaryBooks
                //            temporaryBooks.reverse()
//                temporaryBooks = self.getOrderBooksByPseudoId(temporaryBooks)
                temporaryBooks = self.getOrderBooksByTimestamp(temporaryBooks)
                self.books += temporaryBooks
                self.collectionView?.reloadData()
                
                //
                self.isReading = false
                
            }
            

        }
    }
    
    func getOrderBooksByTimestamp(_ books: [Book]) -> [Book] {
        
        var tempBooks = [Book]()
        
        var timestampsOfBooks = [Double]()
        
        for book in books {
            timestampsOfBooks.append(book.createdAt!)
        }
        
        timestampsOfBooks.sort()
        
        for timestamp in timestampsOfBooks {
            
            for book in books {
                if timestamp == book.createdAt! {
                    tempBooks.append(book)
                    break
                }
            }
        }
        
        return tempBooks
        
        
    }
    
    
    func getOrderBooksByPseudoId(_ books: [Book]) -> [Book] {
        
        var tempBooks = [Book]()
        
        var pseudoIdsOfBooks = [Int]()
        
        for book in books {
            pseudoIdsOfBooks.append(book.pseudoId!)
        }
        
        pseudoIdsOfBooks.sort()
        
        for pseudoId in pseudoIdsOfBooks {
            
            for book in books {
                if pseudoId == book.pseudoId! {
                    tempBooks.append(book)
                    break
                }
            }
        }
        
        return tempBooks
        

    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height && !isReading {
            readBooks()
            print(" BOTTOM bith! you reached end of the table")
        }
    }
    
    private func setCells() {
        
        // Set up a 2-column Collection View
        let width = (view.frame.size.width - 1) / 2
        let height = width * 1.618
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: height)
        
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return books.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        
        let book = books[indexPath.row]
        
        let cellLabel = cell.viewWithTag(100) as! UILabel
        cellLabel.text = book.title
        
        let cellImageView = cell.viewWithTag(200) as! UIImageView
        setCellImageView(for: cellImageView, with: indexPath)
        
        return cell
    }
    
    
    
    
    
    private func setCellImageView(for imageView: UIImageView, with indexPath: IndexPath) {
        
        // 1) Create a StorageReference for "Photos".
//        let photoDownloadUrl = books[indexPath.row].photoDownloadUrl!
//        let photos = books[indexPath.row].photos
        let firstPhotoUrl = books[indexPath.row].photos[0]
        
//        if photoDownloadUrl == "" {
//            print("OOPS!! The photoDownloadUrl for book: \(books[indexPath.row].title) is empty")
//            return
//
//        }
        
        // 2) Reference the fir-storage url.
        let photoFirStorageRef = Storage.storage().reference(forURL: firstPhotoUrl)
        
        
        // 3) Download the photo-data (this is a method with call-back).
        photoFirStorageRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("********* ERROR DOWNLOADING PHOTO: \(error) *********")
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


extension LibraryCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowBookSegue", sender: indexPath)
        
        
    }
}
