//
//  ZawgyiSegmentationHelper.m
//  Pods
//
//  Created by Khant Thu Linn on 13/6/16.
//
//

#import "ZawgyiSegmentationHelper.h"

#pragma mark - Preparation 

#define MYANMAR_CONSONANTS @[ @"က", @"ခ", @"ဂ", @"ဃ", @"င", @"စ", @"ဆ", @"ဇ", @"စ်", @"ည", @"ဋ", @"ဌ", @"ဍ", @"ဎ", @"ဏ", @"တ", @"ထ", @"ဒ", @"ဓ", @"န", @"ပ", @"ဖ", @"ဗ", @"ဘ", @"မ", @"ယ", @"ရ", @"လ", @"၀", @"သ", @"ဟ", @"႒", @"အ"]

#define STARTING_WORD @[ @"က", @"ခ", @"ဂ", @"ဃ", @"င", @"စ", @"ဆ", @"ဇ", @"စ်", @"ည", @"ဋ", @"ဌ", @"ဍ", @"ဎ", @"ဏ", @"တ", @"ထ", @"ဒ", @"ဓ", @"န", @"ပ", @"ဖ", @"ဗ", @"ဘ", @"မ", @"ယ", @"ရ", @"လ", @"၀", @"ဝ", @"သ", @"ဟ", @"႒", @"အ", @"ေ", @"ႀ", @"ၿ", @"ၾ", @"ျ", @"ႂ", @"ႁ", @"ႄ", @"ႃ", @"ဥ", @" @", @"ႏ", @"၍", @"ဤ", @"၏", @"႐", @"ၫ", @"ႆ", @"ၪ", @"ဉ", @"၌", @"ဧ", @"႗", @"ၮ", @"ၯ", @"႑", @"၎", @"ဣ", @"ဩ", @"ဪ", @"ဦ", @"။", @"၊", @"“", @"”", @"[", @"]", @",", @".", @"+", @"-", @" X @", @"/", @"=", @"%", @"၁", @"၂", @"၃", @"၄", @"၅", @"၆", @"၇", @"၈", @"၉", @"၀" ]


@implementation ZawgyiSegmentationHelper


+ (NSArray *)convertZawgyiSentence:(NSString *)inputStr {
    
    inputStr = [NSString stringWithFormat:@"%@။ ",inputStr]; //To solve later instead of putting ။
    NSInteger count = inputStr.length;
    
    NSMutableArray *keeptemporyword = [NSMutableArray array];
    
    for (NSInteger idx = 0; idx < inputStr.length; idx++) {
        [keeptemporyword addObject:[NSString stringWithFormat:@"%C", [inputStr characterAtIndex:idx]]];
    }
    
    Boolean booleancheck = true;
    NSUInteger check10, check20 = 0;
    NSString *stringtesting = @"";
    NSString *stringall = @"";
   
   
    for (NSUInteger testingcount = 0; testingcount < count; testingcount++)
    {
        
        for (NSUInteger testingcount1 = 0; testingcount1 < STARTING_WORD.count; testingcount1++)
        {
            
            if ([keeptemporyword[testingcount] isEqualToString:STARTING_WORD[testingcount1]] && booleancheck == false)
            {
                @try {
                    if ([keeptemporyword[testingcount + 1] isEqualToString:@"ၭ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၬ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၥ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၠ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၸ"]|| [keeptemporyword[testingcount + 1] isEqualToString:@"ၼ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"႖"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၱ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၲ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၦ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၧ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၺ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၵ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၶ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၻ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ႅ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၡ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၣ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၳ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၴ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၹ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၨ"])
                    {
                        
                    }
                    else if ([keeptemporyword[testingcount + 1]  isEqualToString:@"္"] || [keeptemporyword[testingcount + 1]  isEqualToString:@"ၤ"])
                    {
                        
                        @try {
                            if ([keeptemporyword[testingcount + 2] isEqualToString:@"်"]  && [keeptemporyword[testingcount + 3] isEqualToString:@"ာ"] &&  [keeptemporyword[testingcount + 4] isEqualToString:@"း"])
                            {
                                /*this will catch the word "yout kyar"*/
                            }
                            else if ([keeptemporyword[testingcount + 1 + 1] isEqualToString:@"း"] || [keeptemporyword[testingcount + 1 + 1] isEqualToString:@"႔"] || [keeptemporyword[testingcount + 1 + 1] isEqualToString:@"႕"]  || [keeptemporyword[testingcount + 1 + 1] isEqualToString:@"့"])
                            {
                                check20 = testingcount + 2;
                                for (NSUInteger checking = check10; checking <= check20; checking++)
                                {
                                    stringtesting = [NSString stringWithFormat:@"%@%@", stringtesting, keeptemporyword[checking]];
                                }
                                
                                stringall = [NSString stringWithFormat:@"%@%@%@", stringall, stringtesting, @"/"];
                                
                                
                                booleancheck = true;
                                stringtesting = @"";
                                testingcount = testingcount + 2;
                            }
                            else
                            {
                                
                                check20 = testingcount + 1;
                                for (NSUInteger checking = check10; checking <= check20; checking++)
                                {
                                    stringtesting = [NSString stringWithFormat:@"%@%@", stringtesting, keeptemporyword[checking]];
                                }
                                
                                stringall = [NSString stringWithFormat:@"%@%@%@", stringall, stringtesting, @"/"];
                                
                                booleancheck = true;
                                stringtesting = @"";
                                testingcount++;
                            }
                        } @catch (NSException *exception) {
                            
                            check20 = testingcount + 1;
                            for (NSUInteger checking = check10; checking <= check20; checking++)
                            {
                                stringtesting = [NSString stringWithFormat:@"%@%@", stringtesting, keeptemporyword[checking]];
                            }
                            
                            
                            stringall = [NSString stringWithFormat:@"%@%@%@", stringall, stringtesting, @"/"];
                            
                            booleancheck = true;
                            stringtesting = @"";
                            testingcount++;
                        }
                        
                        
                    }  //if (keeptemporyword[testingcount+1] == "္")
                    
                    else
                    {   //this will catch plain word..let say ka kyi..kha khway...without "a thet"...like "ka thet in "yout" kyar"...
                        
                        check20 = testingcount;
                        for (NSUInteger checking = check10; checking < check20; checking++)
                        {
                            stringtesting = [NSString stringWithFormat:@"%@%@", stringtesting, keeptemporyword[checking]];
                        }
                        
                        stringall = [NSString stringWithFormat:@"%@%@%@", stringall, stringtesting, @"/"];
                        
                        booleancheck = true;
                        //  check10 = 0;// check20 = 0;
                        stringtesting = @"";
                        
                    }
                } @catch (NSException *exception) {
                    //consider to use space seperator all the way above.
                    check20 = keeptemporyword.count ;
                    for (NSUInteger item = check10; item < check20; item++)
                    {
                        stringtesting = [NSString stringWithFormat:@"%@%@", stringtesting, keeptemporyword[item]];
                    }
                    
                    stringall = [NSString stringWithFormat:@"%@%@", stringtesting, @"/"];
                } @finally {
                    
                }
                
                
                
            }
            
            
            if ([keeptemporyword[testingcount] isEqualToString:STARTING_WORD[testingcount1]] && booleancheck == true)
            {
                
                if ([keeptemporyword[testingcount] isEqualToString:@"ေ"] || [keeptemporyword[testingcount] isEqualToString:@"ႀ"] || [keeptemporyword[testingcount] isEqualToString:@"ၿ"] || [keeptemporyword[testingcount] isEqualToString:@"ၾ"] || [keeptemporyword[testingcount] isEqualToString:@"ျ"] || [keeptemporyword[testingcount] isEqualToString:@"ႂ"] || [keeptemporyword[testingcount] isEqualToString:@"ႁ"] || [keeptemporyword[testingcount] isEqualToString:@"ႄ"] || [keeptemporyword[testingcount] isEqualToString:@"ႃ"])
                {
                    if ([keeptemporyword[testingcount] isEqualToString:@"ေ"])
                    {
                        if ([keeptemporyword[testingcount + 1] isEqualToString:@"ႀ"] || [keeptemporyword[testingcount + 1] isEqualToString:@"ၿ"] ||
                            [keeptemporyword[testingcount + 1] isEqualToString:@"ၾ"] ||
                            [keeptemporyword[testingcount + 1] isEqualToString:@"ျ"] ||
                            [keeptemporyword[testingcount + 1] isEqualToString:@"ႂ"] ||
                            [keeptemporyword[testingcount + 1] isEqualToString:@"ႁ"] ||
                            [keeptemporyword[testingcount + 1] isEqualToString:@"ႄ"] ||
                            [keeptemporyword[testingcount + 1] isEqualToString:@"ႃ"])
                        {
                            booleancheck = false;
                            check10 = testingcount;
                            testingcount = testingcount+2;
                        }
                        else
                        {
                            booleancheck = false;
                            check10 = testingcount;
                            testingcount++;
                        }
                    }
                    else
                    {
                        booleancheck = false;
                        check10 = testingcount;
                        testingcount++;
                    }
                    
                }
                else
                {
                    booleancheck = false;
                    check10 = testingcount;
                }
            }
            
            
        }
    }
    
    NSArray *arr = [stringall componentsSeparatedByString:@"/"];
    NSMutableArray *finalMu = [NSMutableArray array];
    for (NSString *str in arr) {
        if (str.length > 0)
            [finalMu addObject:str];
    }
    
    return finalMu;
}

@end
