//
//  PresentMusicViewControllerProtocol.h
//  MZK_iOS
//
//  Created by Ondrej Vyhlidal on 09/03/2019.
//  Copyright © 2019 Ondrej Vyhlidal. All rights reserved.
//

#ifndef PresentMusicViewControllerProtocol_h
#define PresentMusicViewControllerProtocol_h

@protocol PresentMusicViewControllerProtocol <NSObject>

- (void)presentMusicViewController:(MusicViewController *)controller withItem:(NSString *)item;

@end


#endif /* PresentMusicViewControllerProtocol_h */
