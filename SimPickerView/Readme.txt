SimPickerView 是用 UICollectionView 加上 custom UICollectionViewFlowLayout
用來模擬原本的 UIPickerView 的功能，為什麼要這樣呢？因為我們需要加上 '>'(disclosure button)
與 '⊖'(delete) 的按鈕，還有在 iPad 上面做無鋸齒放大，這些都是 UIPickerView 沒有的功能。

使用 SimPickerView 的時候，需要 delegate (View Controller) 提供一些配合的動作：

@protocol SimPickerDelegateProtocol <NSObject>
- (NSInteger)numberOfRowsInPickerView:(SimPickerView *)pickerView;
- (NSString *)pickerView:(SimPickerView *)pickerView titleForRow:(NSInteger)row;
- (void)pickerView:(SimPickerView *)pickerView didSelectRow:(NSInteger)row;
- (void)callbackInsertItem:(id)item atRow:(NSInteger)row;
- (void)callbackDeleteRow:(NSInteger)deleteRow;
@end

前三個是類似 UIPickerView 原本的動作，無需再解釋。後面兩個是額外新增的，這裡解釋一下：
因為 delete 可能是從 picker view 本身發出的（由 gesture 動作出來的），
然而 add 可能是從外界（例如 view controller）這邊下過去的，所以介面部分統一設計為

- (void)deleteRow:(NSInteger)deleteRow;
- (void)insertItem:(id)newItem atRow:(NSInteger)row;

提供外界呼叫，然後會引發相關的 delegate 動作：

- (void)callbackInsertItem:(id)item atRow:(NSInteger)row;
- (void)callbackDeleteRow:(NSInteger)deleteRow;

這裡 delegate 就要做實際的資料刪除動作來配合。


========================================
SimPickerView 的介面
========================================
@interface SimPickerView : UIView<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIImageView *focusImageView;
// properties to define the look of pickerview
@property CGFloat CellHeight;
@property NSInteger DisplayedItems;
@property (strong, nonatomic) id<SimPickerDelegateProtocol> delegate;
@property CGFloat MinLineSpacing;
@property (strong, nonatomic) UIButton *buttonDisclosure;

- (void)markFirstDisclosure;
- (NSIndexPath *)getFocusIndexPath;
// insert / add / delete
- (void)deleteRow:(NSInteger)deleteRow;
- (void)insertItem:(id)newItem atRow:(NSInteger)row;
- (void)insertItem:(id)newItem afterRow:(NSInteger)row;
- (void)reloadData;

解釋一下個介面的用途：

初始時要知道 顯示的 cell 有幾個，還有 cell 的間隔，以及 cell 高度，分別會設定在
_DisplayedItems, _MinLineSpacing, _CellHeight 三個參數裡面，在 commonInit() 開始時就
設定其值：

_DisplayedItems = 5;
_MinLineSpacing = 1;
_CellHeight = (frame.size.height - (_MinLineSpacing * (_DisplayedItems -1))) / _DisplayedItems;

focusImageView 就是當作焦點的玻璃

- (void)deleteRow:(NSInteger)deleteRow;
- (void)insertItem:(id)newItem atRow:(NSInteger)row;

提供外界或內部呼叫，用來 add/delete 的動作。

- (void)insertItem:(id)newItem afterRow:(NSInteger)row;

是額外輔助的動作，因為 insertItem:atRow: 是從 row 的位置插入新項目，
我們有時會需要從 row 的下一個位置插入新項目，就使用 insertItem:afterRow:


