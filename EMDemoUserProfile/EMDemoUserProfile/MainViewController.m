//
//  MainViewController.m
//  HXDEMO
//
//  Created by 沈冲 on 16/3/10.
//  Copyright © 2016年 shenchong. All rights reserved.
//

#import "MainViewController.h"
#import "ConversationListController.h"


@interface MainViewController ()<IChatManagerDelegate>
@property (nonatomic, weak) ConversationListController *chatListVC;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /**
     *   在iOS 7中，苹果引入了一个新的属性，叫做[UIViewController setEdgesForExtendedLayout:]，它的默认值为UIRectEdgeAll。当你的容器是navigation controller时，默认的布局将从navigation bar的顶部开始。这就是为什么所有的UI元素都往上漂移了44pt。修复这个问题的快速方法就是在方法- (void)viewDidLoad中添加如下一行代码：
         self.edgesForExtendedLayout = UIRectEdgeNone;
     */
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self registerNotifications];
    [self setUpSubviews];
    [self setUpUnreadMessageCount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - registerNotifications
-(void)registerNotifications{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)setUpSubviews{
    self.tabBar.backgroundImage = [[UIImage imageNamed:@"tabbarBackground"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
    self.tabBar.selectionIndicatorImage = [[UIImage imageNamed:@"tabbarSelectBg"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
    
    ConversationListController *VC1 = [[ConversationListController alloc]init];
    self.chatListVC = VC1;
    VC1.title = @"会话";
    VC1.tabBarItem.image = [UIImage imageNamed:@"tabbar_chats"];
    VC1.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_chatsHL"];
    [self unSelectedTapTabBarItems:VC1.tabBarItem];
    [self selectedTapTabBarItems:VC1.tabBarItem];
    UINavigationController *nav1 = [[UINavigationController alloc]initWithRootViewController:VC1];
    [self addChildViewController:nav1];
    
    
    UIViewController *VC2 = [[UIViewController alloc]init];
    VC2.title = @"通讯录";
    VC2.tabBarItem.image = [UIImage imageNamed:@"tabbar_contacts"];
    VC2.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_contactsHL"];
    [self unSelectedTapTabBarItems:VC2.tabBarItem];
    [self selectedTapTabBarItems:VC2.tabBarItem];
    UINavigationController *nav2 = [[UINavigationController alloc]initWithRootViewController:VC2];
    [self addChildViewController:nav2];
    
    
    UIViewController *VC3 = [[UIViewController alloc]init];
    VC3.title = @"设置";
    VC3.tabBarItem.image = [UIImage imageNamed:@"tabbar_setting"];
    VC3.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_settingHL"];
    [self unSelectedTapTabBarItems:VC3.tabBarItem];
    [self selectedTapTabBarItems:VC3.tabBarItem];
    UINavigationController *nav3 = [[UINavigationController alloc]initWithRootViewController:VC3];
    [self addChildViewController:nav3];
    
}

/**
 *  设置tabbar字体
 */
-(void)unSelectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:14], UITextAttributeFont,[UIColor whiteColor],UITextAttributeTextColor,
                                        nil] forState:UIControlStateNormal];
}

-(void)selectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:14],
                                        UITextAttributeFont,RGBACOLOR(0x00, 0xac, 0xff, 1),UITextAttributeTextColor,
                                        nil] forState:UIControlStateSelected];
}

#pragma mark - private
- (void)setUpUnreadMessageCount{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    
    if (_chatListVC) {
        if (unreadCount) {
            _chatListVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)unreadCount];
        }else{
            _chatListVC.tabBarItem.badgeValue = nil;
        }
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

/**
 *  1. 当会话列表有更改时(新添加,删除), 2. 登陆成功时, 以上两种情况都会触发此回调
 */
- (void)didUpdateConversationList:(NSArray *)conversationList{
    [self setUpUnreadMessageCount];
    [self.chatListVC refreshDataSource];
}

- (void)didUnreadMessagesCountChanged{
    [self setUpUnreadMessageCount];
}

@end
