import { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';

function PostForm({ contentActor, onPostCreated }) {
  const { userProfile } = useAuth();
  const [postContent, setPostContent] = useState('');
  const [isPosting, setIsPosting] = useState(false);
  const [error, setError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!postContent.trim() || !contentActor || !userProfile) return;

    setIsPosting(true);
    setError(null);

    try {
      console.log('🔄 Creating post with:', {
        content: postContent.trim(),
        authorName: userProfile.name || 'Anonymous',
        contentActor: !!contentActor
      });

      const result = await contentActor.createPost({
        content: postContent.trim(),
        authorName: userProfile.name || 'Anonymous'
      });

      console.log('📝 Post creation result:', result);

      if ('ok' in result) {
        setPostContent('');
        if (onPostCreated) {
          onPostCreated(result.ok);
        }
      } else {
        console.error('❌ Post creation failed:', result.err);
        setError('Failed to create post: ' + result.err);
      }
    } catch (err) {
      console.error('❌ Error creating post:', err);
      
      // Provide specific error messages for common issues
      let errorMessage = 'Error creating post: ' + err.message;
      
      if (err.message.includes('Agent')) {
        errorMessage = 'Connection issue. Please check if dfx is running and try again.';
      } else if (err.message.includes('certificate')) {
        errorMessage = 'Authentication issue. Please refresh the page and try again.';
      } else if (err.message.includes('timeout')) {
        errorMessage = 'Request timed out. Please try again.';
      }
      
      setError(errorMessage);
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
    <div className="mb-6 rounded-lg bg-white border border-gray-200 shadow-sm">
      <form onSubmit={handleSubmit} className="p-4">
        {/* Header */}
        <div className="flex items-center space-x-3 mb-4">
          <div className="h-10 w-10 rounded-full bg-gradient-to-r from-blue-500 to-purple-600 flex items-center justify-center">
            <span className="text-sm font-bold text-white">
              {userProfile ? userProfile.name.charAt(0).toUpperCase() : 'U'}
            </span>
          </div>
          <div className="flex-1">
            <textarea
              placeholder="What's on your mind?"
              value={postContent}
              onChange={(e) => setPostContent(e.target.value)}
              className="min-h-[80px] resize-none border-0 bg-gray-50 focus:bg-white transition-colors w-full px-3 py-2 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              rows="3"
              maxLength="1000"
              required
            />
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <button type="button" className="p-2 text-gray-400 hover:text-gray-600 transition-colors">
              <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
            </button>
            <button type="button" className="p-2 text-gray-400 hover:text-gray-600 transition-colors">
              <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14.828 14.828a4 4 0 01-5.656 0M9 10h1m4 0h1m-6 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </button>
          </div>
          <div className="flex items-center space-x-3">
            <span className="text-xs text-gray-500">
              {postContent.length}/1000 characters
            </span>
            <button
              type="submit"
              disabled={isPosting || !postContent.trim()}
              className="px-4 py-2 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-lg hover:from-blue-600 hover:to-purple-700 disabled:opacity-50 disabled:cursor-not-allowed text-sm font-medium transition-all"
            >
              {isPosting ? '🔄 Posting...' : '📤 Post'}
            </button>
          </div>
        </div>
        
        {error && (
          <div className="mt-3 p-3 bg-red-50 border border-red-200 rounded-lg">
            <p className="text-red-800 text-sm">❌ {error}</p>
          </div>
        )}
      </form>
    </div>
  );
}

export default PostForm; 