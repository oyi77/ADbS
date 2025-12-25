import React from 'react';
import './App.css';
import TaskList from './components/TaskList';

function App() {
    return (
        <div className="App">
            <header className="App-header" style={{ backgroundColor: '#282c34', padding: '20px', color: 'white' }}>
                <h1>ADbS Dashboard</h1>
                <p>Project Health & Analytics</p>
            </header>
            <main style={{ padding: '20px', maxWidth: '800px', margin: '0 auto' }}>
                <div className="dashboard-grid" style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '20px' }}>
                    <div className="card">
                        <h3>Current Stage: <span style={{ color: '#61dafb' }}>Implementation</span></h3>
                    </div>

                    <TaskList />
                </div>
            </main>
        </div>
    );
}

export default App;
