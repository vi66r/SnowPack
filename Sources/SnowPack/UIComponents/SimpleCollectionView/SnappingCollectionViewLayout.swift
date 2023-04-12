import UIKit

// https://stackoverflow.com/a/43637969

open class SnappingCollectionViewLayout: UICollectionViewFlowLayout {

    open override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(
                forProposedContentOffset: proposedContentOffset,
                withScrollingVelocity: velocity
            )
        }

        var horizontalOffsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left
        
        var verticalOffsetAdjustment = CGFloat.greatestFiniteMagnitude
        let verticalOffset = proposedContentOffset.y + collectionView.contentInset.top

        let targetRect = CGRect(
            x: proposedContentOffset.x,
            y: proposedContentOffset.y,
            width: collectionView.bounds.size.width,
            height: collectionView.bounds.size.height
        )

        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)

        layoutAttributesArray?.forEach({ (layoutAttributes) in
            let horizontalItemOffset = layoutAttributes.frame.origin.x
            if fabsf(Float(horizontalItemOffset - horizontalOffset)) < fabsf(Float(horizontalOffsetAdjustment)) {
                horizontalOffsetAdjustment = horizontalItemOffset - horizontalOffset
            }
            
            let verticalItemOffset = layoutAttributes.frame.origin.y
            if fabsf(Float(verticalItemOffset - verticalOffset)) < fabsf(Float(verticalOffsetAdjustment)) {
                verticalOffsetAdjustment = verticalItemOffset - verticalOffset
            }
        })

        return CGPoint(x: proposedContentOffset.x + horizontalOffsetAdjustment,
                       y: proposedContentOffset.y + verticalOffsetAdjustment)
    }
}

public extension UICollectionViewLayout {
    static var snappingLayout: UICollectionViewLayout {
        SnappingCollectionViewLayout()
    }
}
