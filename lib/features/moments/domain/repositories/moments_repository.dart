import '../entities/moment_comment.dart';
import '../entities/moment_post.dart';
import '../entities/moment_story.dart';
import '../entities/social_profile.dart';

/// Clean Architecture contract for Moments posts, comments, stories, and social profiles.
abstract class MomentsRepository {
  Future<List<MomentPost>> loadPosts();
  Future<void> savePosts(List<MomentPost> posts);
  Future<void> publishPostToRemote(MomentPost post);
  Future<void> toggleLikeRemote(String postId, int nextLikesCount);

  Future<List<MomentStory>> loadStories();
  Future<void> saveStories(List<MomentStory> stories);

  Future<Map<String, List<MomentComment>>> loadAllComments();
  Future<void> saveCommentsForPost(String postId, List<MomentComment> comments);

  Future<Set<String>> loadLikedPostIds();
  Future<void> saveLikedPostIds(Set<String> ids);

  Future<Set<String>> loadViewedStoryIds();
  Future<void> saveViewedStoryIds(Set<String> ids);

  Future<Set<String>> loadFollowedAuthorIds();
  Future<void> saveFollowedAuthorIds(Set<String> ids);

  Future<Map<String, SocialProfileDetails>> loadSocialProfiles();
  Future<void> saveSocialProfiles(Map<String, SocialProfileDetails> profiles);
}
