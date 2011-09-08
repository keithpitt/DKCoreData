//
//  DKDataImporterSpec.m
//  DiscoKit
//
//  Created by Keith Pitt on 30/06/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "SpecHelper.h"

#import "DKCoreDataImporter.h"

#import "DKFile.h"
#import "FGSpecImportableUser.h"

#import "FGSpecProfile.h"
#import "FGSpecUser.h"
#import "FGSpecComment.h"

SPEC_BEGIN(DKDataImporterSpec)

describe(@"DKDataImporter", ^{
    
    __block NSArray * users;
    
    beforeEach(^{
        
        users = [DKFile jsonFromBundle:nil pathForResource:@"ImportableUsers"];
        
        [FGSpecImportableUser destroyAll];
        
    });
    
    it(@"should create records during import", ^{
        
        [DKCoreDataImporter import:^(DKCoreDataImporter * importer) {
            
            [importer import:users];
            
        } completion: ^{
            
            int count = [[FGSpecImportableUser query] count];
            expect(count).toEqual(360);
            
        } background:NO];
        
    });
    
    it(@"should update records during import", ^{
            
        [DKCoreDataImporter import:^(DKCoreDataImporter * importer) {
        
            // First round of importing creates new users
            [importer import:users];
            
            // Second round should update
            [importer import:users];
            
        } background:NO];
        
        int count = [[FGSpecImportableUser query] count];
        expect(count).toEqual(360);
        
    });
    
    it(@"should update the correct records during import", ^{
        
        NSArray * usersWithNameKeithPitt = [DKFile jsonFromBundle:nil pathForResource:@"UsersWithNameKeithPitt"];
        NSArray * usersWithNameKeithPitty = [DKFile jsonFromBundle:nil pathForResource:@"UsersWithNameKeithPitty"];
        
        [DKCoreDataImporter import:^(DKCoreDataImporter * importer) {
            
            // First round of importing creates new users
            [importer import:usersWithNameKeithPitt];
            
            FGSpecUser * user = [FGSpecUser find:[NSNumber numberWithInt:5]];
            
            NSManagedObjectID * userID = user.objectID;
            
            [importer import:usersWithNameKeithPitty];
            
            FGSpecUser * updatedUser = [FGSpecUser find:[NSNumber numberWithInt:5]];
            
            expect(updatedUser.lastName).toEqual(@"Pitty");
            expect(updatedUser.identifier).toEqual(user.identifier);
            expect(updatedUser.objectID).toEqual(userID);
            
        } background:NO];        
        
        
    });

    it(@"should import an odd number of records", ^{
        
        [FGSpecUser destroyAll];
        
        NSArray * oddNumberOfUsers = [DKFile jsonFromBundle:nil pathForResource:@"OddNumberOfUsers"];
        
        [DKCoreDataImporter import:^(DKCoreDataImporter * importer) {
            
            // First round of importing creates new users
            [importer import:oddNumberOfUsers];
            
        } background:NO];
        
        int count = [[FGSpecUser query] count];
        expect(count).toEqual(223);
        
    });
    
    it(@"should call -afterImport on users", ^{
        
        [DKCoreDataImporter import:^(DKCoreDataImporter * importer) {
            
            // Second round should update
            [importer import:users];
            
        } completion: ^{
            
            FGSpecImportableUser * user = [[[FGSpecImportableUser query] results] lastObject];
            
            expect(user.password).toEqual(@"afterImport");
            
        } background:NO];
        
    });
   
    it(@"should import asynchronously", ^{
        
        __block BOOL completed = NO;
        
        [DKCoreDataImporter import:^(DKCoreDataImporter * importer) {
            
            [importer import:users];
            
            completed = YES;
            
        } background:YES];
        
        while(!completed)
            [NSThread sleepForTimeInterval:0.1];
        
        int count = [[FGSpecImportableUser query] count];
        expect(count).toEqual(360);
        
    });
    
    it(@"should return false if the JSON format is invalid", ^{
        
        NSArray * cafes = [DKFile jsonFromBundle:nil pathForResource:@"InvalidCafesFormat"];
        
        [DKCoreDataImporter import:^(DKCoreDataImporter * importer) {
            expect([importer import:cafes]).toBeFalsy();
        } background:NO];
        
    });
    
    it(@"should return false if the records have no ID", ^{
        
        NSArray * cafes = [DKFile jsonFromBundle:nil pathForResource:@"UsersWithNoIdentifiers"];
        
        [DKCoreDataImporter import:^(DKCoreDataImporter * importer) {
            expect([importer import:cafes]).toBeFalsy();
        } background:NO];
        
    });
    
    it(@"should return false if the entity doens't exist", ^{
        
        NSArray * cafes = [DKFile jsonFromBundle:nil pathForResource:@"NonExistantModel"];
        
        [DKCoreDataImporter import:^(DKCoreDataImporter * importer) {
            expect([importer import:cafes]).toBeFalsy();
        } background:NO];
        
    });
    
    it(@"should import has many relationships", ^{
        
        [FGSpecUser destroyAll];
        [FGSpecComment destroyAll];
        
        NSArray * usersWithComments = [DKFile jsonFromBundle:nil pathForResource:@"UsersWithComments"];
        
        [DKCoreDataImporter import:^(DKCoreDataImporter * importer) {
            
            expect([importer import:usersWithComments]).toBeTruthy();
            
        } completion: ^{
            
            int usersCount = [[FGSpecUser query] count];
            expect(usersCount).toEqual(100);
            
            int commentsCount = [[FGSpecComment query] count];
            expect(commentsCount).toEqual(200);
            
        } background:NO];
        
    });
  
    it(@"should import nested has many relationships", ^{
       
        [FGSpecProfile destroyAll];
        [FGSpecUser destroyAll];
        [FGSpecComment destroyAll];
        
        NSArray * profileWithUserAndComments = [DKFile jsonFromBundle:nil pathForResource:@"ProfileWithUserAndComments"];
        
        [DKCoreDataImporter import:^(DKCoreDataImporter * importer) {
            
            expect([importer import:profileWithUserAndComments]).toBeTruthy();
            
        } completion: ^{
            
            int profileCount = [[FGSpecProfile query] count];
            expect(profileCount).toEqual(1);
            
            int usersCount = [[FGSpecUser query] count];
            expect(usersCount).toEqual(1);
            
            int commentsCount = [[FGSpecComment query] count];
            expect(commentsCount).toEqual(2);
            
        } background:NO];
        
    });
         
});

SPEC_END