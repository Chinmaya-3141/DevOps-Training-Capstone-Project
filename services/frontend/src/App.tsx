import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

interface Item {
  _id: string;
  name: string;
  description: string;
  createdAt: string;
}

function App() {
  const [items, setItems] = useState<Item[]>([]);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const API_BASE = process.env.REACT_APP_API_URL || '/api';

  useEffect(() => {
    fetchItems();
  }, []);

  const fetchItems = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_BASE}/items`);
      setItems(response.data);
    } catch (err) {
      setError('Failed to fetch items');
      console.error('Error fetching items:', err);
    } finally {
      setLoading(false);
    }
  };

  const addItem = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !description.trim()) {
      setError('Please fill in all fields');
      return;
    }

    try {
      setLoading(true);
      const response = await axios.post(`${API_BASE}/items`, {
        name: name.trim(),
        description: description.trim()
      });
      setItems([response.data, ...items]);
      setName('');
      setDescription('');
      setError('');
    } catch (err) {
      setError('Failed to add item');
      console.error('Error adding item:', err);
    } finally {
      setLoading(false);
    }
  };

  const checkBackendHealth = async () => {
    try {
      const response = await axios.get(`${API_BASE.replace('/api', '')}/health`);
      console.log('Backend health:', response.data);
      alert(`Backend is healthy! Status: ${response.data.status}`);
    } catch (err) {
      console.error('Backend health check failed:', err);
      alert('Backend health check failed. Please check the console for details.');
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>DevOps Capstone Project</h1>
        <p>Microservices Demo Application</p>
      </header>
      
      <main className="container">
        <div className="health-check">
          <button onClick={checkBackendHealth} className="health-btn">
            Check Backend Health
          </button>
        </div>

        <div className="add-item-form">
          <h2>Add New Item</h2>
          {error && <div className="error">{error}</div>}
          <form onSubmit={addItem}>
            <div className="form-group">
              <input
                type="text"
                placeholder="Item name"
                value={name}
                onChange={(e) => setName(e.target.value)}
                disabled={loading}
              />
            </div>
            <div className="form-group">
              <textarea
                placeholder="Item description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                disabled={loading}
              />
            </div>
            <button type="submit" disabled={loading}>
              {loading ? 'Adding...' : 'Add Item'}
            </button>
          </form>
        </div>

        <div className="items-list">
          <h2>Items ({items.length})</h2>
          {loading && items.length === 0 && <p>Loading items...</p>}
          {items.length === 0 && !loading && (
            <p>No items yet. Add the first item above!</p>
          )}
          {items.map((item) => (
            <div key={item._id} className="item-card">
              <h3>{item.name}</h3>
              <p>{item.description}</p>
              <small>Created: {new Date(item.createdAt).toLocaleString()}</small>
            </div>
          ))}
        </div>
      </main>

      <footer>
        <p>Built with React • Node.js • MongoDB • Kubernetes</p>
        <p>Environment: {process.env.NODE_ENV}</p>
      </footer>
    </div>
  );
}

export default App;