//
//  AnimationsViewController.m
//  AnimationTableTest
//
//  Created by Kevin Yu on 1/1/19.
//  Copyright © 2019 Kevin Yu. All rights reserved.
//

#import "AnimationsViewController.h"

@interface AnimationsViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewVerticalConstraint;
@property (strong, nonatomic) UIButton *imageView;

@property (strong, nonatomic) UISwipeGestureRecognizer *upSwipe;
@property (strong, nonatomic) UISwipeGestureRecognizer *downSwipe;

@property (strong, nonatomic) NSArray<NSString *> *animationOptions;

@end

@implementation AnimationsViewController

static NSString *reuseIdentifier = @"reuseIdentifier";
static NSInteger imageSize = 214;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

// MARK: - Setup Methods

- (void)setup {
    [self createImageView];
    [self setupSwipeGestures];
    [self setupTableView];
}

- (void)setupTableView {
    self.animationOptions = @[@"Blink",
                              @"Spin",
                              @"Wave",
                              @"Blink and Spin",
                              @"Spin and Wave"];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:reuseIdentifier];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view bringSubviewToFront:self.tableView];
}

- (void)setupSwipeGestures {
    self.upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                             action:@selector(upSwipeGesture)];
    self.upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:self.upSwipe];
    
    self.downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                               action:@selector(downSwipeGesture)];
    self.downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:self.downSwipe];
    
}

// MARK: - Custom Action Methods

- (void)upSwipeGesture {
    if (self.tableViewVerticalConstraint.constant != 0) { return; }
    [self toggleTable:self.tableView.frame.size.height completion:nil];
}

- (void)downSwipeGesture {
    if (self.tableViewVerticalConstraint.constant == 0) { return; }
    [self toggleTable:0.0 completion:nil];
}

- (void)toggleTable:(CGFloat)height completion:(void (^)(void))completion {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.5 animations:^{
        self.tableViewVerticalConstraint.constant = height;
        [self.view layoutIfNeeded]; // Called on parent view
    } completion:^(BOOL finished) {
        if (finished == YES) {
            if (completion != nil) {
                completion();
            }
        }
    }];
}

- (void)createImageView {
    self.imageView = [[UIButton alloc] init];
    UIImage *image = [UIImage imageNamed:@"clickme.png"];
    [self.imageView setImage:image forState:UIControlStateNormal];
    self.imageView.frame = CGRectMake(0, 0,
                                      imageSize, imageSize);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = imageSize / 2;
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addTarget:self
                       action:@selector(chooseImage)
             forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.imageView];
    self.imageView.center = self.view.center;
}

- (void)chooseImage {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

// MARK: - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self.imageView setImage:image forState:UIControlStateNormal];
    self.imageView.center = self.view.center;
    [picker dismissViewControllerAnimated:true completion:nil];
}

// MARK: - UITableView Data Source Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.animationOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier
                                                            forIndexPath:indexPath];
    cell.textLabel.text = self.animationOptions[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak AnimationsViewController *weakSelf = self;
    void(^animation)(void) = ^{
        AnimationsViewController *strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        switch (indexPath.row) {
            case 0:
                [strongSelf blinkAnimation];
                break;
            case 1:
                [strongSelf spinAnimation];
                break;
            case 2:
                [strongSelf waveAnimation];
                break;
            case 3:
                [strongSelf blinkAndSpinAnimation];
                break;
            default:
                [strongSelf spinAndWaveAnimation];
                break;
        }
    };
    
    [self toggleTable:0.0 completion:animation];
}

// MARK: - Animations

- (void)blinkAnimation {
    CAKeyframeAnimation *blink = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    
    blink.values = @[@1.0, @0.0, @1.0, @0.0, @1.0];
    blink.duration = 1.5;
    
    [self.imageView.layer addAnimation:blink forKey:@"blinkAnimation"];
}
- (void)spinAnimation {
    CABasicAnimation *spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    spin.fromValue = @0.0;
    spin.toValue = @(M_PI * 2.0);
    spin.duration = 1.0;
    
    [self.imageView.layer addAnimation:spin forKey:@"spinAnimation"];
}
- (void)waveAnimation {
    CGFloat duration = 3.0;
    CGFloat width = self.view.frame.size.width;
    CAAnimationGroup *group = [CAAnimationGroup new];
    
    group.duration = duration;
    
    CABasicAnimation *xAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    xAnimation.fromValue = @(-width);
    xAnimation.toValue = @(width);
    xAnimation.duration = duration;
    
    CAKeyframeAnimation *yAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    yAnimation.values = @[@0.0, @100.0, @-100.0, @100.0, @-100.0, @0.0];
    yAnimation.duration = duration;
    
    group.animations = @[xAnimation, yAnimation];
    
    [self.imageView.layer addAnimation:group forKey:@"waveAnimation"];
}
- (void)blinkAndSpinAnimation {
    CGFloat duration = 1.5;
    CAAnimationGroup *group = [CAAnimationGroup new];
    group.duration = duration;
    
    CAKeyframeAnimation *blink = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    blink.values = @[@1.0, @0.0, @1.0, @0.0, @1.0];
    blink.duration = duration;
    
    CABasicAnimation *spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    spin.fromValue = @0.0;
    spin.toValue = @(M_PI * 2.0);
    spin.duration = duration;
    group.animations = @[blink, spin];
    
    [self.imageView.layer addAnimation:group forKey:@"blinkAndSpinAnimation"];
}
- (void)spinAndWaveAnimation {
    CGFloat duration = 3.0;
    CGFloat width = self.view.frame.size.width;
    CAAnimationGroup *group = [CAAnimationGroup new];
    
    group.duration = duration;
    
    CABasicAnimation *xAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    xAnimation.fromValue = @(-width);
    xAnimation.toValue = @(width);
    xAnimation.duration = duration;
    
    CAKeyframeAnimation *yAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    yAnimation.values = @[@0.0, @100.0, @-100.0, @100.0, @-100.0, @0.0];
    yAnimation.duration = duration;
    
    CAKeyframeAnimation *blink = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    blink.values = @[@1.0, @0.0, @1.0, @0.0, @1.0];
    blink.duration = duration;
    
    group.animations = @[xAnimation, yAnimation, blink];
    
    [self.imageView.layer addAnimation:group forKey:@"spinAndWaveAnimation"];
}

@end
