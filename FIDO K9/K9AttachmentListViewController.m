//
//  K9AttachmentListViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/12/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9AttachmentListViewController.h"
#import "K9Attachment.h"
#import "K9ObjectGraph.h"

@interface K9AttachmentListViewController ()

@property (readonly) NSArray *extraPossibleAttachments;

@end

@implementation K9AttachmentListViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.possibleAttachments = [[K9ObjectGraph sharedObjectGraph] allAttachments];
    
    // Since the table view has such a light background, we shouldn't use yellow for the checkmarks.
    // If this ever gets a dark theme, we should respect the inherited tint color
    [[self view] setTintColor:[UIColor blackColor]];
}

- (void)setPossibleAttachments:(NSArray *)possibleAttachments {
    if(_possibleAttachments != possibleAttachments && ![_possibleAttachments isEqualToArray:possibleAttachments]) {
        _possibleAttachments = possibleAttachments;
        [[self tableView] reloadData];
    }
}

- (void)setAttachments:(NSArray *)attachments {
    if(_attachments != attachments && ![_attachments isEqualToArray:attachments]) {
        _attachments = attachments;
        [[self tableView] reloadData];
    }
}

- (NSArray *)extraPossibleAttachments {
    NSMutableArray *extraPossibleAttachments = [_possibleAttachments mutableCopy];
    [extraPossibleAttachments removeObjectsInArray:self.attachments];
    return extraPossibleAttachments;
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.attachments.count + self.extraPossibleAttachments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attachmentTableCell" forIndexPath:indexPath];
    
    
    K9Attachment *attachment = nil;
    BOOL isAttached = NO;
    
    if(indexPath.row < self.attachments.count) {
        attachment = [self.attachments objectAtIndex:indexPath.row];
        isAttached = YES;
    } else {
        attachment = [self.extraPossibleAttachments objectAtIndex:(indexPath.row - self.attachments.count)];
    }
    
    cell.textLabel.text = attachment.name;
    cell.detailTextLabel.text = attachment.attachmentDescription;
    cell.accessoryType = isAttached ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

@end
