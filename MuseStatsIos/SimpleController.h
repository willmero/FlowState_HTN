#import <UIKit/UIKit.h>
#import <Muse/Muse.h>
#import <AVFoundation/AVFoundation.h>

@interface SimpleController : UIViewController
< IXNMuseConnectionListener, IXNMuseDataListener, IXNMuseListener, IXNLogListener,
  UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UITextView* logView;
- (IBAction)disconnect:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *bineuralFlipperLabel;
- (IBAction)bineuralToggle:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *bineuralFlipper;
@property (weak, nonatomic) IBOutlet UILabel *selectYourDeviceLabel;
- (IBAction)scan:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *endFlowState;
@property (weak, nonatomic) IBOutlet UIImageView *flowStateWarning;
@property (weak, nonatomic) IBOutlet UIButton *beginButton;
@property (weak, nonatomic) IBOutlet UILabel *pleaseContactLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headPoint1;
@property (weak, nonatomic) IBOutlet UIImageView *headPoint2;
@property (weak, nonatomic) IBOutlet UIImageView *headPoint3;
@property (weak, nonatomic) IBOutlet UIImageView *headPoint4;
- (IBAction)stopScan:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *image;
- (void)applicationWillResignActive;
@end
