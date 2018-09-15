//
//  SimpleController.m
//  MuseStatsIos
//
//  Created by Yue Huang on 2015-09-01.
//  Copyright (c) 2015 InteraXon. All rights reserved.
//

#import "SimpleController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface SimpleController () <CBCentralManagerDelegate>
@property IXNMuseManagerIos * manager;
@property (weak, nonatomic) IXNMuse * muse;
@property (nonatomic) NSMutableArray* logLines;
@property (nonatomic) BOOL lastBlink;
@property (nonatomic) BOOL lastJawClench;
@property (nonatomic, strong) CBCentralManager * btManager;
@property (atomic) BOOL btState;
@end

NSMutableData *_responseData;

@implementation SimpleController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    if (!self.manager) {
        self.manager = [IXNMuseManagerIos sharedManager];
    }
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil
                          bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.manager = [IXNMuseManagerIos sharedManager];
        [self.manager setMuseListener:self];
        self.tableView = [[UITableView alloc] init];

        self.logView = [[UITextView alloc] init];
        self.logLines = [NSMutableArray array];
        [self.logView setText:@""];
        
        [[IXNLogManager instance] setLogListener:self];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSString * dateStr = [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:@".log"];
        NSLog(@"%@", dateStr);
        
        self.btManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        self.btState = FALSE;
    }
    return self;
}

- (void)log:(NSString *)fmt, ... {
    va_list args;
    va_start(args, fmt);
    NSString *line = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);
    NSLog(@"%@", line);
    [self.logLines insertObject:line atIndex:0];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.logView setText:[self.logLines componentsJoinedByString:@"\n"]];
    });
}

- (void)receiveLog:(nonnull IXNLogPacket *)l {
  [self log:@"%@: %llu raw:%d %@", l.tag, l.timestamp, l.raw, l.message];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    self.btState = (self.btManager.state == CBCentralManagerStatePoweredOn);
}

- (bool)isBluetoothEnabled {
    return self.btState;
}

- (void)museListChanged {
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [[self.manager getMuses] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"nil";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:simpleTableIdentifier];
    }
    NSArray * muses = [self.manager getMuses];
    if (indexPath.row < [muses count]) {
        IXNMuse * muse = [[self.manager getMuses] objectAtIndex:indexPath.row];
        cell.textLabel.text = [muse getName];
        if (![muse isLowEnergy]) {
            cell.textLabel.text = [cell.textLabel.text stringByAppendingString:
                                   [muse getMacAddress]];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray * muses = [self.manager getMuses];
    if (indexPath.row < [muses count]) {
        IXNMuse * muse = [muses objectAtIndex:indexPath.row];
        @synchronized (self.muse) {
            if(self.muse == nil) {
                self.muse = muse;
            }else if(self.muse != muse) {
                [self.muse disconnect];
                self.muse = muse;
            }
        }
        [self connect];
        [self log:@"======Choose to connect muse %@ %@======\n",
              [self.muse getName], [self.muse getMacAddress]];
    }
}

- (void)receiveMuseConnectionPacket:(IXNMuseConnectionPacket *)packet
                               muse:(IXNMuse *)muse {
    NSString *state;
    switch (packet.currentConnectionState) {
        case IXNConnectionStateDisconnected:
            state = @"disconnected";
            break;
        case IXNConnectionStateConnected:
            state = @"connected";
            break;
        case IXNConnectionStateConnecting:
            state = @"connecting";
            break;
        case IXNConnectionStateNeedsUpdate: state = @"needs update"; break;
        case IXNConnectionStateUnknown: state = @"unknown"; break;
        default: NSAssert(NO, @"impossible connection state received");
    }
    [self log:@"connect: %@", state];
}

- (void) connect {
    [self.muse registerConnectionListener:self];
    [self.muse registerDataListener:self
                               type:IXNMuseDataPacketTypeBetaRelative];
    /*
    [self.muse registerDataListener:self
                               type:IXNMuseDataPacketTypeEeg];
     */
    [self.muse runAsynchronously];
}

- (void)receiveMuseDataPacket:(IXNMuseDataPacket *)packet
                         muse:(IXNMuse *)muse {
    if (packet.packetType == IXNMuseDataPacketTypeBetaRelative) {
        double IXNEegEEG1Value = [packet.values[IXNEegEEG1] doubleValue];
        double IXNEegEEG2Value = [packet.values[IXNEegEEG2] doubleValue];
        double IXNEegEEG3Value = [packet.values[IXNEegEEG3] doubleValue];
        double IXNEegEEG4Value = [packet.values[IXNEegEEG4] doubleValue];
        
        double total = IXNEegEEG1Value + IXNEegEEG2Value + IXNEegEEG3Value + IXNEegEEG4Value;

        [self log:@"%5.2f", total];
    }
}

- (void)applicationWillResignActive {
    NSLog(@"disconnecting before going into background");
    [self.muse disconnect];
}

- (IBAction)disconnect:(id)sender {
    if (self.muse) [self.muse disconnect];
}

- (IBAction)scan:(id)sender {
    [self.manager startListening];
    [self.tableView reloadData];
}

- (IBAction)stopScan:(id)sender {
    [self.manager stopListening];
    [self.tableView reloadData];
}

- (IBAction)startDND:(id)sender {
    [self log:@"Starting DND"];
    

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://slack.com/api/dnd.setSnooze?token=xoxp-436066852708-437314676935-436436969205-49c9eea973f6a1ec1d64b2d26859042b&num_minutes=5"]];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    
    // This is how we set header fields
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    
    [postDict setValue:@"xoxp-436066852708-437314676935-436436969205-49c9eea973f6a1ec1d64b2d26859042b" forKey:@"token"];
    [postDict setValue:@"5" forKey:@"num_minutes"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postDict options:0 error:nil];
    
    // Checking the format
    NSString *urlString =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    // Convert your data and set your request's HTTPBody property
    NSString *stringData = [[NSString alloc] initWithFormat:@"jsonRequest=%@", urlString];
    
    //@"jsonRequest={\"methodName\":\"Login\",\"username\":\"admin\",\"password\":\"12345678n\",\"clientType\":\"web\"}";
    
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    
    request.HTTPBody = requestBodyData;
    
    // Create url connection and fire request
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!theConnection) {
        
        // Release the receivedData object.
        NSMutableData *responseData = nil;
        
        // Inform the user that the connection failed.
    }

}

- (IBAction)endDND:(id)sender {
    [self log:@"Ending DND"];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://slack.com/api/dnd.endSnooze?token=xoxp-436066852708-437314676935-436436969205-49c9eea973f6a1ec1d64b2d26859042b"]];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"POST";
    
    // This is how we set header fields
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    
    [postDict setValue:@"xoxp-436066852708-437314676935-436436969205-49c9eea973f6a1ec1d64b2d26859042b" forKey:@"token"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postDict options:0 error:nil];
    
    // Checking the format
    NSString *urlString =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    // Convert your data and set your request's HTTPBody property
    NSString *stringData = [[NSString alloc] initWithFormat:@"jsonRequest=%@", urlString];
    
    //@"jsonRequest={\"methodName\":\"Login\",\"username\":\"admin\",\"password\":\"12345678n\",\"clientType\":\"web\"}";
    
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    
    request.HTTPBody = requestBodyData;
    
    // Create url connection and fire request
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!theConnection) {
        
        // Release the receivedData object.
        NSMutableData *responseData = nil;
        
        // Inform the user that the connection failed.
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
    
    NSError *error=nil;
    
    // Convert JSON Object into Dictionary
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:_responseData options:
                          NSJSONReadingMutableContainers error:&error];
    
    
    
    NSLog(@"Response %@",JSON);
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}
@end
