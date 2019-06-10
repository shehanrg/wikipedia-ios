
import UIKit

protocol TalkPageHeaderViewDelegate: class {
    func tappedLink(_ url: URL, cell: TalkPageHeaderView)
}

class TalkPageHeaderView: UIView {
    
    weak var delegate: TalkPageHeaderViewDelegate?
    
    struct ViewModel {
        let header: String
        let title: String
        let info: String?
        let intro: String?
    }
    
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private(set) var titleTextView: UITextView!
    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var introTextView: UITextView!
    
    private var viewModel: ViewModel?
    
    private var theme: Theme?
    
    private var hasInfoText: Bool {
        return viewModel?.info != nil
    }
    
    private var hasIntroText: Bool {
        return viewModel?.intro != nil
    }
    
    var semanticContentAttributeOverride: UISemanticContentAttribute = .unspecified {
        didSet {
            textAlignmentOverride = semanticContentAttributeOverride == .forceRightToLeft ? NSTextAlignment.right : NSTextAlignment.left
            
            headerLabel.semanticContentAttribute = semanticContentAttributeOverride
            titleTextView.semanticContentAttribute = semanticContentAttributeOverride
            infoLabel.semanticContentAttribute = semanticContentAttributeOverride
            introTextView.semanticContentAttribute = semanticContentAttributeOverride
        }
    }
    
    private var textAlignmentOverride: NSTextAlignment = .left {
        didSet {
            headerLabel.textAlignment = textAlignmentOverride
            titleTextView.textAlignment = textAlignmentOverride
            infoLabel.textAlignment = textAlignmentOverride
            introTextView.textAlignment = textAlignmentOverride
        }
    }
    
    override init(frame: CGRect) {
        assertionFailure("init(frame) not setup for TalkPageHeaderView")
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        infoLabel.numberOfLines = 0
        titleTextView.isEditable = false
        titleTextView.isScrollEnabled = false
        titleTextView.delegate = self
        titleTextView.textContainerInset = UIEdgeInsets.zero
        titleTextView.textContainer.lineFragmentPadding = 0
        introTextView.isEditable = false
        introTextView.isScrollEnabled = false
        introTextView.delegate = self
        introTextView.textContainer.maximumNumberOfLines = 3
        introTextView.textContainer.lineBreakMode = .byTruncatingTail
        introTextView.textContainerInset = UIEdgeInsets.zero
        introTextView.textContainer.lineFragmentPadding = 0
    }
    
    func configure(viewModel: ViewModel) {
        
        self.viewModel = viewModel
        
        if hasInfoText {
            infoLabel.text = viewModel.info
            introTextView.isHidden = false
        } else {
            infoLabel.isHidden = true
        }
        
        headerLabel.text = viewModel.header
        
        let titleFont = UIFont.wmf_font(.boldTitle1, compatibleWithTraitCollection: traitCollection)
        let titleAttributedString = viewModel.title.wmf_attributedStringFromHTML(with: titleFont, boldFont: titleFont, italicFont: titleFont, boldItalicFont: titleFont, color: titleTextView.textColor, linkColor:theme?.colors.link, handlingLists: false, handlingSuperSubscripts: true, withAdditionalBoldingForMatchingSubstring:nil, tagMapping: nil, additionalTagAttributes: nil)
        titleTextView.attributedText = titleAttributedString
        
        if let intro = viewModel.intro {
            introTextView.isHidden = false
            setupIntro(text: intro)
        } else {
            introTextView.isHidden = true
        }
    }
    
    private func setupIntro(text: String) {
        if hasIntroText {
            
            let introFont = UIFont.wmf_font(.footnote, compatibleWithTraitCollection: traitCollection)
            let boldIntroFont = UIFont.wmf_font(.semiboldFootnote, compatibleWithTraitCollection: traitCollection)
            let italicIntroFont = UIFont.wmf_font(.italicFootnote, compatibleWithTraitCollection: traitCollection)
            
            introTextView.attributedText = text.wmf_attributedStringFromHTML(with: introFont, boldFont: boldIntroFont, italicFont: italicIntroFont, boldItalicFont: boldIntroFont, color: introTextView.textColor, linkColor:theme?.colors.link, handlingLists: true, handlingSuperSubscripts: true, withAdditionalBoldingForMatchingSubstring:nil, tagMapping: nil, additionalTagAttributes: nil)
        } else {
            introTextView.isHidden = true
        }
    }
    
    // MARK - Dynamic Type
    // Only applies new fonts if the content size category changes
    
    open override func setNeedsLayout() {
        maybeUpdateFonts(with: traitCollection)
        super.setNeedsLayout()
    }
    
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setNeedsLayout()
    }
    
    var contentSizeCategory: UIContentSizeCategory?
    fileprivate func maybeUpdateFonts(with traitCollection: UITraitCollection) {
        guard contentSizeCategory == nil || contentSizeCategory != traitCollection.wmf_preferredContentSizeCategory else {
            return
        }
        contentSizeCategory = traitCollection.wmf_preferredContentSizeCategory
        updateFonts(with: traitCollection)
    }
    
    func updateFonts(with traitCollection: UITraitCollection) {
        headerLabel.font = UIFont.wmf_font(DynamicTextStyle.semiboldFootnote, compatibleWithTraitCollection: traitCollection)
        titleTextView.font = UIFont.wmf_font(DynamicTextStyle.boldTitle1, compatibleWithTraitCollection: traitCollection)
        infoLabel.font = UIFont.wmf_font(DynamicTextStyle.footnote, compatibleWithTraitCollection: traitCollection)
        if let intro = viewModel?.intro {
            setupIntro(text: intro)
        }
    }
}

extension TalkPageHeaderView: Themeable {
    func apply(theme: Theme) {
        self.theme = theme
        titleTextView.backgroundColor = theme.colors.paperBackground
        headerLabel.textColor = theme.colors.secondaryText
        titleTextView.textColor = theme.colors.primaryText
        infoLabel.textColor = theme.colors.secondaryText
        introTextView.textColor = theme.colors.primaryText
        introTextView.backgroundColor = theme.colors.paperBackground
        backgroundColor = theme.colors.paperBackground
    }
}

//MARK: UITextViewDelegate

extension TalkPageHeaderView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        delegate?.tappedLink(URL, cell: self)
        return false
    }
}
