import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';

const NewConversationModal = ({ onClose, onCreateConversation }) => {
    const { identity } = useAuth();
    const [searchTerm, setSearchTerm] = useState('');
    const [selectedUsers, setSelectedUsers] = useState([]);
    const [isGroup, setIsGroup] = useState(false);
    const [groupTitle, setGroupTitle] = useState('');
    const [initialMessage, setInitialMessage] = useState('');
    const [loading, setLoading] = useState(false);
    const [searchResults, setSearchResults] = useState([]);
    const [backendActor, setBackendActor] = useState(null);

    // Initialize backend actor for user search
    useEffect(() => {
        const initBackendActor = async () => {
            try {
                const { backend } = await import('../declarations/backend');
                setBackendActor(backend);
            } catch (error) {
                console.error('Failed to initialize backend actor:', error);
            }
        };
        initBackendActor();
    }, []);

    // Search for users
    useEffect(() => {
        const searchUsers = async () => {
            if (!backendActor || searchTerm.length < 2) {
                setSearchResults([]);
                return;
            }

            try {
                // In a real implementation, you'd have a search users API
                // For now, we'll simulate user search results
                const mockUsers = [
                    { username: 'alice', principal: 'alice-principal-id' },
                    { username: 'bob', principal: 'bob-principal-id' },
                    { username: 'charlie', principal: 'charlie-principal-id' },
                    { username: 'diana', principal: 'diana-principal-id' },
                    { username: 'eve', principal: 'eve-principal-id' },
                ];

                const filtered = mockUsers.filter(user => 
                    user.username.toLowerCase().includes(searchTerm.toLowerCase()) &&
                    !selectedUsers.some(selected => selected.principal === user.principal)
                );

                setSearchResults(filtered);
            } catch (error) {
                console.error('Error searching users:', error);
                setSearchResults([]);
            }
        };

        const debounceTimer = setTimeout(searchUsers, 300);
        return () => clearTimeout(debounceTimer);
    }, [searchTerm, selectedUsers, backendActor]);

    const handleUserSelect = (user) => {
        setSelectedUsers(prev => [...prev, user]);
        setSearchTerm('');
        setSearchResults([]);
    };

    const handleUserRemove = (userToRemove) => {
        setSelectedUsers(prev => prev.filter(user => user.principal !== userToRemove.principal));
    };

    const handleCreateConversation = async () => {
        if (selectedUsers.length === 0) {
            alert('Please select at least one user to start a conversation');
            return;
        }

        if (isGroup && !groupTitle.trim()) {
            alert('Please enter a title for the group chat');
            return;
        }

        if (selectedUsers.length > 1 && !isGroup) {
            setIsGroup(true);
            return;
        }

        setLoading(true);

        try {
            const participants = selectedUsers.map(user => user.principal);
            const participantNames = selectedUsers.map(user => user.username);

            await onCreateConversation(
                participants,
                participantNames,
                isGroup ? groupTitle : null,
                isGroup,
                initialMessage.trim() || null
            );
        } catch (error) {
            console.error('Failed to create conversation:', error);
            alert('Failed to create conversation. Please try again.');
        } finally {
            setLoading(false);
        }
    };

    const getInitials = (name) => {
        return name
            .split(' ')
            .map(word => word.charAt(0))
            .join('')
            .toUpperCase()
            .slice(0, 2);
    };

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg shadow-xl max-w-md w-full mx-4 max-h-[90vh] overflow-hidden">
                {/* Header */}
                <div className="px-6 py-4 border-b border-gray-200">
                    <div className="flex items-center justify-between">
                        <h3 className="text-lg font-semibold text-gray-900">
                            New Conversation
                        </h3>
                        <button
                            onClick={onClose}
                            className="text-gray-400 hover:text-gray-600"
                        >
                            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                </div>

                {/* Body */}
                <div className="px-6 py-4 space-y-4 max-h-96 overflow-y-auto">
                    {/* User search */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                            Search users
                        </label>
                        <input
                            type="text"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            placeholder="Type username to search..."
                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        />
                        
                        {/* Search results */}
                        {searchResults.length > 0 && (
                            <div className="mt-2 border border-gray-200 rounded-md max-h-32 overflow-y-auto">
                                {searchResults.map((user) => (
                                    <button
                                        key={user.principal}
                                        onClick={() => handleUserSelect(user)}
                                        className="w-full px-3 py-2 text-left hover:bg-gray-50 flex items-center space-x-3"
                                    >
                                        <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-teal-500 rounded-full flex items-center justify-center text-white font-medium text-xs">
                                            {getInitials(user.username)}
                                        </div>
                                        <span className="text-sm text-gray-900">{user.username}</span>
                                    </button>
                                ))}
                            </div>
                        )}
                    </div>

                    {/* Selected users */}
                    {selectedUsers.length > 0 && (
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                Selected users ({selectedUsers.length})
                            </label>
                            <div className="flex flex-wrap gap-2">
                                {selectedUsers.map((user) => (
                                    <div
                                        key={user.principal}
                                        className="inline-flex items-center px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm"
                                    >
                                        <div className="w-5 h-5 bg-blue-500 rounded-full flex items-center justify-center text-white font-medium text-xs mr-2">
                                            {getInitials(user.username)}
                                        </div>
                                        {user.username}
                                        <button
                                            onClick={() => handleUserRemove(user)}
                                            className="ml-2 text-blue-600 hover:text-blue-800"
                                        >
                                            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                                            </svg>
                                        </button>
                                    </div>
                                ))}
                            </div>
                        </div>
                    )}

                    {/* Group chat toggle */}
                    {selectedUsers.length > 1 && (
                        <div className="flex items-center">
                            <input
                                type="checkbox"
                                id="isGroup"
                                checked={isGroup}
                                onChange={(e) => setIsGroup(e.target.checked)}
                                className="mr-3"
                            />
                            <label htmlFor="isGroup" className="text-sm text-gray-700">
                                Create group chat
                            </label>
                        </div>
                    )}

                    {/* Group title */}
                    {isGroup && (
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                Group title
                            </label>
                            <input
                                type="text"
                                value={groupTitle}
                                onChange={(e) => setGroupTitle(e.target.value)}
                                placeholder="Enter group title..."
                                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                maxLength={50}
                            />
                        </div>
                    )}

                    {/* Initial message */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                            Initial message (optional)
                        </label>
                        <textarea
                            value={initialMessage}
                            onChange={(e) => setInitialMessage(e.target.value)}
                            placeholder="Type your first message..."
                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
                            rows="3"
                            maxLength={500}
                        />
                    </div>
                </div>

                {/* Footer */}
                <div className="px-6 py-4 border-t border-gray-200 flex justify-end space-x-3">
                    <button
                        onClick={onClose}
                        disabled={loading}
                        className="px-4 py-2 text-sm font-medium text-gray-700 border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50"
                    >
                        Cancel
                    </button>
                    <button
                        onClick={handleCreateConversation}
                        disabled={loading || selectedUsers.length === 0}
                        className="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                        {loading ? (
                            <div className="flex items-center">
                                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                                Creating...
                            </div>
                        ) : (
                            'Start Conversation'
                        )}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default NewConversationModal;