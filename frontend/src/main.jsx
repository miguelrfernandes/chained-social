import React, { useState, useEffect } from 'react';
import ReactDOM from 'react-dom/client';
import '../index.css';
import NfidLogin from './components/Nfidlogin';
import PostForm from './components/PostForm';
import PostList from './components/PostList';

function App() {
  const [error, setError] = useState(null);
  const [backendActor, setBackendActor] = useState(null);
  const [contentActor, setContentActor] = useState(null);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [userPrincipal, setUserPrincipal] = useState(null);
  const [userProfile, setUserProfile] = useState(null);
  const [isSettingProfile, setIsSettingProfile] = useState(false);
  const [profileForm, setProfileForm] = useState({ username: '', bio: '' });




  // Initialize content actor for everyone (not just logged in users)
  useEffect(() => {
    const initContentActor = async () => {
      try {
        const { content } = await import('../../src/declarations/content');
        setContentActor(content);
      } catch (err) {
        console.error('Failed to initialize content actor:', err);
      }
    };
    initContentActor();
  }, []);



  const handleBackendActorSet = (actor, principal) => {
    setBackendActor(actor);
    setUserPrincipal(principal);
    setIsLoggedIn(true);
  };

  const handleSetProfile = async (e) => {
    e.preventDefault();
    if (!backendActor || !profileForm.username.trim()) return;

    setIsSettingProfile(true);
    try {
      console.log("🔄 Setting profile with:", { username: profileForm.username, bio: profileForm.bio });
      const result = await backendActor.setUserProfile(profileForm.username, profileForm.bio);
      console.log("✅ Profile set result:", result);
      if ('ok' in result) {
        setUserProfile(result.ok);
        setProfileForm({ username: '', bio: '' });
      } else {
        setError('Failed to set profile: ' + result.err);
      }
    } catch (err) {
      console.error("❌ Error setting profile:", err);
      setError('Error setting profile: ' + err.message);
    } finally {
      setIsSettingProfile(false);
    }
  };

  const handlePostCreated = async (newPost) => {
    console.log('✅ Post created successfully:', newPost);
    // The PostList component will handle refreshing itself
  };

  return (
    <div className="min-h-screen bg-gradient-to-r from-blue-400 to-purple-500">
      <div className="w-full max-w-4xl mx-auto p-8">
        {/* Header with Title */}
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-white mb-2">🚀 Chained Social</h1>
          <p className="text-white text-lg opacity-90">Crypto Social Network on ICP!</p>
        </div>

        <div className="bg-white rounded-lg shadow-lg p-8">
          <NfidLogin setBackendActor={handleBackendActorSet} />
          
          {isLoggedIn && (
            <div className="mb-4 rounded-lg bg-green-50 p-4 border border-green-200">
              <p className="text-green-800 font-medium">✅ Logged in successfully!</p>
              <p className="text-green-600 text-sm mt-1">Principal: {userPrincipal}</p>
            </div>
          )}

          {isLoggedIn && !userProfile && (
            <div className="mb-6 rounded-lg bg-blue-50 p-4 border border-blue-200">
              <h3 className="text-blue-800 font-medium mb-3">👤 Set Your Profile</h3>
              <form onSubmit={handleSetProfile} className="space-y-3">
                <div>
                  <label htmlFor="username" className="block text-sm font-medium text-gray-700 mb-1">
                    Username
                  </label>
                  <input
                    type="text"
                    id="username"
                    value={profileForm.username}
                    onChange={(e) => setProfileForm({ ...profileForm, username: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Enter your username"
                    required
                  />
                </div>
                <div>
                  <label htmlFor="bio" className="block text-sm font-medium text-gray-700 mb-1">
                    Bio
                  </label>
                  <textarea
                    id="bio"
                    value={profileForm.bio}
                    onChange={(e) => setProfileForm({ ...profileForm, bio: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Tell us about yourself..."
                    rows="3"
                  />
                </div>
                <button
                  type="submit"
                  disabled={isSettingProfile || !profileForm.username.trim()}
                  className="w-full px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isSettingProfile ? '🔄 Setting Profile...' : '💾 Save Profile'}
                </button>
              </form>
            </div>
          )}

          {userProfile && (
            <div className="mb-4 rounded-lg bg-purple-50 p-4 border border-purple-200">
              <h3 className="text-purple-800 font-medium">👤 Your Profile</h3>
              <p className="text-purple-600 text-sm mt-1">Username: {userProfile.name}</p>
              <p className="text-purple-600 text-sm">Bio: {userProfile.bio || 'No bio set'}</p>
              <p className="text-purple-600 text-sm">ID: {userProfile.id}</p>
            </div>
          )}

          {/* Posting Interface */}
          {userProfile && contentActor && (
            <div className="mb-6">
              <h2 className="text-2xl font-bold text-gray-800 mb-4">📝 Create a Post</h2>
              <PostForm 
                contentActor={contentActor}
                userProfile={userProfile}
                onPostCreated={handlePostCreated}
              />
            </div>
          )}

          {/* Posts Display - Now visible to everyone */}
          {contentActor && (
            <div className="mb-6">
              <h2 className="text-2xl font-bold text-gray-800 mb-4">📰 Recent Posts</h2>
              <PostList 
                contentActor={contentActor}
                userProfile={userProfile}
                onPostCreated={handlePostCreated}
              />
            </div>
          )}
          
          <p className="text-center text-gray-600 mt-6">
            A social network hosted onchain on ICP.
          </p>
          
          {error && <p className="mt-4 text-center text-red-500">Error: {error}</p>}
        </div>
      </div>
    </div>
  );
}

export default App;

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
