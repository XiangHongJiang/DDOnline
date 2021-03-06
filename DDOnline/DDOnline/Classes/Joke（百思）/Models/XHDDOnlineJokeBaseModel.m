//
//  XHDDOnlineJokeBaseModel.m
//  DDOnline
//
//  Created by qianfeng on 16/3/13.
//  Copyright (c) 2016年 JXHDev. All rights reserved.
//

#import "XHDDOnlineJokeBaseModel.h"

@implementation XHDDOnlineJokeBaseModel


+ (NSDictionary *)objectClassInArray{
    return @{@"list" : [JokeBase_List class]};
}

@end
@implementation JokeBase_Info

@end


@implementation JokeBase_List

+ (NSDictionary *)objectClassInArray{
    return @{@"tags" : [JokeBase_Tags class]};
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    
    return @{@"ID":@"id"};
}
//textHeight
- (void)setText:(NSString *)text{

    _text = text;
    
    self.textHeight =[XHUtils calculateSizeWithText:text maxSize:CGSizeMake(JScreenWidth - 10, CGFLOAT_MAX) font:15].height;
    
}
//imageHeight
- (void)setImage:(JokeGF_Image *)image{

    _image = image;
    
    CGFloat rat = image.width * 1.0 / (JScreenWidth - JPedding);

    CGFloat height = image.height / rat;
    
    if (height > JScreenHeight * 0.8) {
     
        height = JScreenHeight * 0.8;
    }
    
    self.gifImageHeight = height;
    
}
//gifHeight
- (void)setGif:(JokeGF_Gif *)gif{
    _gif = gif;
    
    CGFloat rat = gif.width * 1.0 / (JScreenWidth - JPedding);
    
    CGFloat height = gif.height / rat;
    
    if (height > JScreenHeight * 0.8) {
        
        height = JScreenHeight * 0.8;
    }
    
    self.gifImageHeight = height;
}
//videoHeight
- (void)setVideo:(JokeVideo_Video *)video{

    _video = video;
    
    CGFloat rat = video.width * 1.0 / (JScreenWidth - JPedding);
    
    CGFloat height = video.height / rat;
    
    if (height > JScreenHeight * 0.75) {
        
        height = JScreenHeight * 0.75;
    }
    
    self.videoImageHeight = height;
}

@end


@implementation JokeBase_U

@end


@implementation JokeBase_Tags

+ (NSDictionary *)mj_replacedKeyFromPropertyName{

    return @{@"ID":@"id"};
}

@end


//video
@implementation JokeVideo_Video

@end
//gif
@implementation JokeGF_Gif


@end
//gif
@implementation JokeGF_Image

@end

