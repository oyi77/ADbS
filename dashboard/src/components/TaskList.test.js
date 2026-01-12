import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import TaskList from './TaskList';

// Mock fetch
global.fetch = jest.fn();

describe('TaskList', () => {
    beforeEach(() => {
        fetch.mockClear();
    });

    test('renders loading state initially', () => {
        fetch.mockImplementationOnce(() => new Promise(() => {})); // Never resolves
        render(<TaskList />);
        expect(screen.getByText(/Loading Tasks/i)).toBeInTheDocument();
    });

    test('renders tasks from API', async () => {
        const mockTasks = {
            tasks: [
                { id: '1', description: 'Test Task 1', status: 'todo', priority: 'high' },
                { id: '2', description: 'Test Task 2', status: 'done', priority: 'low' }
            ]
        };

        fetch.mockResolvedValueOnce({
            ok: true,
            json: async () => mockTasks,
        });

        render(<TaskList />);

        // Wait for tasks to load
        await waitFor(() => {
            expect(screen.getByText('Test Task 1')).toBeInTheDocument();
            expect(screen.getByText('Test Task 2')).toBeInTheDocument();
        });

        // Check mapping (description -> title)
        expect(screen.getByText('Test Task 1')).toBeInTheDocument();
    });

    test('handles API error', async () => {
        fetch.mockRejectedValueOnce(new Error('API Error'));

        render(<TaskList />);

        // Wait for loading to finish (should result in empty list or error state)
        await waitFor(() => {
            expect(screen.queryByText(/Loading Tasks/i)).not.toBeInTheDocument();
        });

        // Since we set tasks to [] on error, list should be empty (but component still renders)
        expect(screen.getByText(/Project Tasks/i)).toBeInTheDocument();
    });
});
