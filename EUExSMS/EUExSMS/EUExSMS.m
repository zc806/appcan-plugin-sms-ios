//
//  EUExSMS.m
//  WebKitCorePlam
//
//  Created by AppCan on 11-8-27.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "EUExSMS.h"
#import "EUtility.h"
#import "EUExBaseDefine.h"

@implementation EUExSMS
-(id)initWithBrwView:(EBrowserView *) eInBrwView {
	if (self = [super initWithBrwView:eInBrwView]) {
	}
	return self;
}

-(void)dealloc{
	[super dealloc];
}

-(void) displaySMSWithArgs:(NSArray *)photoNumArray content:(NSString *)content{
	MFMessageComposeViewController*picker = [[MFMessageComposeViewController alloc] init];
	picker.messageComposeDelegate= self;
	picker.navigationBar.tintColor= [UIColor blackColor];
    // 默认信息内容
	// 默认收件人(可多个)
    if (content&&[content length]>0) {
        picker.body = content;
    }
    if ([photoNumArray isKindOfClass:[NSArray class]] && [photoNumArray count]>0) {
        picker.recipients = photoNumArray;
    }
	[EUtility brwView:meBrwView presentModalViewController:picker animated:NO];
    [picker release];
}

- (void) alertWithTitle:(NSString *)title msg:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
												    message:msg
												   delegate:nil
										  cancelButtonTitle:@"确定"
										  otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)picker
				 didFinishWithResult:(MessageComposeResult)result {
	NSString*msg;
	switch (result) {
		case MessageComposeResultCancelled:
			msg = @"发送取消";
			break;
		case MessageComposeResultSent:
			msg = @"发送成功";
			//[self alertWithTitle:nil msg:msg];
			break;
		case MessageComposeResultFailed:
			msg = @"发送失败";
			//[euexObj jsFailedWithOpId:0 errorCode:152 errorDes:@"发送失败"];
			break;
		default:
			break;
	}
	[picker dismissModalViewControllerAnimated:YES];
}

-(void)open:(NSMutableArray *)inArguments {
	NSArray *photoNumArray = nil;
    NSString *phoneNum = [inArguments objectAtIndex:0];
    if ([phoneNum isKindOfClass:[NSString class]] && phoneNum.length>0) {
        photoNumArray = [phoneNum componentsSeparatedByString:@","];
    }
	NSString *content = [inArguments objectAtIndex:1];
	//判断是不是ipod，ipod不能发送短信，判断是不是ios4.0以上的版本，如果不是的话就不能在程序内发送短信
	if ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"]) {
		[self jsFailedWithOpId:0 errorCode:1180108 errorDes:UEX_ERROR_DESCRIBE_DEVICE_SUPPORT];
		return;
	}
	if ([[[UIDevice currentDevice] systemVersion] floatValue]<4.0) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",[photoNumArray description]]]];
        
	}else {
        //启动发短信的view，在程序内发送短信
        Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
        PluginLog(@"can send SMS [%d]", [messageClass canSendText]);
        
        if (messageClass != nil) {
            if ([messageClass canSendText]) {
                [self displaySMSWithArgs:photoNumArray content:content];
            } else {
                [super jsFailedWithOpId:0 errorCode:1180108 errorDes:UEX_ERROR_DESCRIBE_DEVICE_SUPPORT];
            }
        } else {
            [super jsFailedWithOpId:0 errorCode:1180108 errorDes:UEX_ERROR_DESCRIBE_DEVICE_SUPPORT];
        }
	}
}

-(void)send:(NSMutableArray *)inArguments{
	[self open:inArguments];
}

@end
