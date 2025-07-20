import React, { createContext, useContext, useState, useEffect } from 'react';
import { useLogin } from '../hooks/useLogin';

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [backendActor, setBackendActor] = useState(null);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [userPrincipal, setUserPrincipal] = useState(null);
  const [userProfile, setUserProfile] = useState(null);
  const [profileForm, setProfileForm] = useState({ username: '', bio: '' });
  const [usernameAvailability, setUsernameAvailability] = useState(null);
  const [isCheckingUsername, setIsCheckingUsername] = useState(false);
  const [isSettingProfile, setIsSettingProfile] = useState(false);

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
        window.showToast?.({
          message: `Welcome back, ${profileResult.ok.name}!`,
          type: 'success',
          duration: 4000
        });
      } else {
        console.log("ℹ️ No existing profile found, user needs to set up profile");
        window.showToast?.({
          message: `Logged in successfully!\nPrincipal: ${principal}\nPlease set up your profile.`,
          type: 'success',
          duration: 4000
        });
      }
    } catch (profileError) {
      console.log("ℹ️ Error loading profile (user may not have one yet):", profileError);
      window.showToast?.({
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
    window.showToast?.({
      message: 'Logged out successfully!',
      type: 'success',
      duration: 3000
    });
  };

  // Use shared login hook
  const { handleLogin, isLoggingIn, loginError, setLoginError } = useLogin(handleBackendActorSet);

  // Show login errors as toasts
  useEffect(() => {
    if (loginError) {
      window.showToast?.({
        message: loginError,
        type: 'error',
        duration: 5000
      });
      setLoginError(null); // Clear the error after showing toast
    }
  }, [loginError, setLoginError]);

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
        window.showToast?.({
          message: 'Profile saved successfully!',
          type: 'success',
          duration: 3000
        });
      } else {
        window.showToast?.({
          message: `❌ Failed to save profile: ${result.err}`,
          type: 'error',
          duration: 5000
        });
      }
    } catch (error) {
      console.error("❌ Error setting profile:", error);
      window.showToast?.({
        message: `❌ Error setting profile: ${error.message}`,
        type: 'error',
        duration: 5000
      });
    } finally {
      setIsSettingProfile(false);
    }
  };

  const value = {
    // State
    backendActor,
    isLoggedIn,
    userPrincipal,
    userProfile,
    profileForm,
    setProfileForm,
    usernameAvailability,
    isCheckingUsername,
    isSettingProfile,
    isLoggingIn,
    loginError,
    
    // Functions
    handleLogin,
    handleLogout,
    checkUsernameAvailability,
    handleSetProfile,
    setLoginError
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

// Custom hook for consuming the context
export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
} 