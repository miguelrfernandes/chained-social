import React, { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useMessaging } from '../contexts/MessagingContext';

const MessageList = ({ messages }) => {
    const { identity } = useAuth();
    const { editMessage, deleteMessage } = useMessaging();
    const [editingMessageId, setEditingMessageId] = useState(null);
    const [editContent, setEditContent] = useState('');

    const formatTimestamp = (timestamp) => {
        const date = new Date(Number(timestamp) / 1000000); // Convert nanoseconds to milliseconds
        const now = new Date();
        const diffMs = now - date;
        const diffMins = Math.floor(diffMs / 60000);
        
        if (diffMins < 1) return 'Just now';
        if (diffMins < 60) return `${diffMins}m ago`;
        if (diffMs < 86400000) return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        
        return date.toLocaleDateString([], { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
    };

    const isCurrentUser = (message) => {
        const currentUserPrincipal = identity?.getPrincipal()?.toString();
        return message.sender.toString() === currentUserPrincipal;
    };

    const handleEdit = (message) => {
        setEditingMessageId(message.id);
        setEditContent(message.content);
    };

    const handleSaveEdit = async (messageId) => {
        if (editContent.trim()) {
            await editMessage(messageId, editContent.trim());
        }
        setEditingMessageId(null);
        setEditContent('');
    };

    const handleCancelEdit = () => {
        setEditingMessageId(null);
        setEditContent('');
    };

    const handleDelete = async (messageId) => {
        if (window.confirm('Are you sure you want to delete this message?')) {
            await deleteMessage(messageId);
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

    const renderMessageContent = (message) => {
        if (message.messageType.system) {
            return (
                <div className="flex justify-center">
                    <span className="text-xs text-gray-500 bg-gray-100 px-3 py-1 rounded-full">
                        {message.content}
                    </span>
                </div>
            );
        }

        const isOwn = isCurrentUser(message);

        return (
            <div className={`flex ${isOwn ? 'justify-end' : 'justify-start'} mb-4`}>
                {!isOwn && (
                    <div className="flex-shrink-0 mr-3">
                        <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-teal-500 rounded-full flex items-center justify-center text-white font-medium text-xs">
                            {getInitials(message.senderName)}
                        </div>
                    </div>
                )}

                <div className={`max-w-xs lg:max-w-md xl:max-w-lg ${isOwn ? 'order-1' : 'order-2'}`}>
                    <div className={`
                        px-4 py-2 rounded-lg relative group
                        ${isOwn 
                            ? 'bg-blue-500 text-white' 
                            : 'bg-gray-100 text-gray-900'
                        }
                    `}>
                        {editingMessageId === message.id ? (
                            <div className="space-y-2">
                                <textarea
                                    value={editContent}
                                    onChange={(e) => setEditContent(e.target.value)}
                                    className="w-full p-2 text-sm border rounded resize-none text-gray-900"
                                    rows="2"
                                    autoFocus
                                />
                                <div className="flex justify-end space-x-2">
                                    <button
                                        onClick={handleCancelEdit}
                                        className="px-2 py-1 text-xs text-gray-600 hover:text-gray-800"
                                    >
                                        Cancel
                                    </button>
                                    <button
                                        onClick={() => handleSaveEdit(message.id)}
                                        className="px-2 py-1 text-xs bg-blue-500 text-white rounded hover:bg-blue-600"
                                    >
                                        Save
                                    </button>
                                </div>
                            </div>
                        ) : (
                            <>
                                <p className="text-sm break-words">{message.content}</p>
                                
                                {message.isEdited && (
                                    <span className={`text-xs opacity-75 ${isOwn ? 'text-blue-100' : 'text-gray-500'}`}>
                                        (edited)
                                    </span>
                                )}

                                {/* Message options */}
                                {isOwn && (
                                    <div className="absolute -right-16 top-0 opacity-0 group-hover:opacity-100 transition-opacity bg-white rounded-lg shadow-lg border flex">
                                        <button
                                            onClick={() => handleEdit(message)}
                                            className="p-2 text-gray-600 hover:text-blue-600 hover:bg-gray-50 rounded-l-lg"
                                            title="Edit message"
                                        >
                                            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                            </svg>
                                        </button>
                                        <button
                                            onClick={() => handleDelete(message.id)}
                                            className="p-2 text-gray-600 hover:text-red-600 hover:bg-gray-50 rounded-r-lg"
                                            title="Delete message"
                                        >
                                            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                            </svg>
                                        </button>
                                    </div>
                                )}
                            </>
                        )}
                    </div>

                    {/* Timestamp and sender info */}
                    <div className={`mt-1 text-xs text-gray-500 ${isOwn ? 'text-right' : 'text-left'}`}>
                        {!isOwn && <span className="font-medium">{message.senderName}</span>}
                        {!isOwn && ' • '}
                        <span>{formatTimestamp(message.timestamp)}</span>
                    </div>
                </div>

                {isOwn && (
                    <div className="flex-shrink-0 ml-3">
                        <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full flex items-center justify-center text-white font-medium text-xs">
                            {getInitials(message.senderName)}
                        </div>
                    </div>
                )}
            </div>
        );
    };

    if (messages.length === 0) {
        return (
            <div className="flex items-center justify-center h-32 text-gray-500">
                <div className="text-center">
                    <svg className="mx-auto h-8 w-8 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                    </svg>
                    <p className="text-sm">No messages yet</p>
                    <p className="text-xs text-gray-400 mt-1">Send a message to start the conversation</p>
                </div>
            </div>
        );
    }

    return (
        <div className="space-y-1">
            {messages.map((message) => (
                <div key={message.id}>
                    {renderMessageContent(message)}
                </div>
            ))}
        </div>
    );
};

export default MessageList;