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
  const [usernameAvailability, setUsernameAvailability] = useState(null);
  const [isCheckingUsername, setIsCheckingUsername] = useState(false);
  const [socialGraphActor, setSocialGraphActor] = useState(null);

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
        
        // Try to import the content actor
        const { content, createActor } = await import('../../src/declarations/content');
        
        let contentActor = content;
        
        // If content is undefined, try to create it manually
        if (!contentActor) {
          console.log('⚠️ Content actor is undefined, trying to create manually...');
          const canisterId = "u6s2n-gx777-77774-qaaba-cai";
          contentActor = createActor(canisterId);
          console.log('🔧 Created content actor manually with canister ID:', canisterId);
        }
        
        if (!contentActor) {
          console.error('❌ Failed to create content actor');
          return;
        }
        
        setContentActor(contentActor);
        
        // Test the connection
        try {
          const testResult = await contentActor.getPosts(1, 0);
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
    
    // Initialize social graph actor
    const initSocialGraphActor = async () => {
      try {
        console.log('🔄 Initializing social graph actor...');
        const { socialgraph } = await import('../../src/declarations/socialgraph');
        setSocialGraphActor(socialgraph);
        console.log('✅ Social graph actor initialized successfully');
      } catch (err) {
        console.error('❌ Failed to initialize social graph actor:', err);
      }
    };
    initSocialGraphActor();
  }, []);



  const handleBackendActorSet = async (actor, principal) => {
    setBackendActor(actor);
    setUserPrincipal(principal);
    setIsLoggedIn(true);
    
    // Try to load existing user profile
    try {
      console.log("🔄 Loading existing user profile...");
      const profileResult = await actor.getCurrentUserProfile();
      if ('ok' in profileResult) {
        console.log("✅ Found existing profile:", profileResult.ok);
        console.log("🔍 Profile ID type:", typeof profileResult.ok.id);
        console.log("🔍 Profile ID value:", profileResult.ok.id);
        setUserProfile(profileResult.ok);
        setToast({
          message: `Welcome back, ${profileResult.ok.name}!`,
          type: 'success',
          duration: 4000
        });
      } else {
        console.log("ℹ️ No existing profile found, user needs to set up profile");
        setToast({
          message: `Logged in successfully!\nPrincipal: ${principal}\nPlease set up your profile.`,
          type: 'success',
          duration: 4000
        });
      }
    } catch (profileError) {
      console.log("ℹ️ Error loading profile (user may not have one yet):", profileError);
      setToast({
        message: `Logged in successfully!\nPrincipal: ${principal}\nPlease set up your profile.`,
        type: 'success',
        duration: 4000
      });
    }
  };

  const handleLogout = () => {
    // Clear all user state
    setBackendActor(null);
    setUserPrincipal(null);
    setIsLoggedIn(false);
    setUserProfile(null);
    setProfileForm({ username: '', bio: '' });
    setUsernameAvailability(null);
    
    // Clear localStorage session key for fresh identity on next login
    localStorage.removeItem('chainedsocial_session_key');
    
    // Show logout message
    setToast({
      message: 'Logged out successfully!',
      type: 'success',
      duration: 3000
    });
  };

  // Check username availability with debouncing
  const checkUsernameAvailability = async (username) => {
    if (!backendActor || !username.trim()) {
      setUsernameAvailability(null);
      return;
    }

    // Don't check if it's the current user's username
    if (userProfile && userProfile.name === username) {
      setUsernameAvailability('current');
      return;
    }

    setIsCheckingUsername(true);
    try {
      const result = await backendActor.isUsernameAvailable(username);
      setUsernameAvailability(result);
    } catch (error) {
      console.error('Error checking username availability:', error);
      setUsernameAvailability(null);
    } finally {
      setIsCheckingUsername(false);
    }
  };

  // Debounced username check
  useEffect(() => {
    const timeoutId = setTimeout(() => {
      if (profileForm.username.trim()) {
        checkUsernameAvailability(profileForm.username);
      } else {
        setUsernameAvailability(null);
      }
    }, 500); // 500ms delay

    return () => clearTimeout(timeoutId);
  }, [profileForm.username, backendActor, userProfile]);

  const handleSetProfile = async (e) => {
    e.preventDefault();
    if (!backendActor || !profileForm.username.trim()) return;

    setIsSettingProfile(true);
    try {
      console.log("🔄 Setting profile with:", { username: profileForm.username, bio: profileForm.bio });
      const result = await backendActor.setUserProfile(profileForm.username, profileForm.bio);
      console.log("✅ Profile set result:", result);
      if ('ok' in result) {
        console.log("✅ Profile set result:", result.ok);
        console.log("🔍 Set Profile ID type:", typeof result.ok.id);
        console.log("🔍 Set Profile ID value:", result.ok.id);
        setUserProfile(result.ok);
        setProfileForm({ username: '', bio: '' });
        setToast({
          message: 'Profile saved successfully!',
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
      message: 'Post created successfully!',
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
          onLogout={handleLogout}
        />
        
        <Routes>
          <Route path="/profile/:username" element={
            <Profile 
              contentActor={contentActor}
              socialGraphActor={socialGraphActor}
              userProfile={userProfile}
              isLoggedIn={isLoggedIn}
              userPrincipal={userPrincipal}
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
                        <div className="relative">
                          <input
                            type="text"
                            id="username"
                            value={profileForm.username}
                            onChange={(e) => setProfileForm({ ...profileForm, username: e.target.value })}
                            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
                              usernameAvailability === false 
                                ? 'border-red-300 focus:ring-red-500' 
                                : usernameAvailability === true 
                                ? 'border-green-300 focus:ring-green-500'
                                : 'border-gray-300'
                            }`}
                            placeholder="Enter your username"
                            required
                          />
                          {isCheckingUsername && (
                            <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
                              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-500"></div>
                            </div>
                          )}
                          {usernameAvailability === true && !isCheckingUsername && (
                            <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
                              <svg className="h-4 w-4 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                              </svg>
                            </div>
                          )}
                          {usernameAvailability === false && !isCheckingUsername && (
                            <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
                              <svg className="h-4 w-4 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                              </svg>
                            </div>
                          )}
                        </div>
                        {usernameAvailability === true && !isCheckingUsername && (
                          <p className="text-sm text-green-600 mt-1">✅ Username is available</p>
                        )}
                        {usernameAvailability === false && !isCheckingUsername && (
                          <p className="text-sm text-red-600 mt-1">❌ Username is already taken</p>
                        )}
                        {usernameAvailability === 'current' && !isCheckingUsername && (
                          <p className="text-sm text-blue-600 mt-1">ℹ️ This is your current username</p>
                        )}
                        {isCheckingUsername && (
                          <p className="text-sm text-gray-500 mt-1">🔄 Checking availability...</p>
                        )}
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
                        disabled={isSettingProfile || !profileForm.username.trim() || usernameAvailability === false}
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
                  <p className="text-purple-600 text-sm">ID: {userProfile.id?.toString() || 'N/A'}</p>
                </div>
              </div>
              <div className="flex space-x-2">
                <Link 
                  to={`/profile/${userProfile.name}`}
                  className="inline-block px-4 py-2 bg-purple-500 text-white rounded-md hover:bg-purple-600 transition-colors text-sm"
                >
                  View Full Profile →
                </Link>
                <button
                  onClick={() => setProfileForm({ username: userProfile.name, bio: userProfile.bio || '' })}
                  className="inline-block px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors text-sm"
                >
                  Edit Profile
                </button>
              </div>
            </div>
          )}

          {/* Profile Edit Form */}
          {userProfile && profileForm.username && (
            <div className="mb-6 rounded-lg bg-yellow-50 p-4 border border-yellow-200">
              <h3 className="text-yellow-800 font-medium mb-3">✏️ Edit Your Profile</h3>
              <form onSubmit={handleSetProfile} className="space-y-3">
                <div>
                  <label htmlFor="edit-username" className="block text-sm font-medium text-gray-700 mb-1">
                    Username
                  </label>
                  <div className="relative">
                    <input
                      type="text"
                      id="edit-username"
                      value={profileForm.username}
                      onChange={(e) => setProfileForm({ ...profileForm, username: e.target.value })}
                      className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
                        usernameAvailability === false 
                          ? 'border-red-300 focus:ring-red-500' 
                          : usernameAvailability === true 
                          ? 'border-green-300 focus:ring-green-500'
                          : 'border-gray-300'
                      }`}
                      placeholder="Enter your username"
                      required
                    />
                    {isCheckingUsername && (
                      <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
                        <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-500"></div>
                      </div>
                    )}
                    {usernameAvailability === true && !isCheckingUsername && (
                      <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
                        <svg className="h-4 w-4 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                        </svg>
                      </div>
                    )}
                    {usernameAvailability === false && !isCheckingUsername && (
                      <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
                        <svg className="h-4 w-4 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                        </svg>
                      </div>
                    )}
                  </div>
                  {usernameAvailability === true && !isCheckingUsername && (
                    <p className="text-sm text-green-600 mt-1">✅ Username is available</p>
                  )}
                  {usernameAvailability === false && !isCheckingUsername && (
                    <p className="text-sm text-red-600 mt-1">❌ Username is already taken</p>
                  )}
                  {usernameAvailability === 'current' && !isCheckingUsername && (
                    <p className="text-sm text-blue-600 mt-1">ℹ️ This is your current username</p>
                  )}
                  {isCheckingUsername && (
                    <p className="text-sm text-gray-500 mt-1">🔄 Checking availability...</p>
                  )}
                </div>
                <div>
                  <label htmlFor="edit-bio" className="block text-sm font-medium text-gray-700 mb-1">
                    Bio
                  </label>
                  <textarea
                    id="edit-bio"
                    value={profileForm.bio}
                    onChange={(e) => setProfileForm({ ...profileForm, bio: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Tell us about yourself..."
                    rows="3"
                  />
                </div>
                <div className="flex space-x-2">
                  <button
                    type="submit"
                    disabled={isSettingProfile || !profileForm.username.trim() || usernameAvailability === false}
                    className="flex-1 px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isSettingProfile ? '🔄 Updating Profile...' : '💾 Update Profile'}
                  </button>
                  <button
                    type="button"
                    onClick={() => setProfileForm({ username: '', bio: '' })}
                    className="px-4 py-2 bg-gray-500 text-white rounded-md hover:bg-gray-600 transition-colors"
                  >
                    Cancel
                  </button>
                </div>
              </form>
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
