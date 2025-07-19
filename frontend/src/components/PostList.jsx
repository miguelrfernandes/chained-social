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
        <div key={post.id} className="bg-white rounded-lg border border-gray-200 shadow-sm hover:shadow-md transition-shadow duration-200">
          {/* Header */}
          <div className="p-4 pb-3">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <div className="h-10 w-10 rounded-full bg-gradient-to-r from-blue-500 to-purple-600 flex items-center justify-center">
                  <span className="text-sm font-bold text-white">
                    {post.authorName.charAt(0).toUpperCase()}
                  </span>
                </div>
                <div>
                  <p className="font-semibold text-gray-900">{post.authorName}</p>
                  <p className="text-sm text-gray-500">{formatTimestamp(post.timestamp)}</p>
                </div>
              </div>
              <button className="p-1 text-gray-400 hover:text-gray-600 transition-colors">
                <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
                </svg>
              </button>
            </div>
          </div>

          {/* Content */}
          <div className="px-4 pb-3">
            <p className="text-gray-900 leading-relaxed">{post.content}</p>
          </div>

          {/* Actions */}
          <div className="flex items-center justify-between px-4 py-3 border-t border-gray-100">
            <div className="flex items-center space-x-1">
              <button
                onClick={() => handleLike(post.id)}
                disabled={isLiking[post.id]}
                className="flex items-center space-x-2 text-gray-500 hover:text-red-500 disabled:opacity-50 transition-colors"
              >
                <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                </svg>
                <span className="text-sm">{post.likes}</span>
              </button>
              <button className="flex items-center space-x-2 text-gray-500 hover:text-gray-700 transition-colors">
                <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                </svg>
                <span className="text-sm">{post.comments.length}</span>
              </button>
            </div>
            <button className="text-gray-500 hover:text-gray-700 transition-colors">
              <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.367 2.684 3 3 0 00-5.367-2.684z" />
              </svg>
            </button>
          </div>

        </div>
      ))}
    </div>
  );
}

export default PostList; 