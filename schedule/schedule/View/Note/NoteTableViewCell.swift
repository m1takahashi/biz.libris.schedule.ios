//
//  NoteTableViewCell.swift
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    var titleLabel:UILabel!
    var bodyLabel:UILabel!
    var submitDateLabel:UILabel!
    var updateDateLabel:UILabel!
    var shareButton:UIButton!
    
    let marginLeft:CGFloat  = 10
    let marginRight:CGFloat = 10
    let marginTop:CGFloat   = 2
    
    let titleHeight:CGFloat = 18
    let bodyHeight:CGFloat  = 54
    let submitDateHeight:CGFloat  = 16
    let updateDateHeight:CGFloat  = 16
    
    let shareWidth:CGFloat  = 65
    let shareHeight:CGFloat = 32

    var themeData:ThemeData!
    var pageData:PageStore!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        /**
         * iPhone6, 6plus対応
         * self.frame.size.widthで取得すると、全て"320"になる
         * let width:CGFloat = self.frame.size.width - (marginLeft + marginRight)
         */
        let width:CGFloat = UIScreen.mainScreen().bounds.size.width - (marginLeft + marginRight)

        var y:CGFloat = marginTop;
        titleLabel = UILabel(frame: CGRectMake(marginLeft, y, width, titleHeight));
        titleLabel.text = "";
        titleLabel.font = UIFont.boldSystemFontOfSize(16)
        titleLabel.textColor = UIColor.darkGrayColor()
        titleLabel.textAlignment = .Left
        self.addSubview(titleLabel)

        y = titleHeight
        bodyLabel = UILabel(frame: CGRectMake(marginLeft, y, width, bodyHeight));
        bodyLabel.text = "";
        bodyLabel.font = UIFont.systemFontOfSize(14)
        bodyLabel.textColor = UIColor.grayColor()
        bodyLabel.textAlignment = .Left
        bodyLabel.numberOfLines = 3
        self.addSubview(bodyLabel)
        
        // 作成日時（右寄せ）
        y = marginTop + titleHeight + bodyHeight
        submitDateLabel = UILabel(frame: CGRectMake(marginLeft, y, width - shareWidth, submitDateHeight));
        submitDateLabel.text = "";
        submitDateLabel.font = UIFont.boldSystemFontOfSize(12)
        submitDateLabel.textColor = UIColor.darkGrayColor()
        submitDateLabel.textAlignment = .Right
        self.addSubview(submitDateLabel)
        
        // 更新日時（右寄せ）
        y = marginTop + titleHeight + bodyHeight + submitDateHeight
        updateDateLabel = UILabel(frame: CGRectMake(marginLeft, y, width - shareWidth, updateDateHeight));
        updateDateLabel.text = "";
        updateDateLabel.font = UIFont.boldSystemFontOfSize(12)
        updateDateLabel.textColor = UIColor.darkGrayColor()
        updateDateLabel.textAlignment = .Right
        self.addSubview(updateDateLabel)
        
        // 共有ボタン（右寄せ）
        shareButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width - (shareWidth + marginRight), marginTop + titleHeight + bodyHeight, shareWidth, shareHeight))
        shareButton.setTitle(NSLocalizedString("note_share", comment: ""), forState: .Normal)
        shareButton.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        shareButton.addTarget(self,
            action: "onShareButton:",
            forControlEvents: .TouchUpInside)
        self.addSubview(shareButton)
    }
    
    internal func onShareButton(sender: UIButton){
        NSNotificationCenter.defaultCenter().postNotificationName(Const.getNotificationNameNoteShare(),
            object: nil,
            userInfo: ["page":pageData])
    }
    
    func setTheme(theme:ThemeData) {
        submitDateLabel.textColor = UIColor(hexString: theme.tabSegctr, alpha: 1.0)
        updateDateLabel.textColor = UIColor(hexString: theme.tabSegctr, alpha: 1.0)
        shareButton.setTitleColor(UIColor(hexString: theme.tabSegctr, alpha: 1.0), forState: .Normal)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
