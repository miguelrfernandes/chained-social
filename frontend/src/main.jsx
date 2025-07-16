import React, { useState, useEffect } from 'react';
import ReactDOM from 'react-dom/client';
import '../index.css';

function App() {
  const [posts, setPosts] = useState(null);
  const [users, setUsers] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);

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

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-r from-blue-400 to-purple-500">
      <div className="w-full max-w-md rounded-lg bg-white p-8 shadow-lg">
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
