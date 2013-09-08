//
//  IDEIndexCompletionStrategy+KFCocoaPods.m
//  KFCocoaPodsPlugin
//
//  Copyright (c) 2013 Rico Becker, KF Interactive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "DVTTextCompletionWordsInFileStrategy+KFCocoaPods.h"
#import "MethodSwizzle.h"
#import "KFCocoaPodsPlugin.h"


@implementation DVTTextCompletionWordsInFileStrategy (KFCocoaPods)


+ (void)load
{
    MethodSwizzle(self, @selector(completionItemsForDocumentLocation:context:areDefinitive:), @selector(swizzle_completionItemsForDocumentLocation:context:areDefinitive:));
}

- (id)swizzle_completionItemsForDocumentLocation:(id)arg1 context:(id)arg2 areDefinitive:(char *)arg3
{
    id items = [self swizzle_completionItemsForDocumentLocation:arg1 context:arg2 areDefinitive:arg3];
    @try
    {
        DVTSourceCodeLanguage *sourceCodeLanguage = [arg2 valueForKey:@"DVTTextCompletionContextSourceCodeLanguage"];
        
        if ([sourceCodeLanguage.identifier isEqualToString:@"Xcode.SourceCodeLanguage.Ruby"])
        {
            DVTSourceTextView *sourceTextView = [arg2 objectForKey:@"DVTTextCompletionContextTextView"];
            DVTTextStorage *textStorage = [arg2 valueForKey:@"DVTTextCompletionContextTextStorage"];
            NSRange selectedRange = [sourceTextView selectedRange];
            
            NSString *string = [textStorage string];
            NSRange itemRange = NSMakeRange(0, selectedRange.location);
            NSString *itemString = [string substringWithRange:itemRange];
            
            NSRange newlineRange = [itemString rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
            
            if (newlineRange.location != NSNotFound)
            {
                itemRange.length = itemRange.length - newlineRange.location;
                itemRange.location = itemRange.location + newlineRange.location;
                
                if (itemRange.length < [string length] && NSMaxRange(itemRange) < [string length])
                {
                    itemString = [string substringWithRange:itemRange];
                }
            }
            
            if ([[itemString lowercaseString] hasSuffix:@"pod "])
            {
                items = [[KFCocoaPodsPlugin sharedPlugin] autoCompletionItems];
            }
        }
    }
    @catch (NSException *exception)
    {
        
    }
    
    return items;
}
    
    
@end
