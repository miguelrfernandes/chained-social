import { useState, useEffect } from 'react';

function PostList({ contentActor, userProfile, onPostCreated }) {
  const [posts, setPosts] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);
  const [commentText, setCommentText] = useState({});
  const [isLiking, setIsLiking] = useState({});

  useEffect(() => {
    loadPosts();
  }, [contentActor]);

  // Refresh posts when a new post is created
  useEffect(() => {
    if (onPostCreated) {
      loadPosts();
    }
  }, [onPostCreated]);

  const loadPosts = async () => {
    if (!contentActor) return;

    setIsLoading(true);
    setError(null);

    try {
      const result = await contentActor.getPosts(10, 0); // Get first 10 posts
      if ('ok' in result) {
        setPosts(result.ok);
      } else {
        setError('Failed to load posts: ' + result.err);
      }
    } catch (err) {
      console.error('Error loading posts:', err);
      setError('Error loading posts: ' + err.message);
    } finally {
      setIsLoading(false);
    }
  };

  const handleLike = async (postId) => {
    if (!contentActor) return;

    setIsLiking({ ...isLiking, [postId]: true });

    try {
      const result = await contentActor.likePost(postId);
      if ('ok' in result) {
        setPosts(posts.map(post => 
          post.id === postId ? result.ok : post
        ));
      }
    } catch (err) {
      console.error('Error liking post:', err);
    } finally {
      setIsLiking({ ...isLiking, [postId]: false });
    }
  };

  const handleComment = async (postId) => {
    if (!contentActor || !userProfile || !commentText[postId]?.trim()) return;

    try {
      const result = await contentActor.addComment({
        postId: postId,
        content: commentText[postId].trim(),
        authorName: userProfile.name || 'Anonymous'
      });

      if ('ok' in result) {
        setPosts(posts.map(post => 
          post.id === postId ? result.ok : post
        ));
        setCommentText({ ...commentText, [postId]: '' });
      }
    } catch (err) {
      console.error('Error adding comment:', err);
    }
  };

  const formatTimestamp = (timestamp) => {
    const date = new Date(Number(timestamp) / 1000000); // Convert from nanoseconds
    return date.toLocaleString();
  };

  if (isLoading) {
    return (
      <div className="text-center py-8">
        <p className="text-gray-600">🔄 Loading posts...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center py-8">
        <p className="text-red-600">❌ {error}</p>
        <button 
          onClick={loadPosts}
          className="mt-2 px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600"
        >
          🔄 Retry
        </button>
      </div>
    );
  }

  if (posts.length === 0) {
    return (
      <div className="text-center py-8">
        <p className="text-gray-600">📭 No posts yet. Be the first to post!</p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {posts.map((post) => (
        <div key={post.id} className="bg-white rounded-lg border border-gray-200 p-4 shadow-sm">
          <div className="flex items-start space-x-3">
            <div className="flex-shrink-0">
              <div className="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center">
                <span className="text-white font-medium">
                  {post.authorName.charAt(0).toUpperCase()}
                </span>
              </div>
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center space-x-2 mb-2">
                <span className="font-medium text-gray-900">{post.authorName}</span>
                <span className="text-sm text-gray-500">•</span>
                <span className="text-sm text-gray-500">{formatTimestamp(post.timestamp)}</span>
              </div>
              <p className="text-gray-900 mb-3">{post.content}</p>
              
              {/* Like button */}
              <div className="flex items-center space-x-4 mb-3">
                <button
                  onClick={() => handleLike(post.id)}
                  disabled={isLiking[post.id]}
                  className="flex items-center space-x-1 text-gray-500 hover:text-red-500 disabled:opacity-50"
                >
                  <span>❤️</span>
                  <span className="text-sm">{post.likes}</span>
                </button>
                <span className="text-gray-400">•</span>
                <span className="text-sm text-gray-500">{post.comments.length} comments</span>
              </div>

              {/* Comments */}
              {post.comments.length > 0 && (
                <div className="border-t border-gray-100 pt-3 mb-3">
                  <div className="space-y-2">
                    {post.comments.map((comment) => (
                      <div key={comment.id} className="flex items-start space-x-2">
                        <div className="w-6 h-6 bg-gray-300 rounded-full flex items-center justify-center flex-shrink-0">
                          <span className="text-xs text-gray-600">
                            {comment.authorName.charAt(0).toUpperCase()}
                          </span>
                        </div>
                        <div className="flex-1">
                          <div className="flex items-center space-x-2">
                            <span className="text-sm font-medium text-gray-900">{comment.authorName}</span>
                            <span className="text-xs text-gray-500">{formatTimestamp(comment.timestamp)}</span>
                          </div>
                          <p className="text-sm text-gray-700">{comment.content}</p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Add comment */}
              {userProfile && (
                <div className="border-t border-gray-100 pt-3">
                  <div className="flex space-x-2">
                    <input
                      type="text"
                      value={commentText[post.id] || ''}
                      onChange={(e) => setCommentText({ ...commentText, [post.id]: e.target.value })}
                      placeholder="Add a comment..."
                      className="flex-1 px-3 py-1 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                      maxLength="500"
                    />
                    <button
                      onClick={() => handleComment(post.id)}
                      disabled={!commentText[post.id]?.trim()}
                      className="px-3 py-1 text-sm bg-blue-500 text-white rounded-md hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      💬
                    </button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

export default PostList; 