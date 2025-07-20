import React, { useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

function AuthUI() {
  const {
    isLoggedIn,
    userProfile,
    profileForm,
    setProfileForm,
    usernameAvailability,
    isCheckingUsername,
    isSettingProfile,
    handleSetProfile,
    checkUsernameAvailability
  } = useAuth();

  // Debounced username check
  useEffect(() => {
    const timeoutId = setTimeout(() => {
      if (profileForm.username.trim()) {
        checkUsernameAvailability(profileForm.username);
      }
    }, 500); // 500ms delay

    return () => clearTimeout(timeoutId);
  }, [profileForm.username, checkUsernameAvailability]);

  if (!isLoggedIn) {
    return null;
  }

  return (
    <>
      {/* Profile Setup Form */}
      {!userProfile && (
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
                  className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${usernameAvailability === false
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

      {/* User Profile Display */}
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
                  className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${usernameAvailability === false
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
    </>
  );
}

export default AuthUI; 