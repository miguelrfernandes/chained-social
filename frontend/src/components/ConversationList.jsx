import React from 'react';
import { useAuth } from '../contexts/AuthContext';

const ConversationList = ({ conversations, currentConversation, onSelectConversation }) => {
    const { identity } = useAuth();

    const formatTimestamp = (timestamp) => {
        const date = new Date(Number(timestamp) / 1000000); // Convert nanoseconds to milliseconds
        const now = new Date();
        const diffMs = now - date;
        const diffMins = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMs / 3600000);
        const diffDays = Math.floor(diffMs / 86400000);

        if (diffMins < 1) return 'Just now';
        if (diffMins < 60) return `${diffMins}m`;
        if (diffHours < 24) return `${diffHours}h`;
        if (diffDays < 7) return `${diffDays}d`;
        
        return date.toLocaleDateString();
    };

    const getDisplayName = (conversation) => {
        if (conversation.isGroup) {
            return conversation.title || 'Group Chat';
        }
        
        // For direct messages, show the other participant's name
        const currentUserPrincipal = identity?.getPrincipal()?.toString();
        const otherParticipantIndex = conversation.participants.findIndex(
            participant => participant.toString() !== currentUserPrincipal
        );
        
        if (otherParticipantIndex !== -1 && otherParticipantIndex < conversation.participantNames.length) {
            return conversation.participantNames[otherParticipantIndex];
        }
        
        return 'Unknown User';
    };

    const getUnreadCount = (conversation) => {
        if (!identity) return 0;
        
        const currentUserPrincipal = identity.getPrincipal().toString();
        const userUnread = conversation.unreadCounts.find(
            ([userId, _]) => userId.toString() === currentUserPrincipal
        );
        
        return userUnread ? userUnread[1] : 0;
    };

    const getInitials = (name) => {
        return name
            .split(' ')
            .map(word => word.charAt(0))
            .join('')
            .toUpperCase()
            .slice(0, 2);
    };

    if (conversations.length === 0) {
        return (
            <div className="flex items-center justify-center h-32 text-gray-500">
                <div className="text-center">
                    <svg className="mx-auto h-8 w-8 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                    </svg>
                    <p className="text-sm">No conversations yet</p>
                </div>
            </div>
        );
    }

    return (
        <div className="space-y-1 p-2">
            {conversations.map((conversation) => {
                const isActive = currentConversation?.id === conversation.id;
                const displayName = getDisplayName(conversation);
                const unreadCount = getUnreadCount(conversation);
                const initials = getInitials(displayName);

                return (
                    <div
                        key={conversation.id}
                        onClick={() => onSelectConversation(conversation)}
                        className={`
                            relative flex items-center p-3 rounded-lg cursor-pointer transition-colors
                            ${isActive 
                                ? 'bg-blue-100 border-l-4 border-blue-500' 
                                : 'hover:bg-gray-100'
                            }
                        `}
                    >
                        {/* Avatar */}
                        <div className="flex-shrink-0 mr-3">
                            {conversation.isGroup ? (
                                <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center text-white font-medium text-sm">
                                    <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                                        <path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3zM6 8a2 2 0 11-4 0 2 2 0 014 0zM16 18v-3a5.972 5.972 0 00-.75-2.906A3.005 3.005 0 0119 15v3h-3z" />
                                    </svg>
                                </div>
                            ) : (
                                <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-teal-500 rounded-full flex items-center justify-center text-white font-medium text-sm">
                                    {initials}
                                </div>
                            )}
                        </div>

                        {/* Content */}
                        <div className="flex-1 min-w-0">
                            <div className="flex items-center justify-between">
                                <h4 className={`text-sm font-medium truncate ${isActive ? 'text-blue-900' : 'text-gray-900'}`}>
                                    {displayName}
                                </h4>
                                <span className={`text-xs ${isActive ? 'text-blue-700' : 'text-gray-500'}`}>
                                    {formatTimestamp(conversation.lastMessageAt)}
                                </span>
                            </div>
                            
                            <div className="flex items-center justify-between mt-1">
                                <p className={`text-sm truncate ${isActive ? 'text-blue-700' : 'text-gray-600'}`}>
                                    {conversation.lastMessage || 'No messages yet'}
                                </p>
                                
                                {unreadCount > 0 && (
                                    <span className="inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white bg-red-500 rounded-full">
                                        {unreadCount > 99 ? '99+' : unreadCount}
                                    </span>
                                )}
                            </div>
                        </div>

                        {/* Active indicator */}
                        {isActive && (
                            <div className="absolute right-2 top-1/2 transform -translate-y-1/2">
                                <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                            </div>
                        )}
                    </div>
                );
            })}
        </div>
    );
};

export default ConversationList;