import React from 'react';
import NfidLogin from './Nfidlogin';

function Header({ isLoggedIn, userPrincipal, userProfile, setBackendActor }) {
  return (
    <header className="sticky top-0 z-50 w-full border-b bg-white/80 backdrop-blur-sm shadow-sm">
      <div className="container mx-auto flex h-16 items-center justify-between px-4 max-w-4xl">
        {/* Logo */}
        <div className="flex items-center space-x-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-gradient-to-r from-blue-500 to-purple-600">
            <span className="text-sm font-bold text-white">IC</span>
          </div>
          <div>
            <h1 className="text-xl font-bold text-gray-900">Chained Social</h1>
            <p className="text-xs text-gray-500">Decentralized on ICP</p>
          </div>
        </div>

        {/* Search Bar */}
        <div className="hidden md:flex flex-1 max-w-md mx-8">
          <div className="relative w-full">
            <svg className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <input
              type="text"
              placeholder="Search posts, users..."
              className="w-full rounded-lg bg-gray-50 border-0 py-2 pl-10 pr-4 text-sm placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white"
            />
          </div>
        </div>

        {/* Right Side */}
        <div className="flex items-center space-x-3">
          {isLoggedIn ? (
            <>
              {/* Notifications */}
              <button className="relative p-2 text-gray-500 hover:text-gray-700 transition-colors">
                <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-5 5v-5z" />
                </svg>
                <span className="absolute -top-1 -right-1 h-3 w-3 rounded-full bg-red-500"></span>
              </button>
              
              {/* User Profile */}
              <div className="flex items-center space-x-2 rounded-lg bg-gray-50 px-3 py-1.5">
                <div className="h-6 w-6 rounded-full bg-gradient-to-r from-blue-500 to-purple-600 flex items-center justify-center">
                  <span className="text-xs font-bold text-white">
                    {userProfile ? userProfile.name.charAt(0).toUpperCase() : 'U'}
                  </span>
                </div>
                <span className="text-sm font-medium text-gray-700">
                  {userProfile ? userProfile.name : (userPrincipal ? `${userPrincipal.slice(0, 8)}...` : 'User')}
                </span>
              </div>
            </>
          ) : (
            <NfidLogin setBackendActor={setBackendActor} />
          )}
        </div>
      </div>
    </header>
  );
}

export default Header; 