import React from 'react';
import PostForm from './PostForm';
import { useAuth } from '../contexts/AuthContext';

function PostingInterface({ contentActor, onPostCreated }) {
  const { userProfile } = useAuth();

  if (!userProfile || !contentActor) {
    return null;
  }

  return (
    <div className="mb-6">
      <h2 className="text-2xl font-bold text-gray-800 mb-4">📝 Create a Post</h2>
      <PostForm
        contentActor={contentActor}
        onPostCreated={onPostCreated}
      />
    </div>
  );
}

export default PostingInterface; 