 //
//  XHDDOnlineChatDetailController.m
//  DDOnline
//
//  Created by qianfeng on 16/3/18.
//  Copyright © 2016年 JXHDev. All rights reserved.
//

#import "XHDDOnlineChatDetailController.h"
#import "XHDDOnlineChatMessageCell.h"
#import "EMSDKFull.h"
#import "Entity+CoreDataProperties.h"

@interface XHDDOnlineChatDetailController ()<UITableViewDataSource,UITableViewDelegate,EMChatManagerDelegate>
{
    //CoreDada中管理数据的上下文，做增删改查需要使用到
    NSManagedObjectContext *_managedObjectContext;

}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewLayoutBottom;

/**
 *  当前会话
 */
@property (nonatomic, strong) EMConversation *currentConversation;

@property (weak, nonatomic) IBOutlet UITableView *chatContentTableView;
@property (weak, nonatomic) IBOutlet UITextView *inputMessageTextView;
@property (weak, nonatomic) IBOutlet UIButton *soundInputView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
- (IBAction)sendBtn:(UIButton *)sender;
- (IBAction)emoticonBtn:(UIButton *)sender;
/**
 *  messageArray
 */
@property (nonatomic, strong) NSMutableArray *messagesArray;

@end

@implementation XHDDOnlineChatDetailController
- (EMConversation *)currentConversation{
    
    if (_currentConversation == nil) {
        
       self.currentConversation = [[EMClient sharedClient].chatManager getConversation:self.navigationItem.title type:EMConversationTypeChat createIfNotExist:YES];
    }
    return _currentConversation;
}
- (NSMutableArray *)messagesArray{

    if (_messagesArray == nil) {
        
        self.messagesArray = [NSMutableArray array];
    }
    
    return _messagesArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JRandomColor;
    self.chatContentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.inputMessageTextView.layer.cornerRadius = 4;
    self.inputMessageTextView.layer.masksToBounds = YES;

    //0.配置环境
    [self configEnvironment];
    
    //1.添加键盘监听
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //2.添加点击监听
    [self.chatContentTableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignInput)]];
    
    //3.获取当前会话的历史
//    [self getLastMessageFromDB];
    
}
- (void)resignInput{

    if (self.inputMessageTextView.isFirstResponder) {
        
        [self.view endEditing:YES];
    }
}
#pragma mark - coreData
- (void)configEnvironment{
    
    //1.获取路径;编译后类型会变成mode; 根据路径加载文件中所有的模型
    NSString *momdPath = [[NSBundle mainBundle] pathForResource:@"HistoryMessageModel" ofType:@"momd"];
    NSManagedObjectModel *managedModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:momdPath]];
    
    //2.创建持久化存储协调器（相当于数据库和文件的连接器）
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedModel];
    
    //3.指定数据库的存储路径
    NSString *savaPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/historyMessageInfo.sqlist"];
    
    //4.设置路径
    NSPersistentStore *sotre = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:savaPath] options:nil error:nil];
    
    //5.创建托管上下文
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    //6.关联协调器
    _managedObjectContext.persistentStoreCoordinator = coordinator;
    
    //创建保存数据的数组
    
    //执行一次查询，取出之前的本地化数据
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"HistoryMessageEntity"];
    NSArray *results = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
   
#warning 第一次如何查找并显示历史。
    for (int i = 0; i < results.count; i ++) {
       
        Entity *entityModel = results[i];
        
        NSString *name = entityModel.name;
        
        
        if (![name isEqualToString:[NSString stringWithFormat:@"%@/%@",[EMClient sharedClient].currentUsername,self.navigationItem.title]]) {//(非)自己与某某
            continue;
        }
        
        //自己与某某
        NSString *time = entityModel.time;
        NSString *text = entityModel.message;
        BOOL type =  [entityModel.type boolValue];
        
        //取出用户名
        NSString *userName ;
        if (type) {//来自他人
            userName =[[name componentsSeparatedByString:@"/"] lastObject];
            
        }else{
            userName =[[name componentsSeparatedByString:@"/"] firstObject];
        }
        NSDictionary *dict = @{@"text":text,@"time":time,@"type":@(type),@"name":userName};
       
        XHDDOnlineChatMessageModel *model = [XHDDOnlineChatMessageModel messageWithDict:dict];
        [self.messagesArray addObject:model];
        
    }
    //刷新数据
    [self.chatContentTableView reloadData];
    [self setSendOrReceiveMessageTableViewScroll];
}
#pragma mark - 发送消息处理
//获取当前对话时间字符串
- (NSString *)getCurrentSystemTimeStr{
    //获取当前时间
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss"];
    
    NSDate *date = [NSDate date];
    NSString *time = [df stringFromDate:date];
    
    return time;
}
//创建消息对象
- (XHDDOnlineChatMessageModel *)createMessageWithMessageText:(NSString *)messageText andIsFromOther:(BOOL)fromOther{

    NSString *time = [self getCurrentSystemTimeStr];
    
    NSString *name = [EMClient sharedClient].currentUsername;//自己发送
    
    if (fromOther) {//来自他人的模型
        name = self.navigationItem.title;
    }
    
    NSDictionary *dict = @{@"text":messageText,@"time":time,@"type":@(fromOther),@"name":name};
    XHDDOnlineChatMessageModel *message = [XHDDOnlineChatMessageModel messageWithDict:dict];

    return message;
}
//发送btn点击响应
- (IBAction)sendBtn:(UIButton *)sender {
    
    NSString *messageText = self.inputMessageTextView.text;
    XHDDOnlineChatMessageModel *message = [self createMessageWithMessageText:messageText andIsFromOther:NO];
    
    //1.向服务器发送
    [self sendMessageToFriend:message];
    //2.添加数据
    [self.messagesArray addObject:message];
    //3.刷新数据
    [self.chatContentTableView reloadData];
    //4.清空textField
    self.inputMessageTextView.text = @"";
    
    //5.设置滚动到底部
    [self setSendOrReceiveMessageTableViewScroll];
}
//设置滚动到底部
- (void)setSendOrReceiveMessageTableViewScroll{
   
    if (self.messagesArray.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messagesArray.count - 1 inSection:0];
        [self.chatContentTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
#pragma mark - 发送消息给对方
- (void)sendMessageToFriend:(XHDDOnlineChatMessageModel *)messageModel{

    //1.包装消息
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:messageModel.text];
    NSString *from = [[EMClient sharedClient] currentUsername];//自己的账号
    NSString *friendID = self.navigationItem.title;
    
    NSDictionary *messageDict = @{@"text":messageModel.text,@"time":messageModel.time,@"type":@(messageModel.type),@"name":messageModel.name};
    
    //生成Message
    EMMessage *message = [[EMMessage alloc] initWithConversationID:friendID from:from to:friendID body:body ext:messageDict];
    
    message.chatType = EMChatTypeChat;// 设置为单聊消息
    
    //2.发送消息:异步
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:^(int progress) {
        
        JLog(@"发送进度%d",progress);
        
    } completion:^(EMMessage *messageBody, EMError *error) {
       
        if (!error) {
            
            JLog(@"发送消息成功");

            //添加到数据库
            //创建一个实体
            Entity *messageEntity = (Entity *)[NSEntityDescription insertNewObjectForEntityForName:@"HistoryMessageEntity" inManagedObjectContext:_managedObjectContext];
            
            //实体赋值
            messageEntity.name = [NSString stringWithFormat:@"%@/%@",[EMClient sharedClient].currentUsername,self.navigationItem.title];
            messageEntity.message = messageModel.text;
            messageEntity.time = messageModel.time;
            messageEntity.type = @(messageModel.type);
          
            //实体保存
            if ([_managedObjectContext save:nil]){
            
                NSLog(@"保存实体成功");
            }
            
        }
        else {
            
            EMTextMessageBody *textBody = (EMTextMessageBody *)messageBody.body;
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"消息：%@ 发送失败",textBody.text]];
            
            XHDDOnlineChatMessageModel *model = [self createMessageWithMessageText:messageDict[@"text"] andIsFromOther:NO];
            //从本地删除
            [self.messagesArray removeObject:model];
            //刷新tableView
            [self.chatContentTableView reloadData];
        }

    }];
    
}
- (IBAction)emoticonBtn:(UIButton *)sender {
    
    JLog(@"点击了表情");
}
#pragma mark - tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self.messagesArray[indexPath.row] rowHeight];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.messagesArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XHDDOnlineChatMessageCell *cell = [XHDDOnlineChatMessageCell messageCellWithTableView:tableView];
    
    cell.message = self.messagesArray[indexPath.row];
    
    return cell;
    
}
#pragma mark - 输入滚动相关
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}
#pragma mark - 键盘监听frame改变
- (void)keyboardChange:(NSNotification *)notification{
    
    NSDictionary *infoDict = notification.userInfo;
    //取出结束时的键盘坐标
    CGRect keyboardRect = [infoDict[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //计算移动的距离
    CGFloat distanceY = JScreenHeight - keyboardRect.origin.y;
    
    self.bottomViewLayoutBottom.constant = distanceY;
    //更改约束
    [UIView animateWithDuration:0.25 animations:^{
       
        [self.bottomView layoutIfNeeded];
        [self.chatContentTableView layoutIfNeeded];
       
    }];
    
    
}
- (void)dealloc{
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 设置消息回调代理
- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];

}
- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    
    //移除消息回调
    [[EMClient sharedClient].chatManager removeDelegate:self];
}
#pragma mark - 解析消息回调
- (void)didReceiveMessages:(NSArray *)aMessages{
   
    for (EMMessage *message in aMessages) {
        // cmd消息中的扩展属性
        NSDictionary *ext = message.ext;

        
       XHDDOnlineChatMessageModel *model = [self createMessageWithMessageText:ext[@"text"] andIsFromOther:YES];
        
        //创建一个实体
        Entity *messageEntity = (Entity *)[NSEntityDescription insertNewObjectForEntityForName:@"HistoryMessageEntity" inManagedObjectContext:_managedObjectContext];
        
        //实体赋值
        messageEntity.name = [NSString stringWithFormat:@"%@/%@",[EMClient sharedClient].currentUsername, self.navigationItem.title];
        messageEntity.message = model.text;
        messageEntity.time = model.time;
        messageEntity.type = @(YES);
        
        //实体保存
        if ([_managedObjectContext save:nil]){
            
            NSLog(@"保存实体成功");
        }
        
        [self.messagesArray addObject:model];
        [self.chatContentTableView reloadData];
        //设置滚动到底部
        [self setSendOrReceiveMessageTableViewScroll];
        
    }
}
#pragma mark - 首次进入，本地数据库取出最新20条数据
//- (EMMessage *)loadMessageWithId:(NSString *)aMessageId{
//
//    
//}
//- (void)getLastMessageFromDB{
//
//    NSArray *historyMessageArray = [self.currentConversation loadMoreMessagesFromId:self.navigationItem.title limit:10];
//    
//    for (EMMessage *message in historyMessageArray) {//0x00007fdc10e18f20  //0x00007fdc13a4f130
//        // cmd消息中的扩展属性
//        NSDictionary *ext = message.ext;
//        XHDDOnlineChatMessageModel *model = [XHDDOnlineChatMessageModel messageWithDict:ext];
//        [self.messagesArray addObject:model];
//    }
//    //如果有历史数据
//    if (self.messagesArray.count > 0) {
//        [self.chatContentTableView reloadData];
//        //设置滚动到底部
//        [self setSendOrReceiveMessageTableViewScroll];
//    }
//    
//}

@end
