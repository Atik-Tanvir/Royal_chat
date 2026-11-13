import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../data/repositories/moments_repository_impl.dart';
import '../../domain/entities/moment_comment.dart';
import '../../domain/entities/moment_post.dart';
import '../../domain/entities/moment_story.dart';
import '../../domain/entities/social_profile.dart';
import '../../domain/repositories/moments_repository.dart';
import 'moments_event.dart';
import 'moments_state.dart';

class MomentsBloc extends Bloc<MomentsEvent, MomentsState> {
  final MomentsRepository _repository;

  MomentsBloc({MomentsRepository? repository})
      : _repository = repository ?? MomentsRepositoryImpl(),
        super(const MomentsState()) {
    on<LoadMomentsEvent>(_onLoadMoments);
    on<ChangeMomentTabEvent>(_onChangeTab);
    on<CreateMomentEvent>(_onCreateMoment);
    on<DeleteMomentEvent>(_onDeleteMoment);
    on<ToggleLikePostEvent>(_onToggleLikePost);
    on<SharePostEvent>(_onSharePost);
    on<LoadCommentsEvent>(_onLoadComments);
    on<AddCommentEvent>(_onAddComment);
    on<CreateStoryEvent>(_onCreateStory);
    on<MarkStoryViewedEvent>(_onMarkStoryViewed);
    on<ToggleLikeStoryEvent>(_onToggleLikeStory);
    on<DeleteStoryEvent>(_onDeleteStory);
    on<ToggleFollowAuthorEvent>(_onToggleFollowAuthor);
    on<UpdateMySocialProfileEvent>(_onUpdateMySocialProfile);
    on<MomentsUpdatedFromRealtimeEvent>(_onRealtimeUpdate);
    on<LikedPostsLoadedEvent>(_onLikedLoaded);

    add(LoadMomentsEvent());
  }

  String _currentUserId() => AuthSessionManager.currentUserId ?? 'royal_guest';

  SocialProfileDetails _ensureMyProfile(
      Map<String, SocialProfileDetails> profiles) {
    final myId = _currentUserId();
    final existing = profiles[myId];
    if (existing != null) return existing;

    final rawName = (AuthSessionManager.currentUserName ?? '').trim();
    final nickname = rawName.isEmpty ? 'Royal Player' : rawName;
    final cleanHandle = nickname
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
    final initials = nickname.length >= 2
        ? nickname.substring(0, 2).toUpperCase()
        : nickname.toUpperCase();
    final rawAvatar = (AuthSessionManager.currentUserAvatar ?? '').trim();
    final avatarUrl = rawAvatar.isNotEmpty
        ? rawAvatar
        : 'royal_avatar://$initials:1F7A52';

    return SocialProfileDetails(
      userId: myId,
      usernameHandle: '@${cleanHandle.isEmpty ? 'royalplayer' : cleanHandle}',
      nickname: nickname,
      avatarUrl: avatarUrl,
      coverGradientIndex: 0,
      bio: 'Playing games & sharing daily wins on Gamegala!',
      location: 'Dhaka, Bangladesh',
      countryFlag: '🇧🇩',
      level: 15,
      joinedLabel: 'Member since 2026',
      followersCount: 142,
      followingCount: 38,
    );
  }

  Future<void> _onLoadMoments(
    LoadMomentsEvent event,
    Emitter<MomentsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final results = await Future.wait([
        _repository.loadPosts(),
        _repository.loadStories(),
        _repository.loadAllComments(),
        _repository.loadLikedPostIds(),
        _repository.loadViewedStoryIds(),
        _repository.loadFollowedAuthorIds(),
        _repository.loadSocialProfiles(),
      ]);

      final posts = results[0] as List<MomentPost>;
      final stories = results[1] as List<MomentStory>;
      final comments = results[2] as Map<String, List<MomentComment>>;
      final likedIds = results[3] as Set<String>;
      final viewedIds = results[4] as Set<String>;
      final followedIds = results[5] as Set<String>;
      final profiles = Map<String, SocialProfileDetails>.from(
        results[6] as Map<String, SocialProfileDetails>,
      );

      final myProfile = _ensureMyProfile(profiles);
      if (!profiles.containsKey(myProfile.userId)) {
        profiles[myProfile.userId] = myProfile;
        await _repository.saveSocialProfiles(profiles);
      }

      emit(state.copyWith(
        posts: posts,
        stories: stories,
        commentsByPostId: comments,
        likedPostIds: likedIds,
        viewedStoryIds: viewedIds,
        followedAuthorIds: followedIds,
        mySocialProfile: myProfile,
        profilesById: profiles,
        isLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onChangeTab(
    ChangeMomentTabEvent event,
    Emitter<MomentsState> emit,
  ) {
    emit(state.copyWith(activeTab: event.tab));
  }

  Future<void> _onCreateMoment(
    CreateMomentEvent event,
    Emitter<MomentsState> emit,
  ) async {
    final myProfile =
        state.mySocialProfile ?? _ensureMyProfile(state.profilesById);
    final now = DateTime.now();
    final newPost = MomentPost(
      id: 'post_${now.millisecondsSinceEpoch}',
      authorId: myProfile.userId,
      authorName: myProfile.nickname,
      authorAvatar: myProfile.avatarUrl,
      countryFlag: myProfile.countryFlag,
      authorLevel: myProfile.level,
      content: event.content.trim(),
      imageUrls: List<String>.from(event.imageUrls),
      createdAt: now,
      likesCount: 0,
      commentsCount: 0,
      sharesCount: 0,
      isLiked: false,
      category: event.category,
      location: event.location,
    );

    final updatedPosts = [newPost, ...state.posts];
    List<MomentStory> updatedStories = state.stories;

    if (event.shareToStory) {
      final newStory = MomentStory(
        id: 'story_${now.millisecondsSinceEpoch}',
        authorId: myProfile.userId,
        authorName: myProfile.nickname,
        authorAvatar: myProfile.avatarUrl,
        countryFlag: myProfile.countryFlag,
        mediaUrl: event.imageUrls.isNotEmpty ? event.imageUrls.first : null,
        caption: event.content.trim(),
        bgGradientIndex: 0,
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
      );
      updatedStories = [newStory, ...state.stories];
      await _repository.saveStories(updatedStories);
    }

    emit(state.copyWith(
      posts: updatedPosts,
      stories: updatedStories,
      uiToastMessage: event.shareToStory
          ? 'Moment & Story published!'
          : 'Moment published!',
      uiToastTick: state.uiToastTick + 1,
    ));

    await _repository.savePosts(updatedPosts);
    await _repository.publishPostToRemote(newPost);
  }

  Future<void> _onDeleteMoment(
    DeleteMomentEvent event,
    Emitter<MomentsState> emit,
  ) async {
    final updated = state.posts.where((p) => p.id != event.postId).toList();
    emit(state.copyWith(
      posts: updated,
      uiToastMessage: 'Post deleted from your timeline',
      uiToastTick: state.uiToastTick + 1,
    ));
    await _repository.savePosts(updated);
  }

  Future<void> _onToggleLikePost(
    ToggleLikePostEvent event,
    Emitter<MomentsState> emit,
  ) async {
    final idx = state.posts.indexWhere((p) => p.id == event.postId);
    if (idx == -1) return;

    final current = state.posts[idx];
    final nextLiked = !current.isLiked;
    final nextCount =
        nextLiked ? current.likesCount + 1 : (current.likesCount - 1).clamp(0, 999999);

    final updatedLikedIds = Set<String>.from(state.likedPostIds);
    if (nextLiked) {
      updatedLikedIds.add(event.postId);
    } else {
      updatedLikedIds.remove(event.postId);
    }

    final updatedPosts = List<MomentPost>.from(state.posts);
    updatedPosts[idx] = current.copyWith(
      isLiked: nextLiked,
      likesCount: nextCount,
    );

    emit(state.copyWith(
      posts: updatedPosts,
      likedPostIds: updatedLikedIds,
    ));

    await _repository.saveLikedPostIds(updatedLikedIds);
    await _repository.savePosts(updatedPosts);
    await _repository.toggleLikeRemote(event.postId, nextCount);
  }

  Future<void> _onSharePost(
    SharePostEvent event,
    Emitter<MomentsState> emit,
  ) async {
    final idx = state.posts.indexWhere((p) => p.id == event.postId);
    if (idx == -1) return;

    final targetPost = state.posts[idx];
    final myProfile =
        state.mySocialProfile ?? _ensureMyProfile(state.profilesById);
    final now = DateTime.now();

    final updatedPosts = List<MomentPost>.from(state.posts);
    updatedPosts[idx] = targetPost.copyWith(
      sharesCount: targetPost.sharesCount + 1,
    );

    List<MomentStory> updatedStories = state.stories;
    String toast;

    switch (event.target) {
      case SharePostTarget.repostFeed:
        final noteText = event.note?.trim() ?? '';
        final repostText = noteText.isNotEmpty
            ? '$noteText\n\n"${targetPost.content}"'
            : targetPost.content;
        final repost = MomentPost(
          id: 'repost_${now.millisecondsSinceEpoch}',
          authorId: myProfile.userId,
          authorName: myProfile.nickname,
          authorAvatar: myProfile.avatarUrl,
          countryFlag: myProfile.countryFlag,
          authorLevel: myProfile.level,
          content: repostText,
          imageUrls: List<String>.from(targetPost.imageUrls),
          createdAt: now,
          likesCount: 0,
          commentsCount: 0,
          sharesCount: 0,
          category: 'Moments',
          location: myProfile.location,
          isRepost: true,
          repostedFromAuthor: targetPost.authorName,
          repostedFromPostId: targetPost.id,
        );
        updatedPosts.insert(0, repost);
        toast = 'Shared ${targetPost.authorName}\'s post to your feed!';
        break;
      case SharePostTarget.shareToStory:
        final sharedStory = MomentStory(
          id: 'story_${now.millisecondsSinceEpoch}',
          authorId: myProfile.userId,
          authorName: myProfile.nickname,
          authorAvatar: myProfile.avatarUrl,
          countryFlag: myProfile.countryFlag,
          mediaUrl: targetPost.imageUrls.isNotEmpty
              ? targetPost.imageUrls.first
              : null,
          caption: 'Shared from ${targetPost.authorName}: ${targetPost.content}',
          bgGradientIndex: 3,
          createdAt: now,
          expiresAt: now.add(const Duration(hours: 24)),
        );
        updatedStories = [sharedStory, ...state.stories];
        await _repository.saveStories(updatedStories);
        toast = 'Shared post to your Story!';
        break;
      case SharePostTarget.copyLink:
        toast = 'Post link & summary copied!';
        break;
    }

    emit(state.copyWith(
      posts: updatedPosts,
      stories: updatedStories,
      uiToastMessage: toast,
      uiToastTick: state.uiToastTick + 1,
    ));

    await _repository.savePosts(updatedPosts);
  }

  Future<void> _onLoadComments(
    LoadCommentsEvent event,
    Emitter<MomentsState> emit,
  ) async {
    final all = await _repository.loadAllComments();
    emit(state.copyWith(
      commentsByPostId: {
        ...state.commentsByPostId,
        ...all,
      },
    ));
  }

  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<MomentsState> emit,
  ) async {
    final cleanText = event.text.trim();
    if (cleanText.isEmpty) return;

    final myProfile =
        state.mySocialProfile ?? _ensureMyProfile(state.profilesById);
    final newComment = MomentComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: event.postId,
      userId: myProfile.userId,
      userName: myProfile.nickname,
      userAvatar: myProfile.avatarUrl,
      text: cleanText,
      createdAt: DateTime.now(),
    );

    final existing =
        List<MomentComment>.from(state.commentsByPostId[event.postId] ?? []);
    existing.add(newComment);

    final updatedCommentsMap =
        Map<String, List<MomentComment>>.from(state.commentsByPostId)
          ..[event.postId] = existing;

    final updatedPosts = state.posts.map((p) {
      if (p.id == event.postId) {
        return p.copyWith(commentsCount: existing.length);
      }
      return p;
    }).toList();

    emit(state.copyWith(
      commentsByPostId: updatedCommentsMap,
      posts: updatedPosts,
    ));

    await _repository.saveCommentsForPost(event.postId, existing);
    await _repository.savePosts(updatedPosts);
  }

  Future<void> _onCreateStory(
    CreateStoryEvent event,
    Emitter<MomentsState> emit,
  ) async {
    final myProfile =
        state.mySocialProfile ?? _ensureMyProfile(state.profilesById);
    final now = DateTime.now();
    final story = MomentStory(
      id: 'story_${now.millisecondsSinceEpoch}',
      authorId: myProfile.userId,
      authorName: myProfile.nickname,
      authorAvatar: myProfile.avatarUrl,
      countryFlag: myProfile.countryFlag,
      mediaUrl: event.mediaUrl,
      caption: event.caption.trim(),
      bgGradientIndex: event.bgGradientIndex,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
      viewsCount: 1,
    );

    final updatedStories = [story, ...state.stories];
    emit(state.copyWith(
      stories: updatedStories,
      uiToastMessage: 'Your Story is now live for 24 hours!',
      uiToastTick: state.uiToastTick + 1,
    ));
    await _repository.saveStories(updatedStories);
  }

  Future<void> _onMarkStoryViewed(
    MarkStoryViewedEvent event,
    Emitter<MomentsState> emit,
  ) async {
    final updatedViewed = Set<String>.from(state.viewedStoryIds);
    final firstView = updatedViewed.add(event.storyId);
    final updatedStories = state.stories.map((s) {
      if (s.id == event.storyId && firstView) {
        return s.copyWith(viewsCount: s.viewsCount + 1);
      }
      return s;
    }).toList();

    emit(state.copyWith(
      viewedStoryIds: updatedViewed,
      stories: updatedStories,
    ));

    await _repository.saveViewedStoryIds(updatedViewed);
    await _repository.saveStories(updatedStories);
  }

  Future<void> _onToggleLikeStory(
    ToggleLikeStoryEvent event,
    Emitter<MomentsState> emit,
  ) async {
    final updatedStories = state.stories.map((s) {
      if (s.id == event.storyId) {
        final nextLiked = !s.isLikedByMe;
        return s.copyWith(
          isLikedByMe: nextLiked,
          likesCount: nextLiked ? s.likesCount + 1 : (s.likesCount - 1).clamp(0, 999999),
        );
      }
      return s;
    }).toList();

    emit(state.copyWith(stories: updatedStories));
    await _repository.saveStories(updatedStories);
  }

  Future<void> _onDeleteStory(
    DeleteStoryEvent event,
    Emitter<MomentsState> emit,
  ) async {
    final updatedStories =
        state.stories.where((s) => s.id != event.storyId).toList();
    emit(state.copyWith(
      stories: updatedStories,
      uiToastMessage: 'Story removed',
      uiToastTick: state.uiToastTick + 1,
    ));
    await _repository.saveStories(updatedStories);
  }

  Future<void> _onToggleFollowAuthor(
    ToggleFollowAuthorEvent event,
    Emitter<MomentsState> emit,
  ) async {
    final updatedFollowed = Set<String>.from(state.followedAuthorIds);
    final nowFollowing = updatedFollowed.add(event.authorId);
    if (!nowFollowing) {
      updatedFollowed.remove(event.authorId);
    }

    final updatedProfiles =
        Map<String, SocialProfileDetails>.from(state.profilesById);
    final targetProfile = updatedProfiles[event.authorId];
    if (targetProfile != null) {
      updatedProfiles[event.authorId] = targetProfile.copyWith(
        followersCount: nowFollowing
            ? targetProfile.followersCount + 1
            : (targetProfile.followersCount - 1).clamp(0, 9999999),
      );
    }

    final myProfile = state.mySocialProfile;
    SocialProfileDetails? updatedMine = myProfile;
    if (myProfile != null) {
      updatedMine = myProfile.copyWith(
        followingCount: nowFollowing
            ? myProfile.followingCount + 1
            : (myProfile.followingCount - 1).clamp(0, 9999999),
      );
      updatedProfiles[myProfile.userId] = updatedMine;
    }

    emit(state.copyWith(
      followedAuthorIds: updatedFollowed,
      profilesById: updatedProfiles,
      mySocialProfile: updatedMine,
      uiToastMessage: nowFollowing
          ? 'Following ${event.authorName}'
          : 'Unfollowed ${event.authorName}',
      uiToastTick: state.uiToastTick + 1,
    ));

    await _repository.saveFollowedAuthorIds(updatedFollowed);
    await _repository.saveSocialProfiles(updatedProfiles);
  }

  Future<void> _onUpdateMySocialProfile(
    UpdateMySocialProfileEvent event,
    Emitter<MomentsState> emit,
  ) async {
    final base = state.mySocialProfile ?? _ensureMyProfile(state.profilesById);
    final cleanHandle = event.usernameHandle.trim().startsWith('@')
        ? event.usernameHandle.trim()
        : '@${event.usernameHandle.trim()}';

    final updatedProfile = base.copyWith(
      nickname: event.nickname.trim().isEmpty
          ? base.nickname
          : event.nickname.trim(),
      usernameHandle: cleanHandle == '@' ? base.usernameHandle : cleanHandle,
      bio: event.bio.trim(),
      location: event.location.trim().isEmpty
          ? base.location
          : event.location.trim(),
      avatarUrl: event.avatarUrl.trim().isEmpty
          ? base.avatarUrl
          : event.avatarUrl.trim(),
      coverGradientIndex: event.coverGradientIndex,
      coverImageUrl: event.coverImageUrl,
    );

    final updatedProfiles =
        Map<String, SocialProfileDetails>.from(state.profilesById)
          ..[updatedProfile.userId] = updatedProfile;

    // Keep all posts and stories authored by current user synced with updated name/avatar.
    final updatedPosts = state.posts.map((p) {
      if (p.authorId == updatedProfile.userId) {
        return p.copyWith(
          authorName: updatedProfile.nickname,
          authorAvatar: updatedProfile.avatarUrl,
        );
      }
      return p;
    }).toList();

    final updatedStories = state.stories.map((s) {
      if (s.authorId == updatedProfile.userId) {
        return s.copyWith(
          authorName: updatedProfile.nickname,
          authorAvatar: updatedProfile.avatarUrl,
        );
      }
      return s;
    }).toList();

    emit(state.copyWith(
      mySocialProfile: updatedProfile,
      profilesById: updatedProfiles,
      posts: updatedPosts,
      stories: updatedStories,
      uiToastMessage: 'Social profile updated!',
      uiToastTick: state.uiToastTick + 1,
    ));

    // Also keep AuthSessionManager in sync across the app.
    await AuthSessionManager.saveSession(
      userId: updatedProfile.userId,
      name: updatedProfile.nickname,
      email: AuthSessionManager.currentUserEmail ?? 'player@gamegala.app',
      avatarUrl: updatedProfile.avatarUrl,
    );

    await _repository.saveSocialProfiles(updatedProfiles);
    await _repository.savePosts(updatedPosts);
    await _repository.saveStories(updatedStories);
  }

  void _onRealtimeUpdate(
    MomentsUpdatedFromRealtimeEvent event,
    Emitter<MomentsState> emit,
  ) {
    add(LoadMomentsEvent());
  }

  void _onLikedLoaded(
    LikedPostsLoadedEvent event,
    Emitter<MomentsState> emit,
  ) {
    emit(state.copyWith(likedPostIds: event.likedPostIds));
  }
}
