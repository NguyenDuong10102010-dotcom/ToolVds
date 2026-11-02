#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>

@interface PanelView : UIView
@property (nonatomic, readonly) BOOL autoImageOn;
@property (nonatomic, readonly) BOOL autoBeatOn;
@end

@interface PanelView ()
@property (nonatomic, strong) UIView   *box;
@property (nonatomic, strong) UIButton *header;
@property (nonatomic, strong) UIView   *line;
@property (nonatomic, strong) UILabel  *lImg, *lBeat;
@property (nonatomic, strong) UISwitch *sImg, *sBeat;
@property (nonatomic, assign) BOOL collapsed;
@end

@implementation PanelView

- (instancetype)init {
    CGFloat x = [[NSUserDefaults standardUserDefaults] floatForKey:@"dp_x"];
    CGFloat y = [[NSUserDefaults standardUserDefaults] floatForKey:@"dp_y"];
    if (x <= 0 || y <= 0) { x = 16; y = 120; }

    self = [super initWithFrame:CGRectMake(x, y, 270, 158)];
    if (!self) return nil;
    self.backgroundColor = [UIColor clearColor];

    self.box = [[UIView alloc] initWithFrame:self.bounds];
    self.box.backgroundColor = [UIColor colorWithWhite:0.02 alpha:0.94];
    self.box.layer.cornerRadius  = 18;
    self.box.layer.borderWidth   = 1.4;
    self.box.layer.borderColor   = [UIColor colorWithWhite:1.0 alpha:0.9].CGColor;
    self.box.layer.shadowColor   = [UIColor whiteColor].CGColor;
    self.box.layer.shadowRadius  = 16;
    self.box.layer.shadowOpacity = 0.85;
    self.box.layer.shadowOffset  = CGSizeZero;
    [self addSubview:self.box];

    self.header = [UIButton buttonWithType:UIButtonTypeCustom];
    self.header.frame = CGRectMake(0, 0, 270, 48);
    self.header.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    self.header.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.header.titleLabel.minimumScaleFactor = 0.6;
    [self.header setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.header setTitle:@"◆ PAINUZZ" forState:UIControlStateNormal];
    [self.header addTarget:self action:@selector(toggleCollapse) forControlEvents:UIControlEventTouchUpInside];
    [self.box addSubview:self.header];

    self.line = [[UIView alloc] initWithFrame:CGRectMake(14, 48, 242, 1)];
    self.line.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.35];
    self.line.layer.shadowColor   = [UIColor whiteColor].CGColor;
    self.line.layer.shadowOpacity = 1.0;
    self.line.layer.shadowRadius  = 6;
    [self.box addSubview:self.line];

    self.lImg = [self lbl:@"Auto Nhập Ảnh" y:64];
    [self.box addSubview:self.lImg];
    self.sImg = [self sw:64 tag:1];
    [self.box addSubview:self.sImg];

    self.lBeat = [self lbl:@"Auto Cắt Nhạc" y:110];
    [self.box addSubview:self.lBeat];
    self.sBeat = [self sw:110 tag:2];
    [self.box addSubview:self.sBeat];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.header addGestureRecognizer:pan];

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    self.sImg.on  = [d boolForKey:@"dp_img"];
    self.sBeat.on = [d boolForKey:@"dp_beat"];
    if ([d boolForKey:@"dp_collapsed"]) { self.collapsed = YES; [self collapse:NO]; }
    return self;
}

- (UILabel *)lbl:(NSString *)t y:(CGFloat)y {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 170, 28)];
    l.text = t;
    l.textColor = [UIColor whiteColor];
    l.font = [UIFont systemFontOfSize:13.5 weight:UIFontWeightSemibold];
    l.layer.shadowColor = [UIColor whiteColor].CGColor;
    l.layer.shadowOpacity = 0.35;
    l.layer.shadowRadius = 4;
    return l;
}

- (UISwitch *)sw:(CGFloat)y tag:(NSInteger)t {
    UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(200, y, 51, 31)];
    s.onTintColor = [UIColor whiteColor];
    s.tintColor = [UIColor colorWithWhite:0.22 alpha:1];
    s.thumbTintColor = [UIColor blackColor];
    s.tag = t;
    s.transform = CGAffineTransformMakeScale(0.82, 0.82);
    [s addTarget:self action:@selector(swChanged:) forControlEvents:UIControlEventValueChanged];
    return s;
}

- (void)swChanged:(UISwitch *)s {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setBool:s.isOn forKey:(s.tag == 1 ? @"dp_img" : @"dp_beat")];
    [d synchronize];
}

- (void)toggleCollapse {
    self.collapsed = !self.collapsed;
    [self collapse:YES];
    [[NSUserDefaults standardUserDefaults] setBool:self.collapsed forKey:@"dp_collapsed"];
}

- (void)collapse:(BOOL)anim {
    CGFloat w = self.collapsed ? 62 : 270;
    CGFloat h = self.collapsed ? 48 : 158;
    void (^b)(void) = ^{
        CGRect f = self.frame;
        self.frame = CGRectMake(f.origin.x, f.origin.y, w, h);
        self.box.frame = self.bounds;
        self.header.frame = CGRectMake(0, 0, w, 48);
        self.line.frame = CGRectMake(14, 48, w - 28, 1);
        BOOL hd = self.collapsed;
        self.line.hidden = hd; self.lImg.hidden = hd; self.lBeat.hidden = hd;
        self.sImg.hidden = hd; self.sBeat.hidden = hd;
    };
    if (anim) [UIView animateWithDuration:0.22 animations:b];
    else b();
}

- (void)pan:(UIPanGestureRecognizer *)g {
    CGPoint t = [g translationInView:self.superview];
    self.center = CGPointMake(self.center.x + t.x, self.center.y + t.y);
    [g setTranslation:CGPointZero inView:self.superview];
    if (g.state == UIGestureRecognizerStateEnded) {
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        [d setFloat:self.frame.origin.x forKey:@"dp_x"];
        [d setFloat:self.frame.origin.y forKey:@"dp_y"];
        [d synchronize];
    }
}

- (BOOL)autoImageOn { return self.sImg.isOn; }
- (BOOL)autoBeatOn  { return self.sBeat.isOn; }

@end

static NSArray<NSNumber *> *DetectBeats(NSURL *url) {
    if (!url) return @[];
    NSError *e = nil;
    AVAudioFile *f = [[AVAudioFile alloc] initForReading:url error:&e];
    if (!f || e) return @[];
    AVAudioPCMBuffer *b = [[AVAudioPCMBuffer alloc] initWithPCMFormat:f.processingFormat
                                                        frameCapacity:(AVAudioFrameCount)f.length];
    if (![f readIntoBuffer:b error:&e]) return @[];
    if (b.format.channelCount == 0 || b.floatChannelData == NULL) return @[];

    float *s = b.floatChannelData[0];
    NSUInteger n = b.frameLength;
    double sr = f.processingFormat.sampleRate;
    if (n == 0 || sr <= 0) return @[];

    const NSUInteger hop = (NSUInteger)(sr * 0.010);
    const NSUInteger win = (NSUInteger)(sr * 0.020);
    if (hop < 1 || win < hop) return @[];

    NSUInteger cnt = (n - win) / hop + 1;
    if (cnt < 4) return @[];

    float *en = calloc(cnt, sizeof(float));
    for (NSUInteger i = 0; i < cnt; i++) {
        float sum = 0;
        NSUInteger st = i * hop;
        for (NSUInteger j = 0; j < win; j++) { float v = s[st + j]; sum += v * v; }
        en[i] = sum / (float)win;
    }

    float *flux = calloc(cnt, sizeof(float));
    for (NSUInteger i = 1; i < cnt; i++) {
        float d = en[i] - en[i - 1];
        flux[i] = d > 0 ? d : 0;
    }
    free(en);

    NSUInteger hist = (NSUInteger)(0.35 / 0.010);
    if (hist < 4) hist = 4;

    NSMutableArray *beats = [NSMutableArray array];
    double last = -10.0;
    for (NSUInteger i = hist; i < cnt; i++) {
        float avg = 0;
        for (NSUInteger k = i - hist; k < i; k++) avg += flux[k];
        avg /= (float)hist;
        if (flux[i] > avg * 1.55f && flux[i] > 1e-6f) {
            double t = (double)(i * hop) / sr;
            if (t - last >= 0.14) { [beats addObject:@(t)]; last = t; }
        }
    }
    free(flux);
    return beats;
}

static UIWindow  *gWin = nil;
static PanelView *gPanel = nil;

static void ShowPanel(void) {
    if (gWin) { gWin.hidden = NO; return; }
    dispatch_async(dispatch_get_main_queue(), ^{
        gWin = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        gWin.windowLevel = UIWindowLevelAlert + 2000;
        gWin.backgroundColor = [UIColor clearColor];
        gWin.rootViewController = [UIViewController new];
        gWin.rootViewController.view.backgroundColor = [UIColor clearColor];
        gWin.hidden = NO;
        gPanel = [[PanelView alloc] init];
        [gWin.rootViewController.view addSubview:gPanel];
    });
}

static void FillEmptySlots(UIImage *img, UIView *root) {
    if (!img || !root) return;
    if ([root isKindOfClass:[UIImageView class]]) {
        UIImageView *iv = (UIImageView *)root;
        if ((iv.image == nil || iv.image.size.width <= 1) && root.userInteractionEnabled) {
            iv.image = img;
            iv.contentMode = UIViewContentModeScaleAspectFill;
            iv.clipsToBounds = YES;
        }
    }
    for (UIView *c in root.subviews) FillEmptySlots(img, c);
}

%hook UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)p
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    %orig;
    if (!gPanel || !gPanel.autoImageOn) return;
    UIImage *picked = info[UIImagePickerControllerOriginalImage];
    if (!picked) return;
    UIView *root = p.presentingViewController.view ?: [UIApplication sharedApplication].keyWindow.rootViewController.view;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        FillEmptySlots(picked, root);
    });
}
%end

%hook UIViewController
- (void)viewDidAppear:(BOOL)a { %orig; ShowPanel(); }
%end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{ ShowPanel(); });
}
