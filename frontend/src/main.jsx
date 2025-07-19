import React, { useState, useEffect } from 'react';
import ReactDOM from 'react-dom/client';
import '../index.css';
import NfidLogin from './components/Nfidlogin';

function App() {
  const [posts, setPosts] = useState(null);
  const [users, setUsers] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);
  const [backendActor, setBackendActor] = useState(null);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [userPrincipal, setUserPrincipal] = useState(null);
  const [userProfile, setUserProfile] = useState(null);
  const [isSettingProfile, setIsSettingProfile] = useState(false);
  const [profileForm, setProfileForm] = useState({ username: '', bio: '' });

  useEffect(() => {
    const fetchData = async () => {
      setIsLoading(true);
      try {
        // Fetch posts and users in parallel
        const [postsRes, usersRes] = await Promise.all([
          fetch('https://jsonplaceholder.typicode.com/posts'),
          fetch('https://randomuser.me/api/?results=5'),
        ]);
        if (!postsRes.ok || !usersRes.ok) {
          throw new Error('Network response was not ok');
        }
        const postsData = await postsRes.json();
        const usersData = await usersRes.json();
        setPosts(postsData.slice(0, 5));
        setUsers(usersData.results);
      } catch (err) {
        setError(err.message);
      } finally {
        setIsLoading(false);
      }
    };
    fetchData();
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
      const result = await backendActor.setUserProfile(profileForm.username, profileForm.bio);
      if ('ok' in result) {
        setUserProfile(result.ok);
        setProfileForm({ username: '', bio: '' });
      } else {
        setError('Failed to set profile: ' + result.err);
      }
    } catch (err) {
      setError('Error setting profile: ' + err.message);
    } finally {
      setIsSettingProfile(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-r from-blue-400 to-purple-500">
      <div className="w-full max-w-md rounded-lg bg-white p-8 shadow-lg">
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
        
        <h1 className="mb-4 text-center text-3xl font-bold text-gray-800">🚀 Chained Social: Crypto Social Network on ICP! 🚀</h1>
        <p className="text-center text-gray-600">
          A social network hosted onchain on ICP.
        </p>
        {isLoading && <p className="mt-4 text-center text-gray-600">Loading...</p>}
        {error && <p className="mt-4 text-center text-red-500">Error: {error}</p>}
        {posts && users && (
          <div className="mt-6 flex flex-col gap-4">
            {posts.map((post, idx) => {
              const user = users[idx];
              return (
                <div key={post.id} className="flex items-start gap-3 rounded-lg bg-gray-50 p-4 shadow-sm hover:shadow-md transition-shadow">
                  <img
                    src={user.picture.large}
                    alt={user.login.username}
                    className="h-12 w-12 rounded-full border border-gray-200 object-cover"
                  />
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <span className="font-semibold text-gray-800">{user.name.first} {user.name.last}</span>
                      <span className="text-xs text-gray-400">· @{user.login.username}</span>
                    </div>
                    <h3 className="mt-1 text-base font-medium text-gray-900">{post.title}</h3>
                    <p className="mt-1 text-sm text-gray-700">{post.body.slice(0, 100)}...</p>
                  </div>
                </div>
              );
            })}
          </div>
        )}
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
