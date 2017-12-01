//
//  TalkViewController.m
//  MHKan
//
//  Created by Yinjw on 2017/11/17.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import "TalkViewController.h"
#import "Masonry.h"
#import "NetworkManager.h"

@interface TalkViewController () <UITextFieldDelegate>

@property(nonatomic, strong)UIView*         inputView;
@property(nonatomic, strong)UIButton*       sendBtn;
@property(nonatomic, strong)UITextField*    textInput;
@property(nonatomic, strong)UITextView*     chatView;

@property(nonatomic)NSInteger               keyBoardHeight;

@end

@implementation TalkViewController

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.inputView = [[UIView alloc] init];
    self.inputView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    [self.view addSubview:self.inputView];
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-15);
        make.height.equalTo(@(40));
    }];
    
    self.sendBtn = [[UIButton alloc] init];
    [self.sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendBtn setBackgroundColor:[UIColor redColor]];
    self.sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    self.sendBtn.titleLabel.textColor = [UIColor blackColor];
    self.sendBtn.layer.cornerRadius = 5;
    self.sendBtn.layer.masksToBounds = YES;
    [self.sendBtn addTarget:self action:@selector(onBtnSender:) forControlEvents:UIControlEventTouchUpInside];
    [self.inputView addSubview:self.sendBtn];
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.inputView);
        make.right.equalTo(self.inputView).offset(-15);
        make.height.equalTo(@(25));
        make.width.equalTo(@(60));
    }];
    
    self.textInput = [[UITextField alloc] init];
    self.textInput.backgroundColor = [UIColor whiteColor];
    self.textInput.placeholder = @"请输入聊天内容";
    self.textInput.delegate = self;
    self.textInput.keyboardType = UIKeyboardTypeWebSearch;
    self.textInput.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textInput.returnKeyType = UIReturnKeyDone;
    self.textInput.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textInput.font = [UIFont systemFontOfSize:13];
    self.textInput.textColor = [UIColor blackColor];
    [self.inputView addSubview:self.textInput];
    [self.textInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.inputView).offset(15);
        make.centerY.equalTo(self.sendBtn);
        make.height.equalTo(self.inputView);
        make.right.equalTo(self.sendBtn.mas_left).offset(-10);
    }];
    
    self.chatView = [[UITextView alloc] init];
    self.chatView.textColor = [UIColor blackColor];
    self.chatView.editable = NO;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
    self.chatView.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:self.chatView];
    [self.chatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(15);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.bottom.equalTo(self.inputView.mas_top).offset(-10);
    }];
    
    [[NetworkManager sharedManager] setStreamRecvFunc:^(NSDictionary* data) {
        [self showTextFromServer:data];
    }];
}

-(void)onBtnSender:(id)sender
{
//    NSString* chatText = self.textInput.text;
//    NSDictionary* data = @{@"chat":chatText};
//    [[NetworkManager sharedManager] sendData:data];
}

-(void)showTextFromServer:(NSDictionary*)data
{
    NSString* text = self.chatView.text;
    text = [NSString stringWithFormat:@"%@\n%@",text, [data objectForKey:@"chat"]];
    self.chatView.text = text;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.textInput resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textInput resignFirstResponder];
    return YES;
}

-(void)updateViewConstraints
{
    [self.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-self.keyBoardHeight-15);
    }];
    
    [super updateViewConstraints];
}

#pragma mark - keybord event

- (void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    self.keyBoardHeight = keyboardRect.size.height;
    [self.view setNeedsUpdateConstraints];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.keyBoardHeight = 0;
    [self.view setNeedsUpdateConstraints];
}

@end
