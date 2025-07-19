import React, { useState, useEffect } from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import '../index.css';
import NfidLogin from './components/Nfidlogin';
import PostForm from './components/PostForm';
import PostList from './components/PostList';
import Header from './components/Header';
import Toast from './components/Toast';
import Profile from './components/Profile';

function App() {
  const [error, setError] = useState(null);
  const [backendActor, setBackendActor] = useState(null);
  const [contentActor, setContentActor] = useState(null);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [userPrincipal, setUserPrincipal] = useState(null);
  const [userProfile, setUserProfile] = useState(null);
  const [isSettingProfile, setIsSettingProfile] = useState(false);
  const [profileForm, setProfileForm] = useState({ username: '', bio: '' });
  const [toast, setToast] = useState(null);

  // Expose toast function globally for components to use
  useEffect(() => {
    window.showToast = (toastConfig) => {
      setToast(toastConfig);
    };
    
    return () => {
      delete window.showToast;
    };
  }, []);




  // Initialize content actor for everyone (not just logged in users)
  useEffect(() => {
    const initContentActor = async () => {
      try {
        console.log('🔄 Initializing content actor...');
        const { content } = await import('../../src/declarations/content');
        
        if (!content) {
          console.error('❌ Content actor is undefined - canister ID may not be set');
          return;
        }
        
        setContentActor(content);
        
        // Test the connection
        try {
          const testResult = await content.getPosts(1, 0);
          console.log('✅ Content actor initialized successfully:', testResult);
        } catch (testErr) {
          console.error('⚠️ Content actor connection test failed:', testErr);
          console.error('This might be due to:');
          console.error('1. DFX not running');
          console.error('2. Canister not deployed');
          console.error('3. Network connectivity issues');
        }
      } catch (err) {
        console.error('❌ Failed to initialize content actor:', err);
        console.error('Error details:', err.message);
      }
    };
    initContentActor();
  }, []);



  const handleBackendActorSet = (actor, principal) => {
    setBackendActor(actor);
    setUserPrincipal(principal);
    setIsLoggedIn(true);
    
    // Show success toast
    setToast({
      message: `✅ Logged in successfully!\nPrincipal: ${principal}`,
      type: 'success',
      duration: 4000
    });
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
        setToast({
          message: '✅ Profile saved successfully!',
          type: 'success',
          duration: 3000
        });
      } else {
        setError('Failed to set profile: ' + result.err);
        setToast({
          message: `❌ Failed to save profile: ${result.err}`,
          type: 'error',
          duration: 5000
        });
      }
    } catch (err) {
      console.error("❌ Error setting profile:", err);
      setError('Error setting profile: ' + err.message);
      setToast({
        message: `❌ Error setting profile: ${err.message}`,
        type: 'error',
        duration: 5000
      });
    } finally {
      setIsSettingProfile(false);
    }
  };

  const handlePostCreated = async (newPost) => {
    console.log('✅ Post created successfully:', newPost);
    setToast({
      message: '✅ Post created successfully!',
      type: 'success',
      duration: 3000
    });
    // The PostList component will handle refreshing itself
  };

  return (
    <Router>
      <div className="min-h-screen bg-gray-50">
        <Header 
          isLoggedIn={isLoggedIn}
          userPrincipal={userPrincipal}
          userProfile={userProfile}
          setBackendActor={handleBackendActorSet}
        />
        
        <Routes>
          <Route path="/profile/:username" element={
            <Profile 
              contentActor={contentActor}
              userProfile={userProfile}
              isLoggedIn={isLoggedIn}
            />
          } />
          <Route path="/" element={
            <div className="w-full max-w-4xl mx-auto p-8">
              <div className="bg-white rounded-lg shadow-lg p-8">
                
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
              <div className="flex items-center space-x-3 mb-3">
                <Link 
                  to={`/profile/${userProfile.name}`}
                  className="h-12 w-12 rounded-full bg-gradient-to-r from-blue-500 to-purple-600 flex items-center justify-center cursor-pointer hover:scale-105 transition-transform"
                >
                  <span className="text-lg font-bold text-white">
                    {userProfile.name.charAt(0).toUpperCase()}
                  </span>
                </Link>
                <div className="flex-1">
                  <h3 className="text-purple-800 font-medium">👤 Your Profile</h3>
                  <p className="text-purple-600 text-sm">Username: {userProfile.name}</p>
                  <p className="text-purple-600 text-sm">Bio: {userProfile.bio || 'No bio set'}</p>
                  <p className="text-purple-600 text-sm">ID: {userProfile.id}</p>
                </div>
              </div>
              <Link 
                to={`/profile/${userProfile.name}`}
                className="inline-block px-4 py-2 bg-purple-500 text-white rounded-md hover:bg-purple-600 transition-colors text-sm"
              >
                View Full Profile →
              </Link>
            </div>
          )}

                {/* Debug Info for Codespaces */}
                {window.location.hostname.includes('github.dev') && (
                  <div className="mb-6 rounded-lg bg-yellow-50 p-4 border border-yellow-200">
                    <h3 className="text-yellow-800 font-medium mb-2">🔧 Codespaces Debug Info</h3>
                    <div className="text-sm text-yellow-700 space-y-1">
                      <p>• Content Actor: {contentActor ? '✅ Loaded' : '❌ Not loaded'}</p>
                      <p>• User Profile: {userProfile ? '✅ Set' : '❌ Not set'}</p>
                      <p>• Is Logged In: {isLoggedIn ? '✅ Yes' : '❌ No'}</p>
                      <p>• Environment: Codespaces (Anonymous Identity)</p>
                    </div>
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
          } />
        </Routes>
        
        {/* Toast Notification */}
        {toast && (
          <Toast
            message={toast.message}
            type={toast.type}
            duration={toast.duration}
            onClose={() => setToast(null)}
          />
        )}
      </div>
    </Router>
  );
}

export default App;

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
