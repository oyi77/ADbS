import React, { useState, useEffect } from 'react';

const TaskList = () => {
    const [tasks, setTasks] = useState([]);
    const [loading, setLoading] = useState(true);

    // Fetch from the actual ADbS API
    useEffect(() => {
        const fetchTasks = async () => {
            try {
                // Use relative path to leverage the proxy in development (package.json)
                // and same-origin in production.
                const apiUrl = '/api/tasks';

                const response = await fetch(apiUrl);
                if (!response.ok) {
                    throw new Error('Failed to fetch tasks');
                }

                const data = await response.json();

                // Map the ADbS task structure to the component's expected structure
                // ADbS tasks have 'description' instead of 'title'
                const mappedTasks = (data.tasks || []).map(task => ({
                    ...task,
                    title: task.description || 'Untitled Task'
                }));

                setTasks(mappedTasks);
            } catch (error) {
                console.error('Error fetching tasks:', error);
                // Fallback or empty state could be handled here
                setTasks([]);
            } finally {
                setLoading(false);
            }
        };

        fetchTasks();
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
