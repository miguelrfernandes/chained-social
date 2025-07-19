import { useState } from 'react';

function PostForm({ contentActor, userProfile, onPostCreated }) {
  const [postContent, setPostContent] = useState('');
  const [isPosting, setIsPosting] = useState(false);
  const [error, setError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!postContent.trim() || !contentActor || !userProfile) return;

    setIsPosting(true);
    setError(null);

    try {
      const result = await contentActor.createPost({
        content: postContent.trim(),
        authorName: userProfile.name || 'Anonymous'
      });

      if ('ok' in result) {
        setPostContent('');
        if (onPostCreated) {
          onPostCreated(result.ok);
        }
      } else {
        setError('Failed to create post: ' + result.err);
      }
    } catch (err) {
      console.error('Error creating post:', err);
      setError('Error creating post: ' + err.message);
    } finally {
      setIsPosting(false);
    }
  };

  if (!userProfile) {
    return (
      <div className="mb-6 rounded-lg bg-yellow-50 p-4 border border-yellow-200">
        <p className="text-yellow-800 text-sm">Please set your profile before creating posts.</p>
      </div>
    );
  }

  return (
    <div className="mb-6 rounded-lg bg-white p-4 border border-gray-200 shadow-sm">
      <h3 className="text-lg font-medium text-gray-900 mb-3">📝 Create a Post</h3>
      <form onSubmit={handleSubmit} className="space-y-3">
        <div>
          <textarea
            value={postContent}
            onChange={(e) => setPostContent(e.target.value)}
            placeholder="What's on your mind?"
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
            rows="3"
            maxLength="1000"
            required
          />
          <div className="flex justify-between items-center mt-1">
            <span className="text-xs text-gray-500">
              {postContent.length}/1000 characters
            </span>
            <button
              type="submit"
              disabled={isPosting || !postContent.trim()}
              className="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed text-sm"
            >
              {isPosting ? '🔄 Posting...' : '📤 Post'}
            </button>
          </div>
        </div>
        {error && (
          <div className="p-3 bg-red-50 border border-red-200 rounded-lg">
            <p className="text-red-800 text-sm">❌ {error}</p>
          </div>
        )}
      </form>
    </div>
  );
}

export default PostForm; 