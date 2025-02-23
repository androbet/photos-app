import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:photos/models/file/file_type.dart';
import 'package:photos/models/subscription.dart';

class UserDetails {
  final String email;
  final int usage;
  final int fileCount;
  final int storageBonus;
  final int sharedCollectionsCount;
  final Subscription subscription;
  final FamilyData? familyData;
  final ProfileData? profileData;

  const UserDetails(
    this.email,
    this.usage,
    this.fileCount,
    this.storageBonus,
    this.sharedCollectionsCount,
    this.subscription,
    this.familyData,
    this.profileData,
  );

  bool isPartOfFamily() {
    return familyData?.members?.isNotEmpty ?? false;
  }

  bool isFamilyAdmin() {
    assert(isPartOfFamily(), "verify user is part of family before calling");
    final FamilyMember currentUserMember = familyData!.members!
        .firstWhere((element) => element.email.trim() == email.trim());
    return currentUserMember.isAdmin;
  }

  // getFamilyOrPersonalUsage will return total usage for family if user
  // belong to family group. Otherwise, it will return storage consumed by
  // current user
  int getFamilyOrPersonalUsage() {
    return isPartOfFamily() ? familyData!.getTotalUsage() : usage;
  }

  int getFreeStorage() {
    return max(getTotalStorage() - getFamilyOrPersonalUsage(), 0);
  }

  // getTotalStorage will return total storage available including the
  // storage bonus
  int getTotalStorage() {
    return (isPartOfFamily() ? familyData!.storage : subscription.storage) +
        storageBonus;
  }

  factory UserDetails.fromMap(Map<String, dynamic> map) {
    return UserDetails(
      map['email'] as String,
      map['usage'] as int,
      (map['fileCount'] ?? 0) as int,
      (map['storageBonus'] ?? 0) as int,
      (map['sharedCollectionsCount'] ?? 0) as int,
      Subscription.fromMap(map['subscription']),
      FamilyData.fromMap(map['familyData']),
      ProfileData.fromJson(map['profileData']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'usage': usage,
      'fileCount': fileCount,
      'storageBonus': storageBonus,
      'sharedCollectionsCount': sharedCollectionsCount,
      'subscription': subscription.toMap(),
      'familyData': familyData?.toMap(),
      'profileData': profileData?.toJson(),
    };
  }

  String toJson() => json.encode(toMap());

  factory UserDetails.fromJson(String source) =>
      UserDetails.fromMap(json.decode(source));
}

class FamilyMember {
  final String email;
  final int usage;
  final String id;
  final bool isAdmin;

  FamilyMember(
    this.email,
    this.usage,
    this.id,
    this.isAdmin,
  );

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      (map['email'] ?? '') as String,
      map['usage'] as int,
      map['id'] as String,
      map['isAdmin'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'usage': usage,
      'id': id,
      'isAdmin': isAdmin,
    };
  }

  String toJson() => json.encode(toMap());

  factory FamilyMember.fromJson(String source) =>
      FamilyMember.fromMap(json.decode(source));
}
class ProfileData {
  bool canDisableEmailMFA;
  bool isEmailMFAEnabled;
  bool isTwoFactorEnabled;

  // Constructor with default values
  ProfileData({
    this.canDisableEmailMFA = false,
    this.isEmailMFAEnabled = false,
    this.isTwoFactorEnabled = false,
  });


  // Factory method to create ProfileData instance from JSON
  factory ProfileData.fromJson(Map<String, dynamic>? json) {
    return ProfileData(
      canDisableEmailMFA: json?['canDisableEmailMFA'] ?? false,
      isEmailMFAEnabled: json?['isEmailMFAEnabled'] ?? false,
      isTwoFactorEnabled: json?['isTwoFactorEnabled'] ?? false,
    );
  }

  // Method to convert ProfileData instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'canDisableEmailMFA': canDisableEmailMFA,
      'isEmailMFAEnabled': isEmailMFAEnabled,
      'isTwoFactorEnabled': isTwoFactorEnabled,
    };
  }
  String toJsonString() => json.encode(toJson());
}

class FamilyData {
  final List<FamilyMember>? members;

  // Storage available based on the family plan
  final int storage;
  final int expiryTime;

  FamilyData(
    this.members,
    this.storage,
    this.expiryTime,
  );

  int getTotalUsage() {
    return members!.map((e) => e.usage).toList().sum;
  }

  static fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    assert(map['members'] != null && map['members'].length >= 0);
    final members = List<FamilyMember>.from(
      map['members'].map((x) => FamilyMember.fromMap(x)),
    );
    return FamilyData(
      members,
      map['storage'] as int,
      map['expiryTime'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'members': members?.map((x) => x.toMap()).toList(),
      'storage': storage,
      'expiryTime': expiryTime,
    };
  }

  String toJson() => json.encode(toMap());

  factory FamilyData.fromJson(String source) =>
      FamilyData.fromMap(json.decode(source));
}

class FilesCount {
  final Map<FileType, int> filesCount;
  FilesCount(this.filesCount);

  int get total =>
      images + videos + livePhotos + (filesCount[getInt(FileType.other)] ?? 0);

  int get photos => images + livePhotos;

  int get images => filesCount[FileType.image] ?? 0;

  int get videos => filesCount[FileType.video] ?? 0;

  int get livePhotos => filesCount[FileType.livePhoto] ?? 0;
}
