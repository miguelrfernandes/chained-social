import React from 'react';
import { Shield, Users, Zap } from 'lucide-react';

function HeroSection({ onGetStarted, isLoggingIn = false }) {
  return (
    <div className="mb-8 rounded-lg bg-white border border-gray-200 shadow-sm overflow-hidden">
      <div className="p-8">
        <div className="grid lg:grid-cols-2 gap-8 items-center">
          {/* Left Content */}
          <div className="space-y-6">
            <div className="space-y-4">
              <h1 className="text-3xl md:text-5xl font-bold leading-tight">
                <span className="bg-gradient-to-r from-blue-500 to-purple-600 bg-clip-text text-transparent">
                  ChainedSocial
                </span>
              </h1>
              <p className="text-xl font-semibold text-gray-700">
                "Own Your Voice, Control Your Data"
              </p>
              <p className="text-gray-600 max-w-lg leading-relaxed">
                A truly decentralized social media ecosystem where users own their data, control their content, and participate in platform governance. Built on Internet Computer Protocol with NFID authentication.
              </p>
            </div>

            {/* Features */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
              <div className="flex flex-col items-center text-center space-y-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-50">
                  <Shield className="h-5 w-5 text-blue-600" />
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900">Own Your Data</h3>
                  <p className="text-sm text-gray-500">100% On-Chain</p>
                </div>
              </div>
              <div className="flex flex-col items-center text-center space-y-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-purple-50">
                  <Users className="h-5 w-5 text-purple-600" />
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900">Community DAO</h3>
                  <p className="text-sm text-gray-500">Governance</p>
                </div>
              </div>
              <div className="flex flex-col items-center text-center space-y-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-green-50">
                  <Zap className="h-5 w-5 text-green-600" />
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900">No Gas Fees</h3>
                  <p className="text-sm text-gray-500">ICP Network</p>
                </div>
              </div>
            </div>

            {/* CTA Buttons */}
            <div className="flex flex-col sm:flex-row gap-3">
              <button
                onClick={onGetStarted}
                disabled={isLoggingIn}
                className="px-4 py-2 bg-gradient-to-r from-blue-500 to-purple-600 text-white border-none rounded-lg cursor-pointer shadow-sm transition-all duration-300 hover:from-blue-600 hover:to-purple-700 disabled:opacity-50 disabled:cursor-not-allowed text-sm font-medium"
              >
                {isLoggingIn ? "🔄 Connecting..." : "Get Started"}
              </button>
              <button className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors text-sm font-medium">
                Learn More
              </button>
            </div>
          </div>

          {/* Right Content - Platform Preview */}
          <div className="relative">
            <div className="bg-gradient-to-br from-blue-50 to-purple-50 rounded-lg p-6 border border-gray-200">
              <div className="space-y-4">
                {/* Mock Post */}
                <div className="bg-white rounded-lg border border-gray-200 p-4 shadow-sm">
                  <div className="flex items-center space-x-3 mb-3">
                    <div className="h-8 w-8 rounded-full bg-gradient-to-r from-blue-500 to-purple-600 flex items-center justify-center">
                      <span className="text-xs font-bold text-white">U</span>
                    </div>
                    <div>
                      <p className="text-sm font-semibold text-gray-900">User</p>
                      <p className="text-xs text-gray-500">Just now</p>
                    </div>
                  </div>
                  <p className="text-sm text-gray-700">Welcome to ChainedSocial! 🚀 A truly decentralized social media platform where you own your data and control your content.</p>
                </div>
                
                {/* Mock Stats */}
                <div className="grid grid-cols-3 gap-4 text-center">
                  <div className="bg-white rounded-lg p-3 border border-gray-200">
                    <p className="text-lg font-bold text-blue-600">100%</p>
                    <p className="text-xs text-gray-500">On-Chain</p>
                  </div>
                  <div className="bg-white rounded-lg p-3 border border-gray-200">
                    <p className="text-lg font-bold text-purple-600">0</p>
                    <p className="text-xs text-gray-500">Gas Fees</p>
                  </div>
                  <div className="bg-white rounded-lg p-3 border border-gray-200">
                    <p className="text-lg font-bold text-green-600">∞</p>
                    <p className="text-xs text-gray-500">Scalable</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default HeroSection; 