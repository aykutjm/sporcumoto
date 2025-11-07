// Supabase Configuration
// IMPORTANT: Replace these values with your own Supabase server details

const SUPABASE_CONFIG = {
    url: 'YOUR_SUPABASE_URL', // örn: https://your-project.supabase.co
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
    serviceRoleKey: 'YOUR_SUPABASE_SERVICE_ROLE_KEY' // Only for admin operations
};

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SUPABASE_CONFIG;
}

