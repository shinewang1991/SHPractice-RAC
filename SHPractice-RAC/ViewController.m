//
//  ViewController.m
//  SHPractice-RAC
//
//  Created by Shine on 2019/3/20.
//  Copyright © 2019 shine. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC.h>

#define k_notificaton_name @"k_notificaton_name"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usenameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (copy, nonatomic) NSString *userName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self loginCommand];
//    [self createSignal];
//    [self selectorSignal];
//    [self notificatonSignal];
//    [self timerSingal];
//    [self KVOSignal];
    [self demo];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

#pragma mark - 基础语法

//创建信号-订阅信号-发送信号
- (void)createSignal{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送信号"];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    RACDisposable *disposable = [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"信号内容----%@",x);
    } error:^(NSError * _Nullable error) {
        NSLog(@"信号---error");
    } completed:^{
        NSLog(@"信号---completed");
    }];
    
    [disposable dispose];
}

- (void)selectorSignal{
    [[self rac_signalForSelector:@selector(viewDidAppear:)] subscribeNext:^(id  _Nullable x) {
        NSLog(@"viewwillappear");
    }];
}

- (void)KVOSignal{
    [RACObserve(self, userName) subscribeNext:^(id  _Nullable x) {
        NSLog(@"username-------%@",x);
    }];
    
    self.userName = @"Michael";
    self.userName = @"Tom";
}

- (void)notificatonSignal{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:k_notificaton_name object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"通知来了-----%@",x);
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:k_notificaton_name object:@"Hello World!"];
}

- (void)timerSingal{
    [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
        NSLog(@"timer invoke -------%@",x);
    }];
}

#pragma mark - take/skip/repeat用法
- (void)demo{
    /*
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        [subscriber sendNext:@"3"];
        [subscriber sendNext:@"4"];
        [subscriber sendNext:@"5"];
        return nil;
    }] take:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"x---------%@",x);   //只会输出前两个
    }];
     */
    
    /*
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        [subscriber sendNext:@"3"];
        [subscriber sendNext:@"4"];
        [subscriber sendNext:@"5"];
        return nil;
    }] skip:3] subscribeNext:^(id  _Nullable x) {
        NSLog(@"x---------%@",x);   //只会输出后两个
    }];
    */
    
    /*
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"1"];
        return nil;
    }] delay:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"x---------%@",x);   //延时发送信号
    }];
     */
    
    /*
    [[self.usenameTextfield.rac_textSignal throttle:3] subscribeNext:^(NSString * _Nullable x) {
       //发送请求
        NSLog(@"%@---------",x);    //3秒内输入框值不发生变化，才发送信号
    }];
     */
    
    /*
    [[self.usenameTextfield.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString * _Nullable x) {
       NSLog(@"%@---------",x);
    }];
     */
    
    //timeout
    /*
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{
            [subscriber sendNext:@"1"];
            [subscriber sendCompleted];
        }];
        return nil;
    }] timeout:2 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id  _Nullable x) {
        NSLog(@"x-------------%@",x);
    } error:^(NSError * _Nullable error) {
        NSLog(@"error-------------%@",error);
    } completed:^{
        NSLog(@"complecated-------------");
    }];
     */
    
    //ignore
    [[self.usenameTextfield.rac_textSignal ignore:@"shine"] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"x-------------%@",x);   //输入框为shine时不发送消息
    }];
    
}

#pragma mark - 登录逻辑
- (void)loginCommand{
//    RACSignal *buttonEableSignal = [[RACSignal combineLatest:@[self.usenameTextfield.rac_textSignal,self.passwordTextfield.rac_textSignal]] map:^id _Nullable(id  _Nullable value) {
//        NSLog(@"username------%@",value[0]);
//        NSLog(@"password------%@",value[1]);
//        return @([value[0] length] > 0 && [value[1] length] > 6);
//    }];
//
//    self.loginBtn.rac_command = [[RACCommand alloc] initWithEnabled:buttonEableSignal signalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
//        return [RACSignal empty];
//    }];
    
    RAC(self.loginBtn,enabled) = [RACSignal combineLatest:@[self.usenameTextfield.rac_textSignal,self.passwordTextfield.rac_textSignal] reduce:^id _Nullable(NSString * username, NSString * password){
        NSLog(@"username------%@",username);
        NSLog(@"password------%@",password);
        return @([username length] > 0 && [password length] > 6);
    }];
}


@end
