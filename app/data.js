// Data Management - Using Browser LocalStorage

// Initialize default users if not exists
function initializeData() {
    const existingUsers = localStorage.getItem('users');
    if (!existingUsers) {
        const defaultUsers = [
            { id: 1, name: 'Charlie Brown', email: 'charlie@example.com', phone: '555-0301' },
            { id: 2, name: 'Diana Prince', email: 'diana@example.com', phone: '555-0302' },
            { id: 3, name: 'Eve Wilson', email: 'eve@example.com', phone: '555-0303' }
        ];
        localStorage.setItem('users', JSON.stringify(defaultUsers));
    }
}

// Get all users from localStorage
function getAllUsers() {
    initializeData();
    const users = localStorage.getItem('users');
    return users ? JSON.parse(users) : [];
}

// Get a single user by ID
function getUserById(id) {
    const users = getAllUsers();
    return users.find(user => user.id === id);
}

// Add a new user
function addUser(user) {
    const users = getAllUsers();
    const newId = users.length > 0 ? Math.max(...users.map(u => u.id)) + 1 : 1;
    const newUser = {
        id: newId,
        name: user.name,
        email: user.email,
        phone: user.phone
    };
    users.push(newUser);
    localStorage.setItem('users', JSON.stringify(users));
    return newUser;
}

// Update an existing user
function updateUser(id, updatedUser) {
    const users = getAllUsers();
    const userIndex = users.findIndex(user => user.id === id);
    if (userIndex !== -1) {
        users[userIndex] = {
            id: id,
            name: updatedUser.name,
            email: updatedUser.email,
            phone: updatedUser.phone
        };
        localStorage.setItem('users', JSON.stringify(users));
        return users[userIndex];
    }
    return null;
}

// Delete a user
function deleteUser(id) {
    const users = getAllUsers();
    const filteredUsers = users.filter(user => user.id !== id);
    localStorage.setItem('users', JSON.stringify(filteredUsers));
    return true;
}

// Search users by name
function searchUsers(searchTerm) {
    const users = getAllUsers();
    return users.filter(user => 
        user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.email.toLowerCase().includes(searchTerm.toLowerCase())
    );
}

// Clear all data (for testing)
function clearAllData() {
    localStorage.removeItem('users');
    initializeData();
}

// Log data to console (for debugging)
function logData() {
    console.log('Current Users:', getAllUsers());
}
