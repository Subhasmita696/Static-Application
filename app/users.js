// User Management UI Logic

let currentEditingUserId = null;

// Initialize the page
document.addEventListener('DOMContentLoaded', function() {
    loadUsers();
    
    // Setup search functionality
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('keyup', function() {
            searchUsers();
        });
    }
    
    // Setup form submission
    const userForm = document.getElementById('userForm');
    if (userForm) {
        userForm.addEventListener('submit', function(e) {
            e.preventDefault();
            saveUser();
        });
    }
});

// Load and display all users
function loadUsers() {
    const users = getAllUsers();
    displayUsers(users);
}

// Display users in grid
function displayUsers(users) {
    const container = document.getElementById('usersContainer');
    const noResults = document.getElementById('noResults');
    
    if (!container) return;
    
    if (users.length === 0) {
        container.innerHTML = '';
        noResults.style.display = 'block';
        return;
    }
    
    noResults.style.display = 'none';
    container.innerHTML = users.map(user => `
        <div class="user-card">
            <h3>${escapeHtml(user.name)}</h3>
            <p><strong>ID:</strong> ${user.id}</p>
            <p><strong>Email:</strong> ${escapeHtml(user.email)}</p>
            <p><strong>Phone:</strong> ${escapeHtml(user.phone)}</p>
            <div class="user-card-actions">
                <button class="btn btn-edit" onclick="editUser(${user.id})">Edit</button>
                <button class="btn btn-danger" onclick="confirmDelete(${user.id})">Delete</button>
            </div>
        </div>
    `).join('');
}

// Search users
function searchUsers() {
    const searchTerm = document.getElementById('searchInput').value;
    const results = searchUsers(searchTerm);
    displayUsers(results);
}

// Open modal for adding new user
function addNewUser() {
    currentEditingUserId = null;
    document.getElementById('modalTitle').textContent = 'Add New User';
    document.getElementById('userForm').reset();
    openModal();
}

// Open modal for editing user
function editUser(userId) {
    const user = getUserById(userId);
    if (user) {
        currentEditingUserId = userId;
        document.getElementById('modalTitle').textContent = 'Edit User';
        document.getElementById('userName').value = user.name;
        document.getElementById('userEmail').value = user.email;
        document.getElementById('userPhone').value = user.phone;
        openModal();
    }
}

// Save user (add or update)
function saveUser() {
    const name = document.getElementById('userName').value.trim();
    const email = document.getElementById('userEmail').value.trim();
    const phone = document.getElementById('userPhone').value.trim();
    
    // Validation
    if (!name || !email || !phone) {
        alert('Please fill in all fields');
        return;
    }
    
    const userData = {
        name: name,
        email: email,
        phone: phone
    };
    
    if (currentEditingUserId) {
        // Update existing user
        updateUser(currentEditingUserId, userData);
        alert('User updated successfully!');
    } else {
        // Add new user
        addUser(userData);
        alert('User added successfully!');
    }
    
    closeModal();
    loadUsers();
}

// Confirm and delete user
function confirmDelete(userId) {
    const user = getUserById(userId);
    if (user && confirm(`Are you sure you want to delete ${user.name}?`)) {
        deleteUser(userId);
        alert('User deleted successfully!');
        loadUsers();
    }
}

// Modal functions
function openModal() {
    const modal = document.getElementById('userModal');
    if (modal) {
        modal.classList.add('show');
    }
}

function closeModal() {
    const modal = document.getElementById('userModal');
    if (modal) {
        modal.classList.remove('show');
    }
    currentEditingUserId = null;
}

// Close modal when clicking outside
window.addEventListener('click', function(event) {
    const modal = document.getElementById('userModal');
    if (event.target === modal) {
        closeModal();
    }
});

// Utility function to escape HTML (prevent XSS)
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}
