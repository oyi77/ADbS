import React, { useState, useEffect } from 'react';

const TaskList = () => {
    const [tasks, setTasks] = useState([]);
    const [loading, setLoading] = useState(true);

    // In a real app, this would fetch from an API
    // For MVP, we mock the data structure expected from ADbS
    useEffect(() => {
        const mockTasks = [
            { id: 1, title: "Initialize Project", status: "completed", priority: "high" },
            { id: 2, title: "Setup Testing", status: "completed", priority: "critical" },
            { id: 3, title: "Create Distribution Packages", status: "in-progress", priority: "high" },
            { id: 4, title: "VS Code Extension", status: "pending", priority: "medium" }
        ];

        // Simulate delay
        setTimeout(() => {
            setTasks(mockTasks);
            setLoading(false);
        }, 800);
    }, []);

    if (loading) return <div>Loading Tasks...</div>;

    const getStatusColor = (status) => {
        switch (status) {
            case 'completed': return 'green';
            case 'in-progress': return 'blue';
            case 'pending': return 'gray';
            default: return 'black';
        }
    };

    return (
        <div style={{ padding: '20px', border: '1px solid #ccc', borderRadius: '8px' }}>
            <h2>Project Tasks</h2>
            <ul style={{ listStyle: 'none', padding: 0 }}>
                {tasks.map(task => (
                    <li key={task.id} style={{
                        margin: '10px 0',
                        padding: '10px',
                        borderLeft: `4px solid ${getStatusColor(task.status)}`,
                        backgroundColor: '#f9f9f9'
                    }}>
                        <strong>{task.title}</strong>
                        <span style={{ float: 'right', fontSize: '0.8em', textTransform: 'uppercase' }}>
                            {task.status}
                        </span>
                    </li>
                ))}
            </ul>
        </div>
    );
};

export default TaskList;
