//
//  CMViewController.m
//  CircleMusic
//
//  Created by Kawasaki Toshiya on 5/5/13.
//  Copyright (c) 2013 FORCECLESS. All rights reserved.
//

#import "CMViewController.h"
#import "CMAppDelegate.h"
#define TIMER 0.05f

#define SCROLL_SPEED 1.0

@interface CMViewController ()

@end

@implementation CMViewController


-(void)viewWillAppear:(BOOL)animated
{
    //  self.cellCount=5;
    // [_cv reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    
    
    
}

//http://blog.yabasoft.biz/archives/2982 をするので
- (void)fadeSplashScreen {
    UIImage *img;
    CMAppDelegate *ad=[[UIApplication sharedApplication] delegate];
    NSLog(@"Splash:%d",ad.iOStype);
    UIImageView *imageview;
    if(ad.iOStype==2){
        img = [UIImage imageNamed:@"Default@2x.png"];
        CGRect r=CGRectMake(0, -20, 320,480);
        imageview =
        [[UIImageView alloc] initWithFrame:r];
        imageview.image = img;
    }else{
        img = [UIImage imageNamed:@"Default-568h@2x.png"];
        imageview =
        [[UIImageView alloc] initWithFrame:self.view.frame];
        imageview.image = img;
    }
    

    [self.view addSubview:imageview];
    
    self.view.alpha = 1.0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:3.0];
    imageview.alpha = 0.0;
    
    [UIView commitAnimations];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
	// Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    [NSThread detachNewThreadSelector:@selector(artistvcThread)
                             toTarget:self
                           withObject:nil];
    [NSThread detachNewThreadSelector:@selector(songvcThread)
                             toTarget:self
                           withObject:nil];
    [NSThread detachNewThreadSelector:@selector(albumvcThread)
                             toTarget:self
                           withObject:nil];
    [NSThread detachNewThreadSelector:@selector(playlistvcThread)
                             toTarget:self
                           withObject:nil];
    
    if(_infoViewController==NULL){
        _infoViewController=[[CMInfoViewController alloc] initWithNibName:@"CMInfoViewController" bundle:nil];
        _infoViewController.delegate=self;
        
    }
    
    
    
#pragma mark Genre View
    _center=self.view.center;
    _radius=self.view.frame.size.width*0.33;
    float size=self.view.frame.size.width*0.35;
    _angle=M_PI/2.0;
    _interval_angle=2.0*M_PI/5.0;
    _views=[NSMutableArray array];
    
    
    
    
    CMPlayerButtonView *artist=[[CMPlayerButtonView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    [artist makeCircle];
    artist.center=CGPointMake(_center.x+_radius*cos(_angle-0.0*_interval_angle),_center.y-_radius*sin(_angle-0.0*_interval_angle));
    artist.image=[UIImage imageNamed:@"cell-artist.png"];
    [self.view addSubview:artist];
    [_views addObject:artist];
    
    
    CMPlayerButtonView *song=[[CMPlayerButtonView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    [song makeCircle];
    song.center=CGPointMake(_center.x+_radius*cos(_angle-1.0*_interval_angle),_center.y-_radius*sin(_angle-1.0*_interval_angle));
    song.image=[UIImage imageNamed:@"cell-song.png"];
    [self.view addSubview:song];
    [_views addObject:song];
    
    
    CMPlayerButtonView *album=[[CMPlayerButtonView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    [album makeCircle];
    album.center=CGPointMake(_center.x+_radius*cos(_angle-2.0*_interval_angle),_center.y-_radius*sin(_angle-2.0*_interval_angle));
    album.image=[UIImage imageNamed:@"cell-album.png"];
    [self.view addSubview:album];
    [_views addObject:album];
    
    
    CMPlayerButtonView *list=[[CMPlayerButtonView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    [list makeCircle];
    list.center=CGPointMake(_center.x+_radius*cos(_angle-3.0*_interval_angle),_center.y-_radius*sin(_angle-3.0*_interval_angle));
    list.image=[UIImage imageNamed:@"cell-playlist.png"];
    [self.view addSubview:list];
    [_views addObject:list];
    
    
    CMPlayerButtonView *info=[[CMPlayerButtonView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    [info makeCircle];
    info.center=CGPointMake(_center.x+_radius*cos(_angle-4.0*_interval_angle),_center.y-_radius*sin(_angle-4.0*_interval_angle));
    info.image=[UIImage imageNamed:@"cell-info.png"];
    [self.view addSubview:info];
    [_views addObject:info];
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapRecognizer.delegate=self;
    [self.view addGestureRecognizer:tapRecognizer];
    
    UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panRecognizer.delegate=self;
    [self.view addGestureRecognizer:panRecognizer];
    
    UILongPressGestureRecognizer* longpressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    longpressRecognizer.delegate=self;
    [self.view addGestureRecognizer:longpressRecognizer];
    
    _point_tap_began.x=-99;
    
    /*
     _scroll_speed=SCROLL_SPEED;
     _tm =
     [NSTimer scheduledTimerWithTimeInterval:TIMER target:self selector:@selector(clock:) userInfo:nil repeats:YES];
     
     [_tm fire];
     */
    _isEnabled=NO;
    _progress_view=[[UIView alloc] initWithFrame:self.view.frame];
    _progress_view.backgroundColor=[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.65f];
    [self.view addSubview:_progress_view];
    
    _progress_bar= [[UIProgressView alloc]
                    initWithProgressViewStyle:UIProgressViewStyleBar];
    _progress_bar.progressTintColor=[UIColor grayColor];
    _progress_bar.trackTintColor=[UIColor whiteColor];
    _progress_bar.frame = CGRectMake(0, 0, 200, 10);
    _progress_bar.center=_progress_view.center;
    _progress_bar.progress=0.0f;
    [_progress_view addSubview:_progress_bar];
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    label.text=@"Now Loading...";
    label.center=CGPointMake(self.view.center.x,self.view.center.y+_progress_bar.frame.size.height*2);
    label.backgroundColor=[UIColor clearColor];
    label.textColor=[UIColor whiteColor];
    label.textAlignment=NSTextAlignmentCenter;
    [_progress_view addSubview:label];
    
    [self fadeSplashScreen];
    
}

#pragma mark gesture
-(void)updateCircle:(float)angle WithRatio:(float)ratio
{
    angle*=1.5;
    _angle+=angle;
    for (int i=0; i<[_views count]; i++) {
        CMPlayerButtonView *view=_views[i];
        view.center=CGPointMake(_center.x+_radius*cos(_angle-i*_interval_angle)*ratio,_center.y-_radius*sin(_angle-i*_interval_angle)*ratio);
    }
    
}
#pragma mark - scrolling

-(void)clock:(id)something
{
    if(!_isEnabled){
        if(_scroll_speed>0.01 || _scroll_speed<-0.01){
            float scale_value=1.0-_scroll_speed/SCROLL_SPEED;
            [self updateCircle:_scroll_speed WithRatio:scale_value];
            _scroll_speed*=0.96;
            //NSLog(@"SPEED:%lf",_scroll_speed);
            for (int i=0; i<[_views count]; i++) {
                CMPlayerButtonView *view=_views[i];
                
                CGAffineTransform scale = CGAffineTransformMakeScale(scale_value, scale_value);
                [view setTransform:scale];
            }
            
        }else{
            CMPlayerButtonView *artist=_views[0];
            if(abs(artist.center.x-_center.x)<1 &&  artist.center.y < _center.y){
                _scroll_speed=0.0;
                //  NSLog(@"scroll_end");
                [_tm invalidate];
                [self enable];
            }else{
                
                [self updateCircle:_scroll_speed WithRatio:1.0];
                
            }
            
        }
    }else{
        /*
         if(_scroll_speed>0.01 || _scroll_speed<-0.01){
         [self updateCircle:_scroll_speed WithRatio:1.0];
         _scroll_speed*=0.96;
         
         }else{
         
         _scroll_speed=0.0;
         //  NSLog(@"scroll_end");
         [_tm invalidate];
         }
         */
        
        
    }
    
}

-(void)enable{
    for (int i=0; i<[_views count]; i++) {
        CMPlayerButtonView *view=_views[i];
        void (^animations)(void) = ^{
            
            float scale_value=1.25;
            
            CGAffineTransform scale = CGAffineTransformMakeScale(scale_value, scale_value);
            [view setTransform:scale];
            
        };
        
        void (^completionAnimation)(BOOL) = ^(BOOL finished) {
            
            [self performSelector:@selector(enabled:) withObject:view afterDelay:0.1];
        };
        
        [UIView animateWithDuration:0.5 animations:animations completion:completionAnimation];
    }
    
}

-(void)enabled:(UIView *)view
{
    void (^animations)(void) = ^{
        float scale_value=1.0;
        
        CGAffineTransform scale = CGAffineTransformMakeScale(scale_value, scale_value);
        [view setTransform:scale];
    };
    
    [UIView animateWithDuration:0.7 animations:animations completion:^(BOOL finished){_isEnabled=YES;}];
    
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(!_isEnabled) return YES;
    
    if([gestureRecognizer isMemberOfClass:[UITapGestureRecognizer class]]){
        _scroll_speed=0.0;
        CGPoint point=[touch locationInView:self.view];
        if(_point_tap_began.x==-99){
            for(int i=0;i<[_views count];i++){
                CMPlayerButtonView *view=_views[i];
                
                
                
                
                if(CGRectContainsPoint(view.frame, point)){
                    
                    switch (i) {
                        case 0:
                            title_text.text=@"Artist";
                            break;
                        case 1:
                            title_text.text=@"Song";
                            break;
                        case 2:
                            title_text.text=@"Album";
                            break;
                        case 3:
                            title_text.text=@"Playlist";
                            break;
                        case 4:
                            title_text.text=@"Information";
                            break;
                            
                        default:
                            break;
                    }
                    
                    void (^animations)(void) = ^{
                        
                        float scale_value=1.25;
                        
                        CGAffineTransform scale = CGAffineTransformMakeScale(scale_value, scale_value);
                        [view setTransform:scale];
                        
                    };
                    
                    [UIView animateWithDuration:0.1 animations:animations completion:nil];
                    _on[i]=YES;
                    _point_tap_began=point;
                    
                }
                
            }
        }
        
        
        
        
    }
    
    return YES;
}

- (void)handlePanGesture:(UIGestureRecognizer *)sender
{
    if(!_isEnabled) return;
    title_text.text=@"Circle";
    [self resetControlButtons];
    return;
    
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer*)sender;
    CGPoint point = [pan translationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    CGPoint current_point=CGPointMake(_point_tap_began.x+point.x, _point_tap_began.y+point.y);
    if(sender.state==UIGestureRecognizerStateCancelled ||sender.state==UIGestureRecognizerStateFailed){
        [self resetControlButtons];
    }else{
        
        float side=self.view.frame.size.width/3;
        float div2=self.view.frame.size.width/2;
        
        float angle=0;
        if(CGRectContainsPoint(CGRectMake(0, _center.y-div2, side, side), current_point)){
            NSLog(@"0-0");
            angle=sqrt(pow(velocity.x*0.0001,2)+pow(MAX(velocity.y,0)*0.0001,2));
            if(velocity.x>0)  angle*=-1;
            if(velocity.x<0) angle*=1;
            
            [self updateCircle:angle WithRatio:1.0];
            
        }else if(CGRectContainsPoint(CGRectMake(side, _center.y-div2, side, side), current_point)){
            NSLog(@"0-1");
            angle=sqrt(pow(velocity.x*0.0001,2));
            if(velocity.x>0)  angle*=-1;
            if(velocity.x<0) angle*=1;
            [self updateCircle:1*angle WithRatio:1.0];
            
            
        }else if(CGRectContainsPoint(CGRectMake(side*2, _center.y-div2, side, side), current_point)){
            NSLog(@"0-2");
            angle=sqrt(pow(velocity.x*0.0001,2)+pow(MAX(velocity.y,0)*0.0001,2));
            if(velocity.x>0) angle*=-1;
            if(velocity.x<0) angle*=1;
            [self updateCircle:1*angle WithRatio:1.0];
        }else if(CGRectContainsPoint(CGRectMake(0, _center.y-div2+side, side, side), current_point)){
            NSLog(@"1-0");
            angle=sqrt(pow(velocity.y*0.0001,2));
            if(velocity.y>0) angle*=1;
            if(velocity.y<0) angle*=-1;
            [self updateCircle:1*angle WithRatio:1.0];
        }else if(CGRectContainsPoint(CGRectMake(side*2, _center.y-div2+side, side, side), current_point)){
            NSLog(@"1-2");
            angle=sqrt(pow(velocity.y*0.0001,2));
            if(velocity.y>0) angle*=-1;
            if(velocity.y<0) angle*=1;
            [self updateCircle:1*angle WithRatio:1.0];
        }else if(CGRectContainsPoint(CGRectMake(0, _center.y+div2-side, side, side), current_point)){
            NSLog(@"2-0");
            angle=sqrt(pow(velocity.x*0.0001,2)+pow(MAX(velocity.y,0)*0.0001,2));
            if(velocity.x>0) angle*=1;
            if(velocity.x<0) angle*=-1;
            [self updateCircle:1*angle WithRatio:1.0];
        }else if(CGRectContainsPoint(CGRectMake(side, _center.y+div2-side, side, side), current_point)){
            NSLog(@"2-1");
            angle=sqrt(pow(velocity.x*0.0001,2));
            if(velocity.x>0) angle*=1;
            if(velocity.x<0) angle*=-1;
            [self updateCircle:1*angle WithRatio:1.0];
        }else if(CGRectContainsPoint(CGRectMake(side*2, _center.y+div2-side, side, side), current_point)){
            NSLog(@"2-2");
            angle=sqrt(pow(velocity.x*0.0001,2)+pow(MAX(velocity.y,0)*0.0001,2));
            if(velocity.x>0) angle*=1;
            if(velocity.x<0) angle*=-1;
            [self updateCircle:1*angle WithRatio:1.0];
        }
        
        if (sender.state == UIGestureRecognizerStateEnded){
            _scroll_speed=angle;
            //  NSLog(@"Tag:%d",tag);
            _tm =
            [NSTimer scheduledTimerWithTimeInterval:TIMER target:self selector:@selector(clock:) userInfo:nil repeats:YES];
            
            [_tm fire];
            [self resetControlButtons];
        }
        
        
    }
}
- (void)handleTapGesture:(UIGestureRecognizer *)sender
{
    if(!_isEnabled) return;
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        
        UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
        CGPoint point=[tap locationInView:self.view];
        
        [self resetControlButtons];
        
        for(int i=0;i<[_views count];i++){
            CMPlayerButtonView *view=_views[i];
            if(CGRectContainsPoint(view.frame, point)){
                [self.view bringSubviewToFront:_views[i]];
                
                BOOL hasLoaded;
                switch (i) {
                    case 0:
                        hasLoaded=_artistViewController.hasLoaded;
                        break;
                    case 1:
                        hasLoaded=_songViewController.hasLoaded;
                        break;
                    case 2:
                        hasLoaded=_albumViewController.hasLoaded;
                        break;
                    case 3:
                        hasLoaded=_playlistViewController.hasLoaded;
                        break;
                    case 4:
                        hasLoaded=_infoViewController.hasLoaded;
                        break;
                        
                        
                }
                
                if(!hasLoaded && i!=4){
                    _progress_bar.progress=0.0f;
                    [self.view addSubview:_progress_view];
                }
                _isEnabled=NO;
                
                [self goCenter:i];
                
            }
        }
        
        
        
        
        
    }else if(sender.state==UIGestureRecognizerStateCancelled ||sender.state==UIGestureRecognizerStateFailed){
        [self resetControlButtons];
    }
}

-(void)goCenter:(int) i
{
    CMPlayerButtonView *view=_views[i];
    void (^animations)(void) = ^{
        
        view.center=_center;
        
    };
    
    void (^completionAnimation)(BOOL) = ^(BOOL finished) {
        
        switch (i) {
            case 0:
                [self.navigationController pushViewController:_artistViewController animated:NO];
                break;
            case 1:
                [self.navigationController pushViewController:_songViewController animated:NO];
                break;
            case 2:
                [self.navigationController pushViewController:_albumViewController animated:NO];
                break;
            case 3:
                [self.navigationController pushViewController:_playlistViewController animated:NO];
                break;
            case 4:
                [self.navigationController pushViewController:_infoViewController animated:NO];
                break;
                
            default:
                break;
        }
        
        
    };
    [UIView animateWithDuration:0.5 animations:animations completion:completionAnimation];
}

-(void)resetControlButtons
{
    
    for(int i=0;i<[_views count];i++){
        _on[i]=NO;
        CMPlayerButtonView *view=_views[i];
        float scale_value=1.0;
        CGAffineTransform scale = CGAffineTransformMakeScale(scale_value, scale_value);
        [view setTransform:scale];
        _point_tap_began.x=-99;
    }
}


#pragma mark - load vc
- (void)artistvcThread {
    //各種Viewの読み込み
    if(_artistViewController==NULL){
        _artistViewController=[[CMAlbumViewController alloc] initWithNibName:@"CMAlbumViewController" bundle:nil withType:0];
        _artistViewController.type=0;
        _artistViewController.delegate=self;
        [_artistViewController prepare];
    }
    
}

- (void)songvcThread {
    
    if(_songViewController==NULL){
        _songViewController=[[CMAlbumViewController alloc] initWithNibName:@"CMAlbumViewController" bundle:nil withType:1];
        _songViewController.type=1;
        _songViewController.delegate=self;
        [_songViewController prepare];
    }
    
}
- (void)albumvcThread {
    if(_albumViewController==NULL){
        _albumViewController=[[CMAlbumViewController alloc] initWithNibName:@"CMAlbumViewController" bundle:nil withType:2];
        _albumViewController.type=2;
        _albumViewController.delegate=self;
        [_albumViewController prepare];
    }
}
- (void)playlistvcThread {
    
    if(_playlistViewController==NULL){
        _playlistViewController=[[CMAlbumViewController alloc] initWithNibName:@"CMAlbumViewController" bundle:nil withType:3];
        _playlistViewController.type=3;
        _playlistViewController.delegate=self;
        [_playlistViewController prepare];
        
    }
    
    
}

-(void)CMAlbumViewControllerDidChangeProgressOfLoad:(float)progress From:(CMAlbumViewController*)vc
{
    
    if(vc.type==1){
        NSLog(@"%d|%lf",vc.type,progress);
        dispatch_async(dispatch_get_main_queue(), ^{
            // your code here
            _progress_bar.progress=progress;
        });
    }
}

-(void)CMAlbumViewControllerDidChangeProgressOfShow:(float)progress From:(CMAlbumViewController*)vc
{
    
    NSLog(@"Show%d|%lf",vc.type,progress);
    // your code here
    @try {
        [self performSelectorInBackground:@selector(updateProgress:)
                               withObject:[NSNumber numberWithFloat:progress]];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    
}

-(void)updateProgress:(NSNumber*)progress
{
    _progress_bar.progress=[progress floatValue];
}

-(void)CMAlbumViewControllerDidFinishLoading:(CMAlbumViewController *)vc
{
    NSLog(@"%d FINISH",vc.type);
    if (vc.type==1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // your code here
            [_progress_view removeFromSuperview];
            _isEnabled=YES;
        });
        
    }
    
    
}

-(void)CMAlbumViewControllerDidFinishShowing:(CMAlbumViewController *)vc
{
    title_text.text=@"Circle";
    [self updateCircle:0 WithRatio:1.0];
    _isEnabled=YES;
    [_progress_view removeFromSuperview];
    
}

-(void)CMInfoViewControllerDidFinishShowing:(CMAlbumViewController *)vc
{
    title_text.text=@"Circle";
    [self updateCircle:0 WithRatio:1.0];
    _isEnabled=YES;
    [_progress_view removeFromSuperview];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"MEMORYYYYYYYYYYY");
}

@end
