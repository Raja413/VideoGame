//
//  VideoGameTableViewCell.swift
//  Videogame
//
//  Created by Raja reddy Poreddy on 10/10/18.
//  Copyright © 2018 Delvelogic. All rights reserved.
//

import UIKit

class VideoGameTableViewCell: UITableViewCell {
    
    // Constants
    static let ReuseIdentifier = String(describing: VideoGameTableViewCell.self)
    static let NibName = String(describing: VideoGameTableViewCell.self)
    
    // Outlets
    @IBOutlet weak var gameLabel: UILabel!
    @IBOutlet weak var gameImage: UIImageView!
    
    // Video game data
    var videoGameData: VideoGame? {
        didSet {
            do {
                if let url = URL(string: videoGameData?.iconImageURL ?? "") {
                    let imageData = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        self.gameImage.image = UIImage(data: imageData)
                        self.gameLabel.text = self.videoGameData?.name
                    }
                }
            }
            catch {
                print("Error loading")
            }
        }
    }
    
    // MARK: xib methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
