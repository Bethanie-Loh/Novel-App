class Review {
  String? id;
  final String userId;
  final String userName;
  final String comment;
  final String timestamp;
  final String profilePicture;

  Review({
    this.id,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.timestamp,
    required this.profilePicture,
  });

  factory Review.fromMap(Map<String, dynamic> review) {
    return Review(
      id: review['id'] as String?,
      userId: review['userId'] as String,
      userName: review['userName'] as String,
      comment: review['comment'] as String,
      timestamp: review['timestamp'] as String,
      profilePicture: review['profilePicture'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'timestamp': timestamp,
      'profilePicture': profilePicture,
    };
  }

  Review copyWith({
    String? id,
    String? userId,
    String? userName,
    String? comment,
    String? timestamp,
    String? profilePicture,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  @override
  String toString() {
    return 'Review{id: $id, userId: $userId, userName: $userName, comment: $comment, timestamp: $timestamp, profilePicture: $profilePicture}';
  }
}
