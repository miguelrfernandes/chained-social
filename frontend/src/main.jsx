import React, { useState } from 'react';
import ReactDOM from 'react-dom/client';
import '../index.css';

function App() {
  const [data, setData] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);

  const fetchData = async () => {
    setIsLoading(true);
    try {
      const response = await fetch('https://jsonplaceholder.typicode.com/posts');
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      const result = await response.json();
      setData(result);
    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-r from-blue-400 to-purple-500">
      <div className="w-96 rounded-lg bg-white p-8 shadow-lg">
        <h1 className="mb-4 text-center text-3xl font-bold text-gray-800">🚀 Chained Social: Crypto Social Network on ICP! 🚀</h1>
        <p className="text-center text-gray-600">
          A social network hosted onchain on ICP.
        </p>
        <div className="mt-6 flex justify-center">
          <button onClick={fetchData} className="rounded bg-blue-600 px-4 py-2 font-bold text-white hover:bg-blue-700">
            Fetch Posts
          </button>
        </div>
        {isLoading && <p className="mt-4 text-center text-gray-600">Loading...</p>}
        {error && <p className="mt-4 text-center text-red-500">Error: {error}</p>}
        {data && (
          <div className="mt-4">
            {data.slice(0, 3).map(
              (
                post // Display only first 3 posts for brevity
              ) => (
                <div key={post.id} className="mb-2 rounded bg-gray-100 p-2">
                  <h3 className="text-lg font-semibold">{post.title}</h3>
                  <p className="text-sm">{post.body.slice(0, 100)}...</p>
                </div>
              )
            )}
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
