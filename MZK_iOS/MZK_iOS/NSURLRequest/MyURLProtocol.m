//
//  MyURLProtocol.m
//  NSURLProtocolExample
//
//  Created by Rocir Marcos Leite Santiago on 11/29/13.
//  Copyright (c) 2013 Rocir Santiago. All rights reserved.
//

#import "MyURLProtocol.h"

// AppDelegate
#import "AppDelegate.h"


static NSString * const MyURLProtocolHandledKey = @"MyURLProtocolHandledKey";

@interface MyURLProtocol () <NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) NSURLResponse *response;

@end

@implementation MyURLProtocol

//+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
//    
//    if ([NSURLProtocol propertyForKey:MyURLProtocolHandledKey inRequest:request]) {
//        return NO;
//    }
//    
//    return YES;
//}
//
//+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
//    return request;
//}
//
//- (void) startLoading {
//    
//    CachedURLResponse *cachedResponse = [self cachedResponseForCurrentRequest];
//    if (cachedResponse) {
//        
//        NSData *data = cachedResponse.data;
//        NSString *mimeType = cachedResponse.mimeType;
//        NSString *encoding = cachedResponse.encoding;
//        
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:self.request.URL
//                                                            MIMEType:mimeType
//                                               expectedContentLength:data.length
//                                                    textEncodingName:encoding];
//        
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        [self.client URLProtocol:self didLoadData:data];
//        [self.client URLProtocolDidFinishLoading:self];
//        
//    } else {
//        
//        NSMutableURLRequest *newRequest = [self.request mutableCopy];
//        [NSURLProtocol setProperty:@YES forKey:MyURLProtocolHandledKey inRequest:newRequest];
//        
//        self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
//        
//    }
//    
//}

- (void) stopLoading {
    
    [self.connection cancel];
    self.mutableData = nil;
    
}

#pragma mark - NSURLConnectionDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    self.response = response;
    self.mutableData = [[NSMutableData alloc] init];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    
    [self.mutableData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

#pragma mark - Private
@end
